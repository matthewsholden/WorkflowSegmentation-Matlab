%This function will retrieve a list of procedures from file and from these
%procedures train a Markov Model which will be used to segment and classify
%further procedures performed

%Return status: Whether or not the procedure completed successfully
function status = markovTrainLDA()

%Indicate that the procedure is not finished
status = 0;

%Organizer for writing data to file
o = Organizer();
%Create a parameter collection to store parameters
PC = ParameterCollection();

%Read all procedural records from file
D = readRecord();
%The number of procedures is the length of the cell array D
numProc = length(D);

%Determine the maximum task number
maxTask = calcMax(D,'Task');

%Determine the number of clusters for each task and total
centCount = PC.get('NumCentroids');

%Empty list of clustering centroids
Centroids = [];
%Cell array of centroids for each task
taskCent = cell(1,maxTask);

%Initialize the matrix of concatenated, orthogonally transformed procedures
DO_Cat = Data([],[],[],[]);
%Hold the concatenation of all instances of a particular task (after PCA)
DO_Task_Cat = cell(1,5);

%Preallocate cell arrays of transformed data
DS = cell(1,numProc);
DV = cell(1,numProc);
DO = cell(1,numProc);
DL = cell(1,numProc);
DC = cell(1,numProc);



%0. Smooth/Remove outliers using filtering
for p=1:numProc
    DS{p} = D{p}.movingAverage(PC.get('Average'),'HalfGauss');
end


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
end%for


%2. Group the procedures into cells by task
DO_Task = byTask(DO);
%DO_Task{task}{count}


%3. Concatenate all groups of same task together
for t=1:maxTask
    %Create the blank data object
    DO_Task_Cat{t} = Data([],[],[],[]);
    %Iterate over all instances of the task
    for i = 1:length(DO_Task{t})
        DO_Task_Cat{t} = DO_Task_Cat{t}.concatenate(DO_Task{t}{i});
    end%for
end%for


%4. Perform the linear discriminant analysis
[DL_Task_Cat Trans] = DO_Cat.lda(DO_Task_Cat);

clf; figure; hold on;
clr = {'r','g','b','y','k'};
for t=1:maxTask
    plot3(DL_Task_Cat{t}.X(:,1),DL_Task_Cat{t}.X(:,2),DL_Task_Cat{t}.X(:,3),'.','MarkerEdgeColor',clr{t});
end%for


%7. Perform clustering for each task separately
for t=1:maxTask
    %Calculate the dimensional weighting
    W = ones(1,size(Trans,2));
    %For each task calculate the centroids using the w-means algorithm
    [~, taskCent{t}] = DL_Task_Cat{t}.wmeans(centCount(t),W);
    %Concatenate with the list of centroids
    Centroids = cat(1,Centroids,taskCent{t});
end%for


%8. Write the data we have collected to file
o.write('Centroids',Centroids);
o.write('Weight',W);
%Convert the cell array of class-dependent lda transforms to a 3D matrix
o.write('Trans',Trans);


%3. Apply calculated Linear Discriminant Analysis
for p=1:numProc
    DL{p} = DO{p}.ldaTransform(Trans);
end%for


%9. Perform clustering for each procedure, using cluster centroids
for p=1:numProc
    %Determine the cluster to which the point belongs (ie observation)
    DC{p} = DL{p}.findCluster(Centroids,W);
end%for


%10. Recover the dofs from the cell array Data objects
[~, XC, KC, ~] = DataCell(DC);


%11. Estimate the initial state vector
EstPi = zeros(1,maxTask);
EstPi(1) = 1;   %Always start in task 1


%12. Estimate the task transition matrix
EstA = PC.get('Sense');


%13. Estimate the observation probability matrix
EstB = ones(maxTask,sum(centCount))/maxTask;


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

