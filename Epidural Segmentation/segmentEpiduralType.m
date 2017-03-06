%Segment the procedures from the epidural procedures using the automatic
%segmentation algorithm

%Parameter skill: A string indicating skill (ie Novice, Expert)
%Parameter procName: The name of the procedure (ie TR, TL, CR, CL)

%Return acc: The accuracy of the task segmentation for each procedure
%Return D_Test: The automatically segmented procedures
function [acc D_Test] = segmentEpiduralType(skill,technique)

TRAIN_SET_SIZE = 34;
%create an organizer object for reading/writing files
o = Organizer();

%Get the segmentation subjects and trials
procMatrix = o.read([skill, ' ', technique]);
trialMatrix = procMatrix(:,2:end)';
subjMatrix = bsxfun(@times,~~trialMatrix,procMatrix(:,1)');

%Convert these into appropriate arrays
trialArray = trialMatrix(~~trialMatrix);
subjArray = subjMatrix(~~subjMatrix);
subjNum = length(subjArray);


%Create a cell array of procedural data objects
D = cell(1,subjNum);
D_Test = cell(1,subjNum);
D_Train = cell(TRAIN_SET_SIZE,subjNum);


%Get a Data object for each procedure
for i=1:subjNum
    [Sty_Tr, ~, Ref_Tr] = NDITrackToDataTask(subjArray(i),['Trial',num2str(trialArray(i))],skill,technique);
    Sty_Ref = Ref_Tr.relative( Sty_Tr, true, false);
    Sty_Ent = Sty_Ref.calibration( o.read('ReferenceToEntry'), o.read('Identity') );
    D{i} = Sty_Ent;
end%for

%disp('Data read from file');

%Create a set of training procedures
onlyTrain = zeros( subjNum );
for i = 1:subjNum
    for j = 1:subjNum
        if ( j <= TRAIN_SET_SIZE )
            onlyTrain( i, mod( i + j - 1, subjNum ) + 1 ) = 1;
        end
    end
end
onlyTrain = ~~onlyTrain;

for i=1:subjNum
    D_Test{i} = Data( D{i}.T, D{i}.X, zeros(size(D{i}.K)), D{i}.S );
    D_Train(:,i) = D(onlyTrain(:,i));
end%for

%disp('Data organized into training & testing sets');

%Initialize the vector of task segmentation accuracies
acc = zeros(1,subjNum);

%Iterate over all subjects (leave-one-out method)
for subj = 1:subjNum
    
    %Now, train the Markov model algorithm
    markovTrain( D_Train(:,subj) );
    
    %disp('Algorithm trained');
    
    %Perform a Markov Model task segmentation on the test procedure
    MD = markovSegment( D_Test{subj} );
    
    %disp('Procedure segmented');
    
    %Calculate the accuracy of the task segmentation
    [segAcc, ~, ~, accDTW, ssod, n] = segmentAccuracy(D{subj}.K,MD.DK.X);
    %Add the automatic segmentation to the test data
    D_Test{subj} = Data( D_Test{subj}.T, D_Test{subj}.X, MD.DK.X, D_Test{subj}.S );
    
    %Write the accuracy to screen, and store it in vector
    disp(['Subject ', num2str(subjArray(subj)), ': ', num2str(segAcc), ' DTW: ', num2str(accDTW), ' SSOD: ', num2str(ssod), ' n: ', num2str(n) ]);
    acc(subj) = segAcc;
    
    %Clear the MarkovData object
    clear MD;
    
end%for

%Clear the organizer object
clear o;
