%Given a cell array of training data objects, this function will train the
%task segmentation algorithm

%Parameter D_Train: A cell array of training data objects

%Return status: Whether or not the procedure completed successfully
function status = markovTrainAllClust(D_Train)

%Indicate that the procedure is not finished
status = 0;

%Organizer for writing data to file
o = Organizer();
%Create a parameter collection to store parameters
PC = ParameterCollection();

%The number of procedures is the length of the cell array D
numProc = length(D_Train);

%Determine the maximum task number
maxTask = calcMax(D_Train,'Task');

%Determine the number of clusters for each task and total
centCount = PC.get('NumCentroids');

%Empty list of clustering centroids
Centroids = [];
Clout = [];
%Cell array of centroids for each task
taskCent = cell(1,maxTask);
taskClout = cell(1,maxTask);

%Initialize the matrix of concatenated, orthogonally transformed procedures
DO_Cat = Data([],[],[],[]);
DP_Cat = Data([],[],[],[]);
%Hold the concatenation of all instances of a particular task (after PCA)
DP_Task_Cat = cell(1,maxTask);

%Preallocate cell arrays of transformed data
DS = cell(1,numProc);
DV = cell(1,numProc);
DO = cell(1,numProc);
DP = cell(1,numProc);
DC = cell(1,numProc);



%0. Smooth/Remove outliers using filtering
for p=1:numProc
    DS{p} = D_Train{p}.movingAverage(PC.get('Average'),'Gaussian');
end%for


%Add the velocities to the Data
for p=1:numProc
    %Initialize empty data with velocity object
    DV{p} = DS{p};
    %Iterate over all derivatives up to specified order
    for d=1:PC.get('Derivative')
        DV{p} = DV{p}.concatenateDOF( DS{p}.derivative(d) );
    end%for
end%for


%1. Orthogonal Transformation
for p=1:numProc
    DO{p} = DV{p}.orthogonal(PC.get('Orthogonal'));
    %Concatenate along the data objects together
    DO_Cat = DO_Cat.concatenate(DO{p});
end%for


%2. Principal Component Analysis
[~, TransPCA MeanPCA] = DO_Cat.pca(PC.get('NumComponents'));


%3. Apply calculated Principal Component Analysis
for p=1:numProc
    DP{p} = DO{p}.pcaTransform(TransPCA,MeanPCA);
end%for


%4. Group the procedures into cells by task
DP_Task = byTask(DP);
%DP_Task{task}{count}


%5. Concatenate all groups of same task together
for t=1:maxTask
    %Create the blank data object
    DP_Task_Cat{t} = Data([],[],[],[]);
    %Iterate over all instances of the task
    for i = 1:length(DP_Task{t})
        DP_Task_Cat{t} = DP_Task_Cat{t}.concatenate(DP_Task{t}{i});
    end%for
end%for


%6. Calculate weighting for each dimension in clustering
[~, XP_Task_Cat] = DataCell(DP_Task_Cat);
W = classScatterWeight(XP_Task_Cat);


%7. Perform task clustering as a whole for all tasks
for t=1:maxTask
    DP_Cat = DP_Cat.concatenate( DP_Task_Cat{t} );
end%for
%For each task calculate the centroids using the w-means algorithm
[~, Centroids, ~, ~, Clout] = DP_Cat.fwdkmeans( sum( centCount ),W);


%8. Write the data we have collected to file
o.write('Centroids',Centroids);
o.write('Weight',W);
o.write('Clout',Clout);
o.write('TransPCA',TransPCA);
o.write('MeanPCA',MeanPCA);


%9. Perform clustering for each procedure, using cluster centroids
for p=1:numProc
    %Determine the cluster to which the point belongs (ie observation)
    DC{p} = DP{p}.findCluster(Centroids,W,Clout);
end%for


%10. Recover the dofs from the cell array Data objects
[~, XC, KC, ~] = DataCell(DC);


%11. Estimate the initial state vector
EstPi = zeros(1,maxTask);
EstPi(1) = 1;   %Always start in task 1


%12. Estimate the task transition matrix
EstA = PC.get('Sense');


%13. Estimate the observation probability matrix
EstB = ones( maxTask, sum( centCount ) ) / maxTask;


%14. Ensure that all of the matrices are normalized (required by MMs)
EstPi = normr(EstPi);
EstA = normr(EstA);
EstB = normr(EstB);


%15. Estimate the Markov Model using the estimates of matrices
MProc = MarkovModel('Markov',0,0,0);
MProc = MProc.estimate(XC,KC,EstPi,EstA,EstB);
MProc.write();


%Clear the objects now that we are done with it
clear o;
clear D;
clear PC;
clear MProc;

%Indicate this function is complete
status = 1;

