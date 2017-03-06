%Segment the procedures from the epidural procedures using the automatic
%segmentation algorithm

%Parameter skill: A string indicating skill (ie Novice, Expert)
%Parameter technique: The name of the procedure (ie TR, TL, CR, CL)

%Return acc: The accuracy of the task segmentation for each procedure
%Return D_Test: The automatically segmented procedures
function ConvertEpiduralData(skill,technique)

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


%Get a Data object for each procedure
for i=1:subjNum
    [Sty_Tr, ~, Ref_Tr] = NDITrackToDataTask(subjArray(i),['Trial',num2str(trialArray(i))],skill,technique);
    Sty_Ref = Ref_Tr.relative( Sty_Tr, true, false);
    Sty_Ent = Sty_Ref.calibration( o.read('ReferenceToEntry'), o.read('Identity') );
    
    D{i} = Sty_Ent;
    

    o = Organizer();
    procPath = o.pathName{o.search('Subject')};
    procPath = [o.rootPath, '/', procPath];
    subjStr = num2str( subjArray(i) );
    procPath = [procPath, '/', skill, '/', 'Subject ', subjStr];   
    procName = ['Subject ', subjStr, ' - Trial', num2str( trialArray( i ) ), ' - ', technique];
    procFile = [procPath, '/', procName, '.xml']
    
    DataToAscTrack( { Sty_Ent }, procFile, { 'StylusToEntry' } );
end%for

%disp('Data read from file');