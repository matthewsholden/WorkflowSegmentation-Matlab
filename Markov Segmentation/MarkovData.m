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
        Cluster;
        %An array to keep track of the current sequence of clusters
        Sequence;
        %An array of task classifications of the procedure
        Task;
        %An array of task classifications at the corresponding time step
        TaskTime;
        
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
        
        %Keep track of how many tasks and how many skill levels there are
        maxTask;
        maxSkill;
        
        %Also, keep track of whether or not each task has been sufficiently
        %completed. Note: This is a binary vector: 0 = not complete, 1
        %= complete
        complete;
        %This next tensor will determine what task should be done next
        nextTensor;
        
        %In addition, we need a matrix of allowed transitions
        Allow;
        
        %We will need to know the end clusters in order to determine if
        %tasks have been sufficiently completed
        endCluster;
        
        %The Markov Models representing the different tasks (the inner
        %Markov Models) this is a cell array of Markov Models
        MIn;
        %The Markov Model representing the procedure (the outer Markov
        %Model)
        MOut;
        %The Markov Models representing the different skills for the
        %different tasks (2D cell array)
        MSkill;
        
        %The parameters for the submotion transform
        %Elapse: How many time steps to elapse between projections
        %History: How many time steps to use to calculate the projection
        %Interp: How many interpolated points will be used to calculate the
        %projection
        %Order: The order of the transformation required
        %Retain: How many data points is the maximum we will retain in our
        %sequence
        elapse;
        history;
        interp;
        order;
        retain;
        
        %We also need to keep track of the centroids so that we know how to
        %cluster our projections
        Centroid;
        
        %The weighting for our clustering
        W;
        
        %We will also use our centroid parameters to determine if an
        %observation is close enough to a cluster to be classified as a
        %member of that cluster
        k;
    end
    
    
    
    
    
    
    
    %We need to be able to add data to the object, and classify the
    %procedure into its task (in particular, determine what task is
    %currently being performed)
    methods
        
        %This constructor will create the object. We will already know the
        %number of degrees of freedom, but will not know how many data
        %points will be produced
        function M = MarkovData(maxSkill,maxTask)
            %Initialize all counts to be zero
            M.stepCount = 0;
            M.clustCount = 0;
            M.seqCount = 0;
            M.elapseCount = 0;
            
            %Initilalize all arrays of data to be zero with only one point
            %of data
            M.T = zeros(1,1);
            M.X = zeros(8,1);
            M.Cluster = zeros(1,1);
            M.Sequence = zeros(1,1);
            M.Task = zeros(1,1);
            M.TaskTime = zeros(1,1);
            
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
            
            %Create cell arrays for the inner and outer Markov Models
            M.MIn = cell(1,maxTask);
            M.MOut = cell(1,1);
            
            %Create an organizer such that the data is written to the
            %specified location in file
            o = Organizer();
            
            %Create the inner Markov Models...
            for t=1:maxTask
                M.MIn{t} = MarkovModel(strcat('Inner',num2str(t)), 0, 0, 0);
                %Read the parameters from file
                M.MIn{t} = M.MIn{t}.read();
                %Consider each skill level
                for s=1:maxSkill
                    M.MSkill{s,t} = MarkovModel(strcat('Skill', num2str(s), 'Task', num2str(t)), 0, 0, 0);
                    M.MSkill{s,t} = M.MSkill{s,t}.read();
                end
            end
            
            %And finally create the outer Markov Model
            M.MOut{1} = MarkovModel('Outer', 0, 0, 0);
            M.MOut{1} = M.MOut{1}.read();
            
            %Also, we need to know the number of time steps between
            %projections, the number of time steps used in calculating a
            %projection and the order of projection required
            [M.elapse M.history M.interp M.order M.retain] = readLD();
            
            %Read the centroids from file for clustering the observations
            M.Centroid = o.read('Centroid');
            
            %Read the cluster dimension weighting from file
            M.W = o.read('Weight');
            
            %Read the end clusters from file
            M.endCluster = o.read('End');
            
            %Read the tensor indicating what should be done next fron file
            M.nextTensor = o.read('Next');
            
            %Read the matrix of allowed transitions from file
            M.Allow = MarkovModel('Allow',0,0,0);
            M.Allow = M.Allow.read();
            
            %Read the clustering parameters from file (we really just need
            %the value of thresh)
            M.k = o.read('K');
        end
        
        
        
        
        
        
        %This function will be used to add a data point to the object,
        %noting that a transformation matrix will be provided
        function M = addPoint(M,t,x)
            %Increment the count of time steps
            M.stepCount = M.stepCount + 1;
            %Assign the next time stamp to the array
            M.T(M.stepCount) = t;
            %Assign the dofs to the array of dofs
            M.X(:,M.stepCount) = x;
            
            %Update the sequence of clusters
            M = M.updateClusters();
            
            %If no sequence has been produced yet, then just return
            if (M.Sequence == 0)
                return;
            end
            
            %Calculate the task currently being executed and adjust the
            %current task attribute accordingly
            M = M.calcCurrentTask();
            
            %Now that we have calculated the task, add it to the task array
            M.Task(M.clustCount) = M.currTask;
            M.TaskTime(M.stepCount) = M.currTask;
            
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
            
            %If we have allowed an appropriate number of time steps to
            %elapse in order for the initial time (where we do not have a
            %sufficient history of points) then increment the count of
            %elapsed steps
            if (M.stepCount > M.history - M.elapse)
                M.elapseCount = M.elapseCount + 1;
            end
            
            %Ensure that the sufficient number of time steps have elapsed
            if (M.elapseCount == M.elapse)
                %First, increment the count of clusters and the count of
                %the current sequence of clusters
                M.clustCount = M.clustCount + 1;
                M.seqCount = M.seqCount + 1;
                
                %Preallocate x and t for speed
                t = zeros(1,M.interp);
                x = zeros(size(M.X,1),M.interp);
                
                %Calculate the points we will use to determine the spline. minHist
                %and maxHist indicate the points that are the maximum and minimum
                %index.
                minHist = M.stepCount - M.history + 1;
                maxHist = M.stepCount;
                
                %Now, iterate over all interp points and determine the times at
                %which these points shall occur
                for l=1:M.interp
                    t(l) = M.T(minHist) + (l - 1) * ( M.T(maxHist) - M.T(minHist) ) / (M.interp - 1);
                end
                
                %Now iterate over all degrees of freedom
                for i=1:size(M.X,1)
                    %For each interp point
                    for l=1:M.interp
                        %Calculate the value of the degree of freedom at the interp
                        %points using a velocity spline interpolation
                        x(i,l) = velocitySpline(M.T(minHist:maxHist),M.X(i,minHist:maxHist),t(l));
                    end
                end
                
                %Finally, we can perform a submotion transform on these interp data
                LD = submotionTransform(t,x,M.order);
                
                %Find the cluster to which the projection belongs and assign
                %that to the vector of clusters
                M.Cluster(M.clustCount) = motionCluster(LD,M.Centroid,M.W);
                
                %Assign this new cluster to the sequence vector of current
                %clusters
                M.Sequence(M.seqCount) = M.Cluster(M.clustCount);
                
                %If the length of the current vector is longer than retain,
                %throw away the first entry
                if (M.seqCount > M.retain)
                    %Decrease seqCount
                    M.seqCount = M.seqCount - 1;
                    %Throw away the first (least recent) entry
                    M.Sequence = M.Sequence(2:end);
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
            [task prob] = bestMarkov(M.Sequence,M.MIn,M.getScaling());
            
            %If the cluster has never appeared before then do not change
            %tasks
            if (task == 0)
                task = M.currTask;
            end
            
            %Calculate the probability that the previous sequence
            %was produced by a Markov Model
            [testTask1 testProb1] = bestMarkov(M.Sequence(1:end-1),M.MIn,M.getScaling());
            %Calculate the probability that the current observation was
            %produced by a Markov Model
            [testTask2 testProb2] = bestMarkov(M.Sequence(end),M.MIn);
            
            
            %If the cluster has never appeared before then do not change
            %tasks
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
            
            ra = testProb/prob;
            
            
            %Now, if the probability is less than the threshold probability,
            %clear the cluster sequence and try again. This means that we
            %have moved onto a new task. The number of clusters and tasks
            %will be accounted for in our threshold constant.
            if ( ra > 1 )
                %Since there is a change in tasks, reassign the current
                %task to be the previous task
                M.prevTask = M.currTask;
                %Clear the current sequence (except for the most recent observation)
                M.Sequence = M.Sequence(end);
                M.seqCount = 1;
                
                %Calculate the current task again with the cleared sequence
                [task prob] = bestMarkov(M.Sequence,M.MIn,M.getScaling());
                
                %If the probability is zero (ie no allowed transitions)
                %then ignore transition proability and yield the most
                %likely unscaled task that is allowed
                if (prob == 0)
                    [task prob] = bestMarkov(M.Sequence,M.MIn,M.getAllow());
                end
                
                %If the proability is still zero, the yield the most likely
                %unallowed, unscaled task
                if (prob == 0)
                    [task prob] = bestMarkov(M.Sequence,M.MIn);
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
            %Create a indicating the index of the nextTensor we are interested in.
            
            %We must add one to each entry of complete, since indices are
            %1,2 not 0,1
            nextIndex = cat( 2, M.currTask, M.complete + 1 );
            %Now, index into the completion tensor
            M.nextTask = M.nextTensor(linearIndex(nextIndex,size(M.nextTensor)));
            %this has determined the next task
        end
        
        
        
        
        
        %This function will update the completion vector appropriately if
        %we have reached an end cluster. Note that there only exists one
        %end cluster per task... use it wisely
        function M = updateCompletion(M)
            %So determine if the current cluster is the end cluster for the
            %any task by iterating over all tasks
            for i = 1:length(M.complete)
                if (M.Cluster(M.clustCount) == M.endCluster(i))
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
                %Only consider the transition probabilities from the previous
                %task
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
                allowScale = M.Allow.getPi();
            else
                %Create a vector of scaling fro mthe allowed transitions
                allowScale = M.Allow.getA();
                %Only consider the transition probabilities from the previous
                %task
                allowScale = allowScale(M.prevTask,:);
                
            end
            
            %Return the scaling as a column vector rather than a row vector
            allowScale = allowScale';
        end
        
        
        
        
        %When all is said and done, we can determine the skill level of
        %each task and from this the skill level of the entire procedure
        function [skillLevel skillProb taskSkillProb] = skillClassify(M)
            %First, we must convert the sequence of clusters and tasks into
            %cells such that we can pass them into our motionSequenceByTask
            %function
            cluster = cell(1,1);    TaskD = cell(1,1);
            cluster{1} = M.Cluster;
            TaskD{1} = M.Task;
            currSeq = cell(1,1);
            
            %Now, let us break down the tasks using the function we have
            %already created
            seqByTask = motionSequenceByTask(cluster,TaskD);
            
            %Initiliaze the cell array of probabilities of each Markov
            %Model for each instance of the task
            p = cell(M.maxSkill,max(TaskD{1}));
            
            %Now go through each task and calculate which Markov Model was
            %the most likely to have produced this task
            
            %Iterate over all skill levels
            for s=1:M.maxSkill
                %Iterate over all tasks
                for t=1:max(TaskD{1})
                    %Iterate over all instances of each task
                    for i=1:length(seqByTask{t})
                        %Make the current sequence a cell
                        currSeq{1} = seqByTask{t}{i};
                        %Determine the probability that each skill-level of
                        %Markov Model from the task produced the results
                        p{s,t}(i) = cell2mat(M.MSkill{s,t}.seqProb(currSeq));
                        %Now, since not all sequences are the same length, we will
                        %weight the probabilities by taking the length root of
                        %each probability
                        p{s,t}(i) = p{s,t}(i)^(1/length(seqByTask{t}(i)));
                        %But shorter tasks should carry a lesser weight so
                        %scale by the length
                        p{s,t}(i) = p{s,t}(i)*length(seqByTask{t}(i));
                    end
                    %Now, find the combined probability for each skill-task
                    %pair
                    p{s,t} = prod(p{s,t});
                end
                
            end
            
            %Convert the cell array into a matrix and normalize
            p = cell2mat(p);
            
            %Now we must normalize the columns of such that they sum to one
            for t=1:max(TaskD{1})
                taskSkillProb(:,t) = p(:,t) / sum(p(:,t));
            end
            
            %And the total skill is the expected value of the
            %skill-levels over all tasks
            skillProb = prod(taskSkillProb,2);
            %Now we must normalize the columns of such that they sum to one
            skillProb = skillProb / sum(skillProb);
            
            %The overall skill level is the maximum of the skillProb, but
            %if the skillProb is a NaN (because all of the options are too
            %unlikely) then return zero (unidentified)
            if (isnan(skillProb))
                skillLevel = 0;
            else
                skillLevel = maxIndex(skillProb);
            end
            
            
        end
        
        
    end
    
    
    
    
end