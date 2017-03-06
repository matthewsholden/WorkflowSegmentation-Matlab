%Segment the procedures from the LP procedures using the automatic
%segmentation algorithm

%Parameter skill: A string indicating skill (ie TrialControl, PracticeVR)
%Parameter procName: The name of the procedure (ie L3-4, L4-5)

%Return acc: The accuracy of the task segmentation for each procedure
%Return D_Test: A cell array of the automatically segmented procedures
function [acc D_Test] = segmentLumbarType(skill,technique)

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
D_Train = cell(subjNum-1,subjNum);


%Determine if the procedures are practices or trials
if ( ~~strfind( skill, 'Trial' ) )
    pracTri = 'Trial';
else
    pracTri = 'Practice';
end%if


%Get a Data object for each procedure
toolNames = {'Tool_1'};
for i=1:subjNum
    disp( [ 'Subject: ', num2str( subjArray(i) ) ] );
    Sty_Ref = AscTrackToDataTask(subjArray(i),[pracTri,num2str(trialArray(i))],skill,technique,toolNames);
    StyTip_RAS = Sty_Ref{1}.calibration( o.read('ReferenceToRAS'), o.read('StylusTipToStylus') );
    D{i} = StyTip_RAS;
end%for

%disp('Data read from file');

%Create a set of training procedures
onlyTrain = ~eye(subjNum);
for i=1:subjNum
    D_Test{i} = Data( D{i}.T, D{i}.X, zeros(size(D{i}.K)), D{i}.S );
    D_Train(:,i) = D(onlyTrain(:,i));    
end%for

%disp('Data organized into training & testing sets');

%Initialize the vector of task segmentation accuracies
acc = zeros(1,subjNum);

%Iterate over all subjects (leave-one-out method)
for subj = 7:subjNum
    
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
