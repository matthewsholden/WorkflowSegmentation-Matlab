%This function will guide a user through a manual segmentation

function status = manSegGuideEP()

%Enter task segmentation in the form:

% Subject Number
% Trial
% Skill
% Technique
% TaskLabel             StartTime

%For Example:

% 201
% Trial1
% Novice
% CL
% 1         0.05
% 2         9.65
% 3         11.55
% 4         16.75
% 5         19.40
% End       23.60

%The subject number, trial, skill, technique will automatically be outputted
%for each procedure

%Create an organizer object for reading/writing files
o = Organizer();

skill = {'Novice','Novice','Expert','Expert'};
technique = {'CR','CL','CR','CL'};

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
        [Sty_Tr, ~, Ref_Tr] = NDITrackToDataNoTask(subjArray(i),['Trial',num2str(trialArray(i))],skill{st},technique{st});
        Sty_Ref = Ref_Tr.relative( Sty_Tr, true, false);
        Sty_Ent = Sty_Ref.calibration( o.read('ReferenceToEntry'), o.read('Identity') );
        D{i} = Sty_Ent;
    end%for
    
    %Iterate over all procedures and navigate
    for i = 1:subjNum
        disp( [ 'Subject Number: ', num2str( subjArray(i) ) ] );
        disp( [ 'Trial: Trial', num2str( trialArray(i) ) ] );
        disp( [ 'Skill: ', skill{st} ] );
        disp( [ 'Technique: ', technique{st} ] );
        navigateData( D{i} );
    end%for
    
end%for