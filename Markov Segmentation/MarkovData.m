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
        nextTask;
        currTask;
        currClust;
        prevTask;
        
        %Keep track of which tasks we have and haven't completed
        complete;
        
        %Keep track of how many tasks and how many skill levels there are
        maxTask;
        maxSkill;
        
        %The Markov Models representing the different tasks (the inner
        %Markov Models) this is a cell array of Markov Models
        MTask;
        %The Markov Model representing the procedure (the outer Markov
        %Model)
        MProc;
        %The Markov Models representing the different skills for the
        %different tasks (2D cell array)
        MSkill;
        
        %Keep a parameter collection object in which we can store all of
        %the necessary parameters for our task segmentation
        PC;
    end
    
    
    
    
    
    
    
    %We need to be able to add data to the object, and classify the
    %procedure into its task (in particular, deterMTaske what task is
    %currently being performed)
    methods
        
        %This constructor will create the object. We will already know the
        %number of degrees of freedom, but will not know how many data
        %points will be produced
        function M = MarkovData(maxTask,maxSkill)
            %Initialize count to be zero
            M.count = 0;
            M.seqCount = 0;
            
            %Initialize the data objects to be empty
            M.D = Data(zeros(1,1),zeros(1,8),zeros(1,1),0);
            M.DC = Data(zeros(1,1),zeros(1,1),zeros(1,1),0);
            M.DK = Data(zeros(1,1),zeros(1,1),zeros(1,1),0);
            
            %This object will refer to all parameters we will use
            M.PC = ParameterCollection();
            
            %Since the first task shall be zero since we cannot assume
            %anyhting about it
            M.nextTask = 0;
            M.currTask = 0;
            M.prevTask = 0;
            M.currClust = 0;
            
            %Initialize the number of tasks and number of skill levels
            M.maxTask = maxTask;
            M.maxSkill = maxSkill;
            
            %Nothing has been completed initially
            M.complete = zeros(1,maxTask);
            
            %Create the task and procedure Markov Models
            M = M.initilaizeMMs();
        end
        
        
        
        %This procedure will create the Markov models
        function M = initilaizeMMs(M)
            
            %Create cell array for the task  Markov Models
            M.MTask = cell(1,M.maxTask);
            
            %Iterate over all tasks (one Markov Model for each task)
            for t=1:M.maxTask
                
                %Create the task Markov Models
                M.MTask{t} = MarkovModel(strcat('Task',num2str(t)), 0, 0, 0);
                %Read the parameters from file
                M.MTask{t} = M.MTask{t}.read();
                
                %                 %Consider each skill level
                %                 for s=1:M.maxSkill
                %                     M.MSkill{s,t} = MarkovModel(strcat('Skill', num2str(s),'Task', num2str(t)), 0, 0, 0);
                %                     M.MSkill{s,t} = M.MSkill{s,t}.read();
                %                 end
                
            end
            
            %And finally create the procedure Markov Model
            M.MProc = MarkovModel('Proc', 0, 0, 0);
            M.MProc = M.MProc.read();
            
        end
        
        
        
        
        
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
            
            %Also, calculate what the next task should be given the current
            %task
            M = M.calcNextTask();
            
            %Also, update the completion vector if necessary
            M = M.updateCompletion();
            
        end
        
        
        
        
        
        
        %This function will take a point given as a transformation matrix
        %and add it (converting to DOFs and then using the addPoint method
        %defined previously)
        function M = addPointMatrix(M,t,A)
            %Convert the tranformation matrix to a quaternion, and use this
            %quternion for the addPoint method
            M = M.addPoint(t,matrixToDOF(A));
        end
        
        
        
        
        
        
        
        %This function is responsible for updating the array of clusters of
        %procedural data
        function C_Current = currentCluster(M)
            
            %Get the orthogonal transformation parameters
            orthParam = M.PC.get('Orth');
            
            %Calculate the points we will use to determine the spline. minHist
            %and maxHist indicate the points that are the max and min index.
            minHist = max(1,M.count - orthParam(2) + 1);    maxHist = M.count;
            vectHist = minHist:maxHist;
            
            %Create a data object with the relevant data
            D_Current = Data(M.D.T(vectHist,:),M.D.X(vectHist,:),M.D.K(vectHist,:),M.D.S);
            
            %Replace the most recent point if it is an outlier
            DS_Current = D_Current.replaceOutlierOne(M.PC.get('Outlier'));
            
            %Smooth the most recent data point
            DS_Current = DS_Current.smoothOne(M.PC.get('Accel'));
            
            %Perform an orthogonal transformation on our sequence of observations
            DO_Current = DS_Current.currentOrthogonal(orthParam);
            
            %Perform a pca transform according to the parameters
            DP_Current = DO_Current.pcaTransform(M.PC.get('TransPCA'),M.PC.get('Mn'));
            
            %Determine the cluster to which the data point belongs
            DC_Current = DP_Current.findCluster(M.PC.get('Cent'),M.PC.get('Weight'));
            
            %Assign the found cluster to the vector of all clusters
            C_Current = DC_Current.X;
            
        end
        
        
        
        
        
        
        %This function will return the current task, given all of the
        %points that were previously added to the object
        function K_Current = currentTask(M)
            %The task at the current time step depends upon the best Markov
            %Model (task), scaled by the transition matrix of the procedure
            %Markov Model
            
            %Calculate the points we will use to determine the spline. minHist
            %and maxHist indicate the points that are the max and min index.
            minHist = M.count - M.seqCount + 1;    maxHist = M.count;
            seqHist = minHist:maxHist;
            
            %Get the most recent clusterings
            XC = M.DC.X(seqHist,:);
            
            %Now, calculate the most likely Markov Model to have reproduced
            %the current sequence
            [task prob] = bestMarkov(XC,M.MTask,M.getScaling());
            %Probability previous sequence was produced by Markov Model
            [testTask1 testProb1] = bestMarkov(XC(1:end-1,:),M.MTask,M.getScaling());
            %Probability current observation was produced by Markov Model
            [testTask2 testProb2] = bestMarkov(XC(end),M.MTask);
            
            %If the cluster has never appeared before then do not change
            %tasks
            if (task == 0)
                task = M.currTask;
            end
            if (testTask1 == 0)
                testTask1 = M.currTask;
            end
            if (testTask2 == 0)
                testTask1 = M.currTask;
            end
            
            %Multiply the probabilities with the transition probability
            %of going from testTask1 to testTask2
            scale = M.MProc.getA();
            testProb = testProb1 * testProb2 * scale(testTask1,testTask2);
            
            %Calculate the ratio of probabilities
            probRat = testProb/prob;
            
            %Now, if the probability is less than the threshold probability,
            %clear the cluster sequence and try again. This means that we
            %have moved onto a new task.
            if ( prob == 0 || probRat > 1 )
                %Since there is a change in tasks, reassign the current
                %task to be the previous task
                M.prevTask = M.currTask;
                %Clear the current sequence (except for the most recent observation)
                M.seqCount = 1;
                
                %Calculate the current task again with the cleared sequence
                [task prob] = bestMarkov(M.DC.X(end,:),M.MTask,M.getScaling());
                
                %If the probability is zero (ie no allowed transitions)
                %then ignore transition proability and yield the most
                %likely unscaled task that is allowed
                if (prob == 0)
                    [task prob] = bestMarkov(M.DC.X(end,:),M.MTask,M.getAllow());
                end
                
                %If the proability is still zero, the yield the most likely
                %unallowed, unscaled task
                if (prob == 0)
                    [task prob] = bestMarkov(M.DC.X(end,:),M.MTask);
                end
                
                %If the cluster has never appeared before then do not change
                %tasks
                if (task == 0)
                    task = M.currTask;
                end

            end
            
            %The previous task will be replaced by the current task
            K_Current = task;
            
        end
        
        
        
        
        
        
        
        %This function will calculate what the next task should be given
        %what tasks have been completed and what has already been completed
        function M = calcNextTask(M)
            %Read the tensor indicating the next task from our parameter
            %collection
            next = M.PC.get('Next');
            %We must add one to each entry of complete, since indices are
            %1,2 not 0,1
            nextIndex = cat( 2, M.currTask, M.complete + 1 );
            %Now, index into the next tensor
            M.nextTask = next( linearIndex( nextIndex,size(next) ) );
        end
        
        
        
        
        
        %This function will update the completion vector appropriately if
        %we have reached an end cluster. Note that there only exists one
        %end cluster per task... use it wisely
        function M = updateCompletion(M)
            %Get a vector of end clusters
            End = M.PC.get('End');
            
            %So deterMTaske if the current cluster is the end cluster for the
            %any task by iterating over all tasks
            for i = 1:length(End)
                if ( M.DC.X(M.count) == End(i) )
                    M.complete(i) = 1;
                end
            end
            
        end
        
        
        
        
        
        
        %This function will be used to calculate the appropriate scaling
        %for the transition probability
        function scale = getScaling(M)
            %If we haven't started the procedure yet then do not account
            %for the previous task
            if (M.prevTask == 0)
                %The scaling shall be the initial task distribution
                scale = M.MProc.getPi();
            else
                %First, create a vector of scaling from the outer Markov Model
                scale = M.MProc.getA();
                %Consider the transition probabilities from the previous task
                scale = scale(M.prevTask,:);
            end
            
            %Return the scaling as a column vector rather than a row vector
            scale = scale';
            
            %Multiply the trained scaling by the allowed scaling so no
            %unallowed transitions occur
            scale = scale .* M.getAllow();
            
        end
        
        
        
        
        
        
        %This function will be used to calculate the appropriate scaling
        %for the transition probability only considering whether or not a
        %transition is allowed
        function allowScale = getAllow(M)
            %If we haven't started the procedure yet then do not account
            %for the previous task
            if (M.prevTask == 0)
                %Multiply the scaling by the allowed transitions
                allowScale = [1 0 0 0 0];
            else
                %Create a vector of scaling from the allowed transitions
                allowScale = M.PC.get('Allow');
                %Consider the transition probabilities from the previous task
                allowScale = allowScale(M.prevTask,:);
            end
            
            %Return the scaling as a column vector rather than a row vector
            allowScale = allowScale';
        end
        
        
        
        
