%This class will be used to create an interface type object such that data
%points can be added to the object, and the classification algorithm can be
%run in real-time. Run the task segmentation algorithm every time we
%receive a new data point, as controlled by the getLDPoint function

classdef MarkovData
    
    
    
    
    
    %We need an array of data points, with an associated array of time
    %stamps, and a count of the number of time stamps we have
    properties (SetAccess = private)
        
        %Note: We will not use the task field of the data objects here
        %The entirity of the collected data
        D;
        %The collection of states (determined by the Kalman filter)
        DS;
        %The entire collection of clusters
        DC;
        %The data collection of tasks
        DK;
        
        %We also need counts of the lengths of all of these things
        %A count of how many time steps we have data from
        count;
        seqCount;
        
        %Keep track of what the current task is and what the previous task
        %was and what the next task should be
        currTask;
        currClust;
        currState;
        prevTask;
        

        %The Markov Model representing the procedure (the outer Markov
        %Model)
        MProc;

        %Keep a parameter collection object in which we can store all of
        %the necessary parameters for our task segmentation
        PC;
        
        %Retain the P matrix from the Kalman filtering so we can update
        kalmanP;
        
    end %Properties
    
    
    
    
    
    
    
    %We need to be able to add data to the object, and classify the
    %procedure into its task (in particular, deterMTaske what task is
    %currently being performed)
    methods
        
        %This constructor will create the object. We will already know the
        %number of degrees of freedom, but will not know how many data
        %points will be produced
        function M = MarkovData()
            
            %Initialize count to be zero
            M.count = 0;
            M.seqCount = 0;
            
            %Initialize the data objects to be empty
            M.D = Data(zeros(1,1),zeros(1,8),zeros(1,1),0);
            M.DS = Data(zeros(1,1),zeros(1,8),zeros(1,1),0);
            M.DC = Data(zeros(1,1),zeros(1,1),zeros(1,1),0);
            M.DK = Data(zeros(1,1),zeros(1,1),zeros(1,1),0);
            
            %This object will refer to all parameters we will use
            M.PC = ParameterCollection();
            
            %Since the first task shall be zero since we cannot assume
            %anyhting about it
            M.currTask = 0;
            M.prevTask = 0;
            M.currClust = 0;
            
            %Initialize the Kalman P matrix to be the identity
            M.kalmanP = eye(8);
            
            %And finally create the procedure Markov Model
            M.MProc = MarkovModel('Markov', 0, 0, 0);
            M.MProc = M.MProc.read();
            
        end%function
       
        
        
        %This function will be used to add a data point to the object,
        %noting that a transformation matrix will be provided
        function M = addPoint(M,t,x)
            
            %Increment the count of time steps
            M.count = M.count + 1;
            M.seqCount = M.seqCount + 1;
            
            %Get a reference to the data object for all collected points we
            %wish to add this new point to
            T = M.D.T;  X = M.D.X; K = M.D.K;          
            %Add the newest point to our array of points
            T(M.count,:) = t;
            X(M.count,:) = x;
            K(M.count,:) = 0;
            M.D = Data(T,X,K,M.D.S);
            
            %Calculate the current state
            M.currState = M.currentState();
            
            
            %Get a reference to the data object for all collected points we
            %wish to add this new point to
            TS = M.D.T;  XS = M.D.X; KS = M.D.K;          
            %Add the newest point to our array of points
            TS(M.count,:) = t;
            XS(M.count,:) = M.currState.X(end,:);
            KS(M.count,:) = 0;
            M.DS = Data(TS,XS,KS,M.D.S);
            
            %Calculate the current cluster
            M.currClust = M.currentCluster();
            

            %Get a reference to the data object for all collected points we
            %wish to add this new point to
            TC = M.DC.T;  XC = M.DC.X; KC = M.DC.K;  
            %Add the newest point to our array of points
            TC(M.count,:) = t;
            XC(M.count,:) = M.currClust;
            KC(M.count,:) = 0;
            M.DC = Data(TC,XC,KC,M.DC.S);
            
            %Calculate the current task
            M.currTask = M.currentTask();
            
            
            %Get a reference to the data object for all collected points we
            %wish to add this new point to
            TK = M.DK.T;  XK = M.DK.X; KK = M.DK.K;          
            %Add the newest point to our array of points
            TK(M.count,:) = t;
            XK(M.count,:) = M.currTask;
            KK(M.count,:) = 0;
            M.DK = Data(TK,XK,KK,M.DK.S);
            
        end%function
        
        
        
        
        
        
        %This function will take a point given as a transformation matrix
        %and add it (converting to DOFs and then using the addPoint method
        %defined previously)
        function M = addPointMatrix(M,t,mat)
            
            %Convert matrix to quaternion; use quaternion in addPoint
            M = M.addPoint(t,matrixToDOF(mat));
            
        end%function
        
        
        
        
        %This function will calculate the current state of the motion,
        %given the observed motion based on Kalman filtering
        function S_Current = currentState(M)
        
            %Create a data object with the relevant data
            D_Current = M.D;
            
            %Apply the Kalman filtering algorithm
            S_Current = D_Current.movingAverageLast(M.PC.get('Average'),'Gaussian');
            
        end%function
        
        
        
        
        
        %This function is responsible for updating the array of clusters of
        %procedural data
        function C_Current = currentCluster(M)
            
            %Get the orthogonal transformation parameters
            orthParam = M.PC.get('Orthogonal');
            
            %Calculate the points we will use to determine the spline. minHist
            %and maxHist indicate the points that are the max and min index.
            minHist = max(1,M.count - orthParam(2) + 1);    maxHist = M.count;
            vectHist = minHist:maxHist;
            
            %Create a data object with the relevant data
            DS_Current = Data(M.DS.T(vectHist,:),M.DS.X(vectHist,:),M.DS.K(vectHist,:),M.D.S);
            
            %Calculate the velocities, and concatenate
            DV_Current = DS_Current;
            
            %Iterate until we have added the appropriate derivatives
            for d=1:M.PC.get('Derivative')
                DV_Current = DV_Current.concatenateDOF( DS_Current.derivative(d) );
            end%for
            
            %Perform an orthogonal transformation on our sequence of observations
            DO_Current = DV_Current.orthogonalLast(orthParam);
            
            %Perform a pca transform according to the parameters
            DP_Current = DO_Current.pcaTransform(M.PC.get('TransPCA'),M.PC.get('MeanPCA'));
            
            %Determine the cluster to which the data point belongs
            DC_Current = DP_Current.findCluster(M.PC.get('Centroids'),M.PC.get('Weight'),M.PC.get('Clout'));
            
            %Assign the found cluster to the vector of all clusters
            C_Current = DC_Current.X;
            
        end%function
        
        
        
        
        
        
        %This function will return the current task, given all of the
        %points that were previously added to the object
        function K_Current = currentTask(M)
           
            %minHist and maxHist indicate max and min indices
            minHist = M.count - M.seqCount + 1;    maxHist = M.count;
            seqHist = minHist:maxHist;
            
            %Get the most recent clusterings
            XC = M.DC.X(seqHist,:);
            
            %Create a vector of scaling from the allowed transitions
            allowScale = M.PC.get('Allow');
            
            %Calculate the most likely state sequence
            M_Allow = MarkovModel('Allow',M.MProc.pi, M.MProc.A .* allowScale, M.MProc.B);
            [~, K_Current] = M_Allow.statePath(XC);
            
            %Grab the last state of the sequence
            K_Current = K_Current(end);
            
        end%function
        

        
    end %Methods
    
    
end %Classdef