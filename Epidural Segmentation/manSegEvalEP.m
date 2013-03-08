%This function will evaluate the accuracy with which a procedure has been
%manually segmented relative to a ground-truth manual segmentation

%Parameter fileName: The name of the file with test manual segmentations
%Parameter skill: The skill level of the users
%Parameter technique: The procedural technique the user is performing

%Return acc: Matrix of manual segmentation accuracies
function acc = manSegEvalEP(fileName, skill, technique)

%Create an organizer object for reading/writing files
o = Organizer();

if (nargin < 2)
    skill = {'Novice','Novice','Expert','Expert'};
elseif ( ~iscell(skill) )
    skill = {skill};
end%if

if (nargin < 3)
    technique = {'CR','CL','CR','CL'};
elseif ( ~iscell(technique) )
    technique = {technique};
end%if


acc = [];
%Iterate over all skills/techniques
for st = 1:length(skill)
    
    %Get the segmentation subjects and trials
    procMatrix = o.read([skill{st}, ' ', technique{st}]);
    trialMatrix = procMatrix(:,2:end)';
    subjMatrix = bsxfun(@times,~~trialMatrix,procMatrix(:,1)');
    
    %Convert these into appropriate arrays
    trialArray = trialMatrix(~~trialMatrix);
    subjArray = subjMatrix(~~subjMatrix);
    subjNum = length(subjArray);
    

    %Create a cell array of procedural data objects
    D = cell(1,subjNum);
    
    %Get a Data object for each procedure
    for i=1:subjNum
        %Get a tool transform Data object so we have the time stamps
        DT = NDITrackToDataNoTask(subjArray(i),['Trial',num2str(trialArray(i))],skill{st},technique{st});
        
        %Find the file with the ground-truth manual segmentation
        [~, segFile] = findDataEP( subjArray(i), [ 'Trial', num2str(trialArray(i)) ], skill{st}, technique{st} );
        %Read the manual segmentation from file
        [transT transK] = readManSegEP( segFile, [ 'Trial', num2str(trialArray(i)) ] );
        %Convert the manual segmentation into time stamps
        trueTask = segToTaskData( DT.T, transT, transK );
        
        %Now, read the manual segmentation from the Excel file
        Data = xlsread(fileName);
        %Consider only the data of the appropriate procedure (given the position)
        transT = Data( : , 2 * i );
        transK = Data( : , 2 * i - 1 );
        %Chop off NaNs associated with different procedures having more transitions
        chop = ~isnan(transT);
        transT = transT(chop);
        transK = transK(chop);
        %Convert the manual segmentation into time stamps
        segTask = segToTaskData( DT.T, transT, transK );
        
        [currAcc, ~, ~, AccDTW, AccMMD] = segmentAccuracy( trueTask, segTask );
        
        %Output the accuracy of manual segmentation
        disp( [ 'Subject Number: ', num2str( subjArray(i) ) ] );
        disp( [ 'Trial: Trial', num2str( trialArray(i) ) ] );
        disp( [ 'Skill: ', skill{st} ] );
        disp( [ 'Technique: ', technique{st} ] );
        disp( [ 'Accuracy: ', num2str( currAcc ) ] );
        disp( [ 'DTW Accuracy: ', num2str( AccDTW ) ] );
        disp( [ 'MMD Accuracy: ', num2str( AccMMD ) ] );
        
        acc = cat( 1, acc, currAcc);
    end%for
    
end%for