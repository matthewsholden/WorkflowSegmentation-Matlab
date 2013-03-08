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

%Create an organizer to write data to file
o = Organizer();

%Read the procedural record from file (time, dofs, task, skill)
D = readRecord();
%Create a collection of parameters in which to store parameters
PC = ParameterCollection();





%Ok, so the array of times shall only be one dimensional
procs = length(D);
%Now, determine the maximum task number for future reference and the
%maximum skill level
maxTask = calcMax(D,'Task');
maxSkill = calcMax(D,'Skill');
%Determine the total number of clusters we will have available
kTotal = sum(PC.get('K')) + maxTask;


%Let's create an array of all of the LD points from all of the files
%Initialize the matrix such that we have something to concatenate nothing
%with
DO_Cat = Data([],[],[],[]);

%Preallocate the size of our cell array of orthogonally projected data
DO = cell(1,procs);


%Get all of the orthogonally transformed points for each array
for p=1:procs
    %Find the orthogonal projection for each procedural record
    DO{p} = D{p}.orthogonal(PC.get('Orth'));
    %Concatenate along the data objects together
    DO_Cat = DO_Cat.concatenate(DO{p});
end

%Next, perform a principal component analysis on the concatenated data
[DP_Cat Trans Mn] = DO_Cat.principal();

%Perform a wmeans clustering using the z3 weighting for each dimension, as
%specified by the wmeans method on a Data object
[DC_Cat C EC W] = DP_Cat.wmeans( sum(PC.get('K')) );

%Concatenate all centroids into a single matrix
Cent = cat(1,C,EC);

%The end of task centroids will be numbered from (# of non-endTask
%centroids)-(kTotal)
End = (kTotal-maxTask+1):(kTotal);

%Write the centroids to file for clustering later
o.write('Cent',Cent);
%Write the weighting to each file associated with each dimension
o.write('Weight',W);
%Write the end cluster numbers to file to determine if a task is completed
o.write('End',End);
%Write the transformation for pca to file
o.write('Trans',Trans);
%Write the mean of each dof to file for the pca transformation
o.write('Mn',Mn);





%Initialize the variable storing the pca data and clustering record
DP = cell(1,procs);     DC = cell(1,procs);

%Now, using the centroids, determine the index of each projected point
%Go through all procedures again
for p=1:procs
    %Perform the transformation for the principal component analysis
    %separately on each procedure. The clever mulitplication in the first
    %parameter turns a vector into a matrix with each row equal to the row
    %vector we started with
    DP{p} = DO{p}.transform( -ones(size(DO{p}.X,1),1) * Mn , Trans);
    
    %Determine the cluster to which the point belongs (ie observation)
    DC{p} = DP{p}.findCluster(Cent,W);

end



%And determine the sequence of motions for each task
%(task, taskCount (specific), point (cluster))
X_Task = motionSequenceByTask(DC);
%Determine the sequence of motions for each task at each skill level
%(task, skill, taskCount (skill & task specific), point (cluster))
X_Skill = motionSequenceBySkill(DC);
%Determine the sequence of tasks for each procedure
%(procedure, point (task))
K_Task = taskSequenceConvert(DC);


%We must create the Inner Markov Models, the Outer Markov Model, and the
%Skill Markov Models

%For each task, create a Markov Model, using X_Task
MIn = cell(1,maxTask);

%Iterate over all tasks
for t=1:maxTask
    %Create a blank Inner Markov Model, specifying only the name
    MIn{t} = MarkovModel(strcat( 'Inner',num2str(t) ),0,0,0);
    %Estimate the parameters of the model using the estimate function.
    %Ensure that no model is ruled out by an unlucky cluster, so ensure
    %that every model can produce every sequence with non-zero probability
    MIn{t} = MIn{t}.estimate(X_Task{t},X_Task{t},ones(1,kTotal),zeros(kTotal),ones(kTotal));
    %Write the Markov Model to file
    MIn{t}.write();
end


%We have the sequence of states. The sequence of observed states does not
%affect the segmentation, so we do not need to calculate them
MOut = MarkovModel('Outer',0,0,0);
MOut = MOut.estimate(K_Task,K_Task,[1 0 0 0 0],PC.get('Sense'),zeros(5));
%And write this estimation of parameters to file
MOut.write();



%For each skill on each task, create a Markov Model, using X_Skill
MSkill = cell(maxSkill,maxTask);

%Iterate over all skill-levels
for s=1:maxSkill
    %Iterate over all tasks
    for t=1:maxTask
        %Create a blank skill Markov Model, specifying only the name
        MSkill{s,t} = MarkovModel(strcat('Skill',num2str(s),'Task',num2str(t)),0,0,0);
        %Estimate the parameters of the model using the estimate function.
        %Ensure that no model is ruled out by an unlucky cluster, so ensure
        %that every model can produce every sequence with non-zero probability
        MSkill{s,t} = MSkill{s,t}.estimate(X_Skill{s,t},X_Skill{s,t},ones(1,kTotal),zeros(kTotal),ones(kTotal));
        %And write this Markov Model to file
        MSkill{s,t}.write();
    end
end


%Indicate this function is complete
status=1;

