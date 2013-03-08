%Training:
%1. Collect LD Points from files
%2. Determine centroids
%3. Determine indices
%4. Train Inner Markov Model (Baum-Welch)
%5. Estimate Outer Markov Model (Viterbi Estimation)
%6. Write Markov Models to file

%This function will retrieve a list of procedures from file and from these
%procedures train a Markov Model which will be used to segment and classify
%further procedures performed

%Return status: Whether or not the procedure completed successfully
function status = markovTrain()

%Indicate that the procedure is not finished
status = 0;

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%Read the matrix of sensical transitions to file (such that we can pad the
%experimental data with sensical transitions that may not have occurred)
Sense = MarkovModel('Sense',0,0,0);
Sense = Sense.read();

%Read the procedural records from file
D = readRecord();
%Iterate over all D
for i=1:length(D)
    T{i} = D{i}.T;
    X{i} = D{i}.X;
    Task{i} = D{i}.K;
    Skill{i} = D{i}.S;
end


%Read the number of clusters from file
k = o.read('K');
%Also, read the parameters relevant to determining the points in lower
%dimensional space from file
LDParam = o.read('Orth');





%Ok, so the array of times shall only be one dimensional
procs = length(T);
%Now, determine the maximum task number for future reference and the
%maximum skill level
maxTask = calcMaxTask(Task);
maxSkill = max(cell2mat(Skill));
%Determine the total number of clusters we will have available
kTotal = sum(k) + maxTask;


%Let's create an array of all of the LD points from all of the files
%Initialize the matrix such that we have something to concatenate nothing
%with
LDCat = zeros(0,0);
%Also, we want to concatenate all of the centroids and weightings together
CCat = zeros(0,0);

%Preallocate the sizes of our cell array of lower-dimensionally projected
%procedural data
LD = cell(1,procs);
TD = cell(1,procs);
TaskD = cell(1,procs);

%Get all of the LD (lower-dimensional) points for each array
for p=1:procs
    %Now that we know how many files we have, find the LD (lower-dimensional)
    %points for each array
    [LD{p} TD{p} TaskD{p}] = LDTransform(T{p},X{p},Task{p},LDParam);
    
    %Concatenate along the vertical direction (1)
    LDCat = cat(1,LDCat,LD{p});
    
end

LDCat

%Calculate the weighting for each task
W = z3weight(LDCat);
%Now, determine the sequence by task
LDSeq = LDByTask(LD,TaskD);

%Now iterate over each task
for t=1:maxTask
    %This procedure calculate the remaining (not end of task) cluster centroids
    [ix C dis D] = kmeansWeight(LDSeq{t},W,k(t));
    %Concatenate centroids along the vertical direction (1)
    CCat = cat(1,CCat,C);
end

%Concatenate the centroids into a single matrix
C = CCat;

%This procedure calculates the end of task cluster centroids
EC = endTask(LD,TaskD);
%Now, append the end of task centroids to this matrix of centroids
C = cat(1,C,EC);
%The end of task clusters will be the last maxTask number of clusters
endCluster = (kTotal-maxTask+1):(kTotal);



%Write the centroids we have used for training to file because applying the
%k-means algorithm multiple times results in different centroid indices.
%This would lead to incorrect task classification.
o.write('Centroid',C);
%Write the weighting for each dimension of LD space
o.write('Weight',W);
%Also, write the end clusters to file such that we can determine when a
%task has been completed with success.
o.write('End',endCluster);





%Initialize the variable cluster
cluster = cell(1,procs);

%Now, using these centroids, determine the index of each point in LD-space
%such that we can determine the observations
%Go through all procedures again
for p=1:procs
    %Determine the cluster to which the point belongs (ie observation)
    cluster{p} = motionCluster(LD{p},C,W);
end

%Determine the sequence of motions for each procedure
%(procedure, taskCount (generic), point (cluster))
seqByProc = motionSequenceByProcedure(cluster,TaskD);
%And determine the sequence of motions for each task
%(task, taskCount (specific), point (cluster))
seqByTask = motionSequenceByTask(cluster,TaskD);
%Determine the sequence of motions for each task at each skill level
%(task, skill, taskCount (skill & task specific), point (cluster))
seqBySkill = motionSequenceBySkill(cluster,TaskD,Skill);
%Determine the sequence of tasks for each procedure
%(procedure, point (task))
taskSeq = taskSequenceConvert(TaskD);







%Now, for each task, we want to create a new markov model

%We have cleverly given the matrix containing the data a shape such that
%it can be easily read from the data as a smaller matrix for the given
%task
M = cell(1,maxTask);

for t=1:maxTask
    
    %Now we have the data for training the Markov Model, we will create a
    %Markov Model, train it, and then write to file
    %Create an initial Markov Model (with some guess of parameters, we will
    %choose a unifrom distribution)
    M{t} = MarkovModel(strcat( 'Inner',num2str(t) ),0,0,0);
    
    %Now, estimate the parameters of the model using the estimate function
    %Reshape our seq array such that all procedures are concatenated
    %together so that the training can handle the input
    M{t} = M{t}.estimate(seqByTask{t},seqByTask{t},ones(1,kTotal),zeros(kTotal),ones(kTotal));
    
    %And write this Markov Model to file
    M{t}.write();
    
end






%Now, to calculate the emission matrix the outer Markov Model, we should
%see what inner Markov Model best describes each task (observation) and the
%actual task (state) presumably the correspondence should be fairly strong
%(but not necessarily perfect)

%Go through each motion sequence and determine which Markov Model is most
%likely to have produced the motion sequence

%Initialize the task observation sequence to have the same size as the task
%sequence
taskObsSeq = cell(size(taskSeq));
%Initialize our maximum task count tn
tn = cell(1,procs);

%Go through each procedure
for p=1:procs
    %And for each task in the particular procedure, determine the number of
    %time steps within the task
    tn{p} = length(taskSeq{p});
    %Increment over all tasks
    for t=1:tn{p}
        %Determine which Markov Model is most likely to have produced the
        %motion sequence, noting that even though this is training, this will
        %not necessarily be perfectly correspondent
        taskObsSeq{p}(t)=bestMarkov(seqByProc{p}{t},M);
    end
end



%Ok, now we have the state sequence and observation sequence, we just need
%to estimate the Markov Model parameters now
MOut = MarkovModel('Outer',0,0,0);
MOut = MOut.estimate(taskObsSeq,taskSeq,Sense.getPi(),Sense.getA(),0);

%And write this estimation of parameters to file
MOut.write();






%Finally, we want to determine the Markov Models for each skill of
%procedure. We can do this in the exact same way as in the general task
%Markov Model, but now we have several different sets of them...

MSkill = cell(maxSkill,maxTask);

for s=1:maxSkill
    for t=1:maxTask
        
        %Now we have the data for training the Markov Model, we will create a
        %Markov Model, train it, and then write to file
        MSkill{s,t} = MarkovModel(strcat('Skill',num2str(s),'Task',num2str(t)),0,0,0);
        
        %Now, estimate the parameters of the model using the estimate function
        %Reshape our seq array such that all procedures are concatenated
        %together so that the training can handle the input
        MSkill{s,t} = MSkill{s,t}.estimate(seqBySkill{s,t},seqBySkill{s,t},ones(1,kTotal),zeros(kTotal),ones(kTotal));
        
        %And write this Markov Model to file
        MSkill{s,t}.write();
        
    end
end


%Indicate this function is complete
status=1;

