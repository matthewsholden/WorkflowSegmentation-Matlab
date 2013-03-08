%This class will be used to create an interface type object such that data
%points can be added to the object, and the classification algorithm can be
%run in real-time. Run the task segmentation algorithm every time we
%receive a new data point, as controlled by the getLDPoint function

classdef MarkovData
    
    
    
    
    
    %We need an array of data points, with an associated array of time
    %stamps, and a count of the number of time stamps we have
    properties (SetAccess = private)
        %An array of time stamps
        T;
        %A matrix containing the degrees of freedom
        X;
        %An array of clusters
        XC;
        %The current sequence of clusters
        XQ;
        %An array of task classifications of the procedure
        K;
        %An array of task classifications at the corresponding time step
        KC;
        
        %We also need counts of the lengths of all of these things
        %A count of how many time steps we have data from
        stepCount;  %T and X
        clustCount; %Cluster and Task
        seqCount;   %Sequence
        elapseCount; %Time steps between consecutive projections
        
        %Keep track of what the current task is and what the previous task
        %was and what the next task should be
        nextTask;
        currTask;
        prevTask;
        
        %Keep track of which tasks we have and haven't completed
        complete;
        
        %Keep track of how many tasks and how many skill levels there are
        maxTask;
        maxSkill;
        
        %The Markov Models representing the different tasks (the inner
        %Markov Models) this is a cell array of Markov Models
        MIn;
        %The Markov Model representing the procedure (the outer Markov
        %Model)
        MOut;
        %The Markov Models representing the different skills for the
        %different tasks (2D cell array)
        MSkill;
        
        %Keep a parameter collection object in which we can store all of
        %the necessary parameters for our task segmentation
        PC;
    end
    
    
    
    
    
    
    
    %We need to be able to add data to the object, and classify the
    %procedure into its task (in particular, determine what task is
    %currently being performed)
    methods
        
        %This constructor will create the object. We will already know the
        %number of degrees of freedom, but will not know how many data
        %points will be produced
        function M = MarkovData(maxTask,maxSkill)
            %Initialize all counts to be zero
            M.stepCount = 0;
            M.clustCount = 0;
            M.seqCount = 0;
            M.elapseCount = 0;
            
            %Initilalize all arrays of data to be zero with only one point
            %of data
            M.T = zeros(1,1);
            M.X = zeros(1,8);
            M.XC = zeros(1,1);
            M.XQ = zeros(1,1);
            M.K = zeros(1,1);
            M.KC = zeros(1,1);
            
            %Since the first task shall be zero since we cannot assume
            %anyhting about it
            M.nextTask = 0;
            M.currTask = 0;
            M.prevTask = 0;
            
            %Initialize the number of tasks and number of skill levels
            M.maxTask = maxTask;
            M.maxSkill = maxSkill;
            
            %Nothing has been completed initially
            M.complete = zeros(1,maxTask);
            
            %Create the inner and outer Markov Models
            M = M.createMMs();
            
            %Create the parameter collection object, reading the parameter
            %values from file
            M.PC = ParameterCollection();
        end
        
        
        %This procedure will create the Markov models
        function M = createMMs(M)
            %Create cell arrays for the inner and outer Markov Models
            M.MIn = cell(1,M.maxTask);
            M.MOut = cell(1,1);
            
            %Create the inner Markov Models...
            for t=1:M.maxTask
                M.MIn{t} = MarkovModel(strcat('Inner',num2str(t)), 0, 0, 0);
                %Read the parameters from file
                M.MIn{t} = M.MIn{t}.read();
                %Consider each skill level
                for s=1:M.maxSkill
                    M.MSkill{s,t} = MarkovModel(strcat('Skill', num2str(s),'Task', num2str(t)), 0, 0, 0);
                    M.MSkill{s,t} = M.MSkill{s,t}.read();
                end
            end
            
            %And finally create the outer Markov Model
            M.MOut{1} = MarkovModel('Outer', 0, 0, 0);
            M.MOut{1} = M.MOut{1}.read();
            
        end
        
        
        
        
        
        %This function will be used to add a data point to the object,
        %noting that a transformation matrix will be provided
        function M = addPoint(M,t,x)
            %Increment the count of time steps
            M.stepCount = M.stepCount + 1;
            %Assign the next time stamp to the array
            M.T(M.stepCount,:) = t;
            %Assign the dofs to the array of dofs
            M.X(M.stepCount,:) = x;
            
            %Update the sequence of clusters
            M = M.updateClusters();
            
            %If no sequence has been produced yet, then just return
            if (M.XQ == 0)
                return;
            end
            
            %Calculate the task currently being executed and adjust the
            %current task attribute accordingly
            M = M.calcCurrentTask();
            
            %Now that we have calculated the task, add it to the task array
            M.K(M.clustCount) = M.currTask;
            M.KC(M.stepCount) = M.currTask;
            
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
            %First, create a local variable, and use this to store the
            %array of DOFs, which we have converted from the 4x4
            %transformation matrix
            x=matrixToDOF(A);
            %Now call the add point function using this previously defined
            %function
            M = M.addPoint(t,x);
        end
        
        
        
        
        
        
        
        %This function is responsible for updating the array of clusters of
        %procedural data
        function M = updateClusters(M)
            
            %Find the orthogonal transformation parameters
            Orth = M.PC.get('Orth');
            
            %If we have allowed an appropriate number of time steps to
            %elapse in order for the initial time (where we do not have a
            %sufficient history of points) then increment the count of
            %elapsed steps
            if (M.stepCount > Orth(2) - Orth(1))
                M.elapseCount = M.elapseCount + 1;
            end
            
            %Ensure that the sufficient number of time steps have elapsed
            if (M.elapseCount == Orth(1))
                
                %Increment the count of clsuters and sequence
                M.clustCount = M.clustCount + 1;
                M.seqCount = M.seqCount + 1;
                
                %Calculate the points we will use to determine the spline. minHist
                %and maxHist indicate the points that are the maximum and minimum
                %index.
                minHist = M.stepCount - Orth(2) + 1;    maxHist = M.stepCount;
                vectHist = minHist:maxHist;
                
                %Create a data object with the relevant data
                D = Data(M.T(vectHist),M.X(vectHist,:),zeros(1,length(vectHist)),0);
                
                %Perform an orthogonal transformation on our sequence of observations
                DO = D.orthogonal(M.PC.get('Orth'));
                
                %Perform a pca transform according to the parameters
                DP = DO.pcaTransform( M.PC.get('TransPCA'), M.PC.get('Mn') );
                
                %Then perform a transformation according to the lda
                %                 DL = DP.ldaTransform( M.PC.get('TransLDA') );
                
                %Initialize the cell array of data objects containing
                %clusters and distances
                %                 DC = cell(1,M.maxTask);
                %                 dis = zeros(1,M.maxTask);
                
                %Find the cluster to which the transformation belongs,
                %iterating over all possible transformations
                %                 for t = 1:M.maxTask
                %                     [DC{t} dis(t)]= DP{t}.findCluster(M.PC.get('Cent'),M.PC.get('Weight'));
                %                 end
                %
                %                 %Determine the smallest distance
                %                 [~, mix] = min(dis);
                %
                %                 %Determine the smallest distance
                %                 DC = DC{mix};
                
                DC = DP.findCluster(M.PC.get('Cent'),M.PC.get('Weight'));
                
                %hold on;
                %plot3(DP{mix}.X(:,1),DP{mix}.X(:,2),DP{mix}.X(:,3));
                
                %Assign the found cluster to the vector of all clusters
                M.XC(M.clustCount) = DC.X;
                
                %Assign this new cluster to the sequence vector of current
                %clusters
                M.XQ(M.seqCount) = M.XC(M.clustCount);
                
                %If the length of the current vector is longer than retain,
                %throw away the first entry
                if (M.seqCount > Orth(5))
                    %Decrease seqCount
                    M.seqCount = M.seqCount - 1;
                    %Throw away the first (least recent) entry
                    M.XQ = M.XQ(2:end);
                end
                
                %Reset the coutn of elapsed steps
                M.elapseCount = 0;
                
            end
            
        end
        
        
        
        
        
        
        %This function will return the current task, given all of the
        %points that were previously added to the object
        function M = calcCurrentTask(M)
            %The task at the current time step depends upon the best Markov
            %Model (inner), scaled by the transition matrix of the outer
            %Markov Model
            
            %Now, calculate the most likely Markov Model to have reproduced
            %the current sequence
            [task prob] = bestMarkov(M.XQ,M.MIn,M.getScaling());
            %Probability previous sequence was produced by Markov Model
            [testTask1 testProb1] = bestMarkov(M.XQ(1:end-1),M.MIn,M.getScaling());
            %Probability current observation was produced by Markov Model
            [testTask2 testProb2] = bestMarkov(M.XQ(end),M.MIn);
            
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
            scale = M.MOut{1}.getA();
            testProb = testProb1 * testProb2 * scale(testTask1,testTask2);
            
            %Calculate the ratio of probabilities
            probRat = testProb/prob;
            
            %Now, if the probability is less than the threshold probability,
            %clear the cluster sequence and try again. This means that we
            %have moved onto a new task. The number of clusters and tasks
            %will be accounted for in our threshold constant.
            if ( prob == 0 || probRat > 1 )
                %Since there is a change in tasks, reassign the current
                %task to be the previous task
                M.prevTask = M.currTask;
                %Clear the current sequence (except for the most recent observation)
                M.XQ = M.XQ(end);
                M.seqCount = 1;
                
                %Calculate the current task again with the cleared sequence
                [task prob] = bestMarkov(M.XQ,M.MIn,M.getScaling());
                
                %If the probability is zero (ie no allowed transitions)
                %then ignore transition proability and yield the most
                %likely unscaled task that is allowed
                if (prob == 0)
                    [task prob] = bestMarkov(M.XQ,M.MIn,M.getAllow());
                end
                
                %If the proability is still zero, the yield the most likely
                %unallowed, unscaled task
                if (prob == 0)
                    [task prob] = bestMarkov(M.XQ,M.MIn);
                end
                
                %If the cluster has never appeared before then do not change
                %tasks
                if (task == 0)
                    task = M.currTask;
                end
                
                %When we start a task, it means that we haven't completed
                %it even if we completed it previously (may be undoing it)
                %so set our completion tensor to zero for the new task
                M.complete(task) = 0;
            end
            
            %The previous task will be replaced by the current task
            M.currTask = task;
            
            %This has calculated the task
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
            
            %So determine if the current cluster is the end cluster for the
            %any task by iterating over all tasks
            for i = 1:length(End)
                if ( M.XC(M.clustCount) == End(i) )
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
                scale = M.MOut{1}.getPi();
            else
                %First, create a vector of scaling from the outer Markov Model
                scale = M.MOut{1}.getA();
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
        
        
        
        
        %When all is said and done, we can determine the skill level of
        %each task and from this the skill level of the entire procedure
        function [S SP SPT] = skillClassify(M)
            %First, we must convert the sequence of clusters and tasks into
            %cells such that we can pass them into our motionSequenceByTask
            %function
            xc = cell(1,1);        kc = cell(1,1);
            xc{1} = M.XC;          kc{1} = M.K;
            
            %Now, let us break down the tasks using the function we have
            %already created
            seqByTask = motionSequenceByTask(xc,kc);
            
            %Initiliaze the cell array of probabilities of each Markov
            %Model for each instance of the task
            SPT = cell(M.maxSkill,M.maxTask);
            
            %Now go through each task and calculate which Markov Model was
            %the most likely to have produced this task
            
            %Iterate over all skill levels
            for s=1:M.maxSkill
                %Iterate over all tasks
                for t=1:M.maxTask
                    %Iterate over all instances of each task
                    for i=1:length(seqByTask{t})
                        %Make the current sequence a cell
                        xq = seqByTask{t}{i};
                        %Determine the probability that each skill-level of
                        %Markov Model from the task produced the results
                        SPT{s,t}(i) = cell2mat(M.MSkill{s,t}.seqProb(xq));
                        %Now, since not all sequences are the same length, we will
                        %weight the probabilities by taking the length root of
                        %each probability
                        SPT{s,t}(i) = SPT{s,t}(i) ^ ( 1/ length(xq) );
                        %But shorter tasks should carry a lesser weight so
                        %scale by the length
                        SPT{s,t}(i) = SPT{s,t}(i) * length(xq);
                    end
                    %Now, find the combined probability for each skill-task
                    %pair
                    SPT{s,t} = prod( SPT{s,t} );
                end
                
            end
            
            %Convert the cell array into a matrix and normalize
            SPT = cell2mat(SPT);
            
            %Now we must normalize the columns of such that they sum to one
            for t=1:M.maxTask
                SPT(:,t) = SPT(:,t) / sum( SPT(:,t ));
            end
            
            %And the total skill is the expected value of the
            %skill-levels over all tasks
            SP = prod(SPT,2);
            %Now we must normalize the columns of such that they sum to one
            SP = SP / sum(SP);
            
            %The overall skill level is the maximum of the SP, but
            %if the SP is a NaN (because all of the options are too
            %unlikely) then return zero (unidentified)
            if (isnan(SP))
                S = 0;
            else
                S = maxIndex(SP);
            end
            
            
        end
        
        
    end %Methods
    
    
end %Classdef