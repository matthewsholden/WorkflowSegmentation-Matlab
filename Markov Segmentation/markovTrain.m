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

%Read all procedural records from file (time, dofs, task, skill)
D = readRecord();
%Create a collection of parameters in which to store parameters
PC = ParameterCollection();

%The number of procedures is the length of the cell array D
procs = length(D);

%Determine the maximum task number and maximum skill level
maxTask = calcMax(D,'Task');
% maxSkill = calcMax(D,'Skill');

%Determine the total number of clusters we will have available
%Determine the clustering parameters
CP = PC.get('CP');
kTotal = sum(CP);

%The number of components specified by the user for PCA (0 => calculate it)
UserComp = PC.get('UserComp');

%Initialize Cent to be an empty list of centroids
Cent = [];
%Create a list of centroids for each inidividual task
taskCent = cell(1,maxTask);

%Initialize the matrix of concatenated, orthogonally transformed procedures
DO_Cat = Data([],[],[],[]);
%Hold the concatenation of all instances of a particular task (after PCA)
DP_Task_Cat = cell(1,5);

%Preallocate the size of our cell array of orthogonally projected data
DS = cell(1,procs);
DO = cell(1,procs);
DP = cell(1,procs);
DC = cell(1,procs);



%P1. Remove all outliers in the data

%Remove outliers from each procedure individually
for p=1:procs
    DS{p} = D{p}.replaceOutliers(PC.get('Outlier'));
end


%P2. Smooth the data by limiting the curvature

%Smooth each procedure individually
for p=1:procs
    DS{p} = DS{p}.smooth(PC.get('Accel'));
end
    



%1. Orthogonal Transformation

%Get all of the orthogonally transformed points for each array
for p=1:procs
    %Find the orthogonal projection for each procedural record
    DO{p} = D{p}.orthogonal(PC.get('Orth'));
    %Concatenate along the data objects together
    DO_Cat = DO_Cat.concatenate(DO{p});
end


%2. Calculate Principal Component Analysis

%Next, perform a principal component analysis on the concatenated data
[DP_Cat TransPCA Mn] = DO_Cat.principal(UserComp(1));


%3. Apply calculated Principal Component Analysis

%Transform the unconcatenated data using the tranformation from PCA
for p=1:procs
    %Perform the transformation for the principal component analysis
    %separately on each procedure
    DP{p} = DO{p}.pcaTransform(TransPCA,Mn);
end


%4. Group the procedures into cells by task

%Now, group the records by task, rather than as one big thing
DP_Task = motionSequenceByTask(DP);


%5. Concatenate all groups of the same task together, to obtain one cell
%for each task (over all procedures)

%Concatenate all instances of each task together
for t=1:maxTask
    %Create the blank data object
    DP_Task_Cat{t} = Data([],[],[],[]);
    %Iterate over all instances of the task
    for i = 1:length(DP_Task{t})
        %Concatenate this particular instance with all previous instances
        DP_Task_Cat{t} = DP_Task_Cat{t}.concatenate(DP_Task{t}{i});
    end
end


%6. Perform clustering for each task separately

%Uniform weighting for each DOF appears to work best
W = ones(1,size(TransPCA,2));

%Iterate over each task
for t=1:maxTask
    %For each task calculate the centroids using the w-means algorithm
    [~, taskCent{t}] = DP_Task_Cat{t}.wmeans(CP(t),W);
    %Concatenate with the list of centroids
    Cent = cat(1,Cent,taskCent{t});
end


%7. Write the data we have collected to file

%Write the centroids to file for clustering later
o.write('Cent',Cent);
%Write the weighting to each file associated with each dimension
o.write('Weight',W);
%Write the transformation for pca and lda to file
o.write('TransPCA',TransPCA);
% o.writeCell('TransLDA',TransLDA);
%Write the mean of each dof to file for the pca or lda transformation
o.write('Mn',Mn);


%8. Perform clustering for each procedure, using the calculated cluster
%centroids

