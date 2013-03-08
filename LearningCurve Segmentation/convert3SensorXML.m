%This function will take a directory of specified procedural recordings
%(recorded by fCal) and convert all of the mha files to xml files

%Parameter dirPath: The path with the specified subject folders
%Parameter subjName: The name of the subject folders to look in

%Return status: Whether or not the conversion was successful
function status = convert3SensorXML(dirPath,subjName)

%Initialize the status to indicate incomplete
status = 0;

%Search the directory for all folders with subjects within
subjDir = dir([dirPath, '/', subjName, '*']);
numSubj = length(subjDir);

%Iterate over all subjects
for i = 1:numSubj
    
    %Get the mha contents of the directory of the current subject
    currSubjDir = dir([dirPath, '/', subjDir(i).name, '/*mha']);
    
    %Iterate over all mha files for the current subject
    for j = 1:length(currSubjDir)
        
        %Get the full path of the mha file
        mhaPath = [ dirPath, '/', subjDir(i).name, '/' currSubjDir(j).name ];
        %Convert the mha file to xml
        fCalTrackToAscTrack3Sensor( mhaPath, replaceExtension(mhaPath,'_Parse.xml') ); 
        
    end%for
    
    
end%for

%Indicate the function has been successful
status = 1;