%         %When all is said and done, we can deterMTaske the skill level of
%         %each task and from this the skill level of the entire procedure
%         function [S SP SPT] = skillClassify(M)
%             %First, we must convert the sequence of clusters and tasks into
%             %cells such that we can pass them into our motionSequenceByTask
%             %function
%             xc = cell(1,1);        kc = cell(1,1);
%             xc{1} = M.XC;          kc{1} = M.K;
%             
%             %Now, let us break down the tasks using the function we have
%             %already created
%             seqByTask = motionSequenceByTask(xc,kc);
%             
%             %Initiliaze the cell array of probabilities of each Markov
%             %Model for each instance of the task
%             SPT = cell(M.maxSkill,M.maxTask);
%             
%             %Now go through each task and calculate which Markov Model was
%             %the most likely to have produced this task
%             
%             %Iterate over all skill levels
%             for s=1:M.maxSkill
%                 %Iterate over all tasks
%                 for t=1:M.maxTask
%                     %Iterate over all instances of each task
%                     for i=1:length(seqByTask{t})
%                         %Make the current sequence a cell
%                         xq = seqByTask{t}{i};
%                         %DeterMTaske the probability that each skill-level of
%                         %Markov Model from the task produced the results
%                         SPT{s,t}(i) = cell2mat(M.MSkill{s,t}.seqProb(xq));
%                         %Now, since not all sequences are the same length, we will
%                         %weight the probabilities by taking the length root of
%                         %each probability
%                         SPT{s,t}(i) = SPT{s,t}(i) ^ ( 1/ length(xq) );
%                         %But shorter tasks should carry a lesser weight so
%                         %scale by the length
%                         SPT{s,t}(i) = SPT{s,t}(i) * length(xq);
%                     end
%                     %Now, find the combined probability for each skill-task
%                     %pair
%                     SPT{s,t} = prod( SPT{s,t} );
%                 end
%                 
%             end
%             
%             %Convert the cell array into a matrix and normalize
%             SPT = cell2mat(SPT);
%             
%             %Now we must normalize the columns of such that they sum to one
%             for t=1:M.maxTask
%                 SPT(:,t) = SPT(:,t) / sum( SPT(:,t ));
%             end
%             
%             %And the total skill is the expected value of the
%             %skill-levels over all tasks
%             SP = prod(SPT,2);
%             %Now we must normalize the columns of such that they sum to one
%             SP = SP / sum(SP);
%             
%             %The overall skill level is the maximum of the SP, but
%             %if the SP is a NaN (because all of the options are too
%             %unlikely) then return zero (unidentified)
%             if (isnan(SP))
%                 S = 0;
%             else
%                 S = maxIndex(SP);
%             end
%             
%             
%         end
        
        
    end %Methods
    
    
end %Classdef