%Now, using the centroids, determine the index of each projected point
%Go through all procedures again
for p=1:procs
    %Determine the cluster to which the point belongs (ie observation)
    DC{p} = DP{p}.findCluster(Cent,W);
end









%And determine the sequence of motions for each task
%(task, taskCount (specific), point (cluster))
DC_Task = motionSequenceByTask(DC);

%Determine the sequence of motions for each task at each skill level
%(task, skill, taskCount (skill & task specific), point (cluster))
% DC_Skill = motionSequenceBySkill(DC);

%Recover the dofs from the cell array Data objects
[TC_Task XC_Task KC_Task SC_Task] = DataCell(DC_Task);
% [TC_Skill XC_Skill KC_Skill SC_Skill] = DataCell(DC_Skill);

%Determine the sequence of tasks for each procedure (procedure, point (task))
K_Task = taskSequenceConvert(DC);


%For each task, create a Markov Model
MTask = cell(1,maxTask);

%Iterate over all tasks
for t=1:maxTask
    
    %Calculate the clusters corresponding to the current task
    currClust = 1 + sum(CP(1:t)) - CP(t) : sum(CP(1:t));
    
    %Initialize the parameters of the model
    EstPi = ones(1,kTotal)/kTotal;
    EstPi(currClust) = ones(1,length(currClust));
    
    EstA = ones(kTotal)/kTotal;
    EstA(currClust,currClust) = ones(length(currClust));
    
    EstB = eye(kTotal) + ones(kTotal)/kTotal;
    
    %Now, normalize the parameters (as required by Markov Models)
    EstPi = normr(EstPi);
    EstA = normr(EstA);
    EstB = normr(EstB);
    
    %Create an inner Markov Model, with the estimated parameters
    MTask{t} = MarkovModel(strcat('Task',num2str(t)),EstPi,EstA,EstB);
    
    %Ensure that no model is ruled out by an unlucky cluster, so ensure
    %that every model can produce every sequence with non-zero probability
    MTask{t} = MTask{t}.estimate(XC_Task{t},XC_Task{t},EstPi,EstA,EstB);
    
    %Write the Markov Model to file
    MTask{t}.write();
    
end


%Create the Procedure Markov Model to govern transitions between tasks
MProc = MarkovModel('Proc',0,0,0);

%Initialize the parameters for the procedure Markov Model
%Always start in task 1
EstPi = zeros(1,maxTask);
EstPi(1) = 1;

%Assume that the sensible tasks are most likely to occur
EstA = PC.get('Sense');

%Use the same model of misclassification as the Task Markov Models
EstB = eye(maxTask) + ones(maxTask)/maxTask;

%Now, normalize the parameters (as required by Markov Models)
EstPi = normr(EstPi);
EstA = normr(EstA);
EstB = normr(EstB);

%Ensure this model can produce every sequence with non-zero probability
MProc = MProc.estimate(K_Task,K_Task,EstPi,EstA,EstB);

%And write this estimation of parameters to file
MProc.write();









% %For each skill on each task, create a Markov Model, using X_Skill
% MSkill = cell(maxSkill,maxTask);
%
% %Iterate over all skill-levels
% for s=1:maxSkill
%     %Iterate over all tasks
%     for t=1:maxTask
%         %Create a blank skill Markov Model, specifying only the name
%         MSkill{s,t} = MarkovModel(strcat('Skill',num2str(s),'Task',num2str(t)),0,0,0);
%         %Estimate the parameters of the model using the estimate function.
%         %Ensure that no model is ruled out by an unlucky cluster, so ensure
%         %that every model can produce every sequence with non-zero probability
%         MSkill{s,t} = MSkill{s,t}.train(XC_Skill{s,t},XC_Skill{s,t},indexMember(XC_Skill{t},kTotal),zeros(kTotal),ones(kTotal)/kTotal);
%         %And write this Markov Model to file
%         MSkill{s,t}.write();
%     end
% end




%Clear the objects now that we are done with it
clear o; clear D; clear PC; clear MTask; clear MProc;
% clear MSkill;
%Indicate this function is complete
status=1;

