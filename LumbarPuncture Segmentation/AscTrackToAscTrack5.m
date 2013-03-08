%This function will take a procedural record, and fiveplicate each of the
%time stamps (for the PerkProcedureEvaluator)

%Parameter filePath: The name of the directory to fiveplicate
%Paramter subjName: The name of the subject to read from file

%Return status: Whether or not the funciton has succeeded
function status = AscTrackToAscTrack5(dirPath,subjName)

%Initialize the status to indicate incomplete
status = 0;

%Search the directory for all folders with subjects within
subjDir = dir([dirPath, '/', subjName, '*']);
numSubj = length(subjDir);

%Iterate over all subjects
for i = 1:numSubj
    
    %Get the xml contents of the directory of the current subject
    currSubjDir = dir([dirPath, '/', subjDir(i).name, '/*xml']);
    
    %Iterate over all mha files for the current subject
    for j = 1:length(currSubjDir)
        
        %Get the full path of the mha file
        xmlPath = [ dirPath, '/', subjDir(i).name, '/' currSubjDir(j).name ];
        %Convert the mha file to xml
        D = AscTrackToData( xmlPath, {'Tool_1'} );
        DataToAscTrack5( D, replaceExtension(xmlPath,'_Five.xml'), {'Tool_1'} ); 
        
    end%for
    
    
end%for

%Indicate the function has been successful
status = 1;