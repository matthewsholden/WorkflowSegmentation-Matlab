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
%Determine the clustering parameters
CP = PC.get('CP');
kTotal = sum(CP) + maxTask;
UserComp = o.read('UserComp');

%Initialize Cent to be an empty list of centroids
Cent = [];
%Create a list of centroids for each inidividual task
taskCent = cell(1,maxTask);

%Let's create an array of all of the LD points from all of the files
%Initialize the matrix such that we have something to concatenate nothing
DO_Cat = Data([],[],[],[]);
%A cell array of data objects to hold the concatenation of all instances of
%a particular task
DP_Task_Cat = cell(1,5);


%Preallocate the size of our cell array of orthogonally projected data
DO = cell(1,procs); DP = cell(1,procs); DC = cell(1,procs); DL = cell(1,procs);


%Get all of the orthogonally transformed points for each array
for p=1:procs
    %Find the orthogonal projection for each procedural record
    DO{p} = D{p}.orthogonal(PC.get('Orth'));
    %Concatenate along the data objects together
    DO_Cat = DO_Cat.concatenate(DO{p});
end

%Next, perform a principal component analysis on the concatenated data
[DP_Cat TransPCA Mn] = DO_Cat.principal(UserComp(1));
%Then, perform a class-dependent linear discriminant analysis on the
%concatenated data (hopefully our scatter matrices will be non-singular
%after the PCA)
[DL_Cat TransLDA W] = DP_Cat.linear(UserComp(2));

% figure;
%Transform the unconcatenated data using th tranformation from PCA
for p=1:procs
    %Perform the transformation for the principal component analysis
    %separately on each procedure
    DP{p} = DO{p}.pcaTransform(TransPCA,Mn);
    %And for the linear discriminant analysis
    %DL{p} = DP{p}.ldaTransformTask(TransLDA);
% 
%     hold on;
%     plot3(DL{p}.X(DL{p}.K==1,1),DL{p}.X(DL{p}.K==1,2),DL{p}.X(DL{p}.K==1,3),'.r')
%     plot3(DL{p}.X(DL{p}.K==2,1),DL{p}.X(DL{p}.K==2,2),DL{p}.X(DL{p}.K==2,3),'.b')
%     plot3(DL{p}.X(DL{p}.K==3,1),DL{p}.X(DL{p}.K==3,2),DL{p}.X(DL{p}.K==3,3),'.g')
%     plot3(DL{p}.X(DL{p}.K==4,1),DL{p}.X(DL{p}.K==4,2),DL{p}.X(DL{p}.K==4,3),'.y')
%     plot3(DL{p}.X(DL{p}.K==5,1),DL{p}.X(DL{p}.K==5,2),DL{p}.X(DL{p}.K==5,3),'.k')
%     hold off;
    
end

%Now, group the records by task, rather than as one big thing
DP_Task = motionSequenceByTask(DP);

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

%Calculate the weighting associated with the entire procedure.
%It seems that uniform weighting works the best...
W = ones(1,size(TransPCA,2));
%W

%Iterate over each task
for t=1:maxTask
%     figure
%     plot3(DL_Task_Cat{t}.X(:,1),DL_Task_Cat{t}.X(:,2),DL_Task_Cat{t}.X(:,3),'.')
    %For each task calculate the centroids using the w-means algorithm
    [~, taskCent{t}] = DP_Task_Cat{t}.wmeans(CP(t),W);
    %Concatenate with the list of centroids
    Cent = cat(1,Cent,taskCent{t});
end

%Calculate the centroids for the end of task
EC = endCent(DP_Cat);

%Concatenate all centroids into a single matrix
Cent = cat(1,Cent,EC);


%The end of task centroids will be numbered from (# of non-endTask
%centroids)-(kTotal)
End = (kTotal-maxTask+1):(kTotal);

%Write the centroids to file for clustering later
o.write('Cent',Cent);
%Write the weighting to each file associated with each dimension
o.write('Weight',W);
%Write the end cluster numbers to file to determine if a task is completed
o.write('End',End);
%Write the transformation for pca and lda to file
o.write('TransPCA',TransPCA);
o.writeCell('TransLDA',TransLDA);
%Write the mean of each dof to file for the pca or lda transformation
o.write('Mn',Mn);






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
DC_Skill = motionSequenceBySkill(DC);
%Recover the dofs from the cell array Data objects[T_Task X_Task K_Task S_Task] = DataCell(DC_Task);[T_Skill X_Skill K_Skill S_Skill] = DataCell(DC_Skill);%Determine the sequence of tasks for each procedure
%(procedure, point (task))
K_Task = taskSequenceConvert(DC);

%Convert to cell arrays of the data
[~, XC_Task] = DataCell(DC_Task);
[~, XC_Skill] = DataCell(DC_Skill);

%We must create the Inner Markov Models, the Outer Markov Model, and the
%Skill Markov Models

%For each task, create a Markov Model, using X_Task
MIn = cell(1,maxTask);

%Iterate over all tasks
for t=1:maxTask

    %Calculate the clusters corresponding to the current task
    currClust = 1 + sum(CP(1:t)) - CP(t) : sum(CP(1:t));
    
    %Estimate the parameters of the model using the estimate function.
    EstPi = ones(1,kTotal)/kTotal;
    EstPi(currClust) = ones(1,length(currClust));
    EstA = ones(kTotal)/kTotal;
    EstA(currClust,currClust) = ones(length(currClust));
    EstB = eye(kTotal) + ones(kTotal)/kTotal;
    
    %Now, normalize (of course)
    EstPi = normr(EstPi);   EstA = normr(EstA); EstB = normr(EstB);
    
    %Create an inner Markov Model, with the estimated parameters
    MIn{t} = MarkovModel(strcat( 'Inner',num2str(t) ),EstPi,EstA,EstB);
    
    %Ensure that no model is ruled out by an unlucky cluster, so ensure
    %that every model can produce every sequence with non-zero probability
    MIn{t} = MIn{t}.estimate(XC_Task{t},XC_Task{t},EstPi,EstA,EstB);
    
    %Write the Markov Model to file
    MIn{t}.write();
    
end


%We have the sequence of states. The sequence of observed states does not
%affect the segmentation, so we do not need to calculate them
MOut = MarkovModel('Outer',0,0,0);
MOut = MOut.estimate(K_Task,K_Task,[1 0 0 0 0],PC.get('Sense'),zeros(5));
%And write this estimation of parameters to file
MOut.write();


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

%Clear the objects now that we are done with itclear o;clear D;clear PC;clear MIn;clear MOut;clear MSkill;
%Indicate this function is complete
status=1;

