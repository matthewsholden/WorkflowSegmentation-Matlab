%This function will take a directory of specified procedural recordings
%(recorded by fCal) and convert all of the mha files to xml files

%Parameter dirPath: The path with the specified subject folders

%Return status: Whether or not the conversion was successful
function status = convert3SensorXMLFilter(dirPath,subjName)

%Initialize the status to indicate incomplete
status = 0;

%Search the directory for all folders with subjects within
subjDir = dir([dirPath, '/', subjName, '*']);
numSubj = length(subjDir);

%The names of the relevant tools
toolNames = {'StylusTipToReference'};
numTools = length(toolNames);

%Iterate over all subjects
for i = 1:numSubj
    
    %Get the mha contents of the directory of the current subject
    currSubjDir = dir([dirPath, '/', subjDir(i).name, '/*Parse.xml']);
    
    %Iterate over all mha files for the current subject
    for j = 1:length(currSubjDir)

        %Get the full path of the xml file
        xmlPath = [ dirPath, '/', subjDir(i).name, '/' currSubjDir(j).name ];
        %Read the xml file
        D = AscTrackToData( xmlPath, toolNames);
        
        %Create a new cell array of Data objects with filtered trajectories
        D_Filter = cell(size(D));
        
        %Remove any time stamps where the inout segmentation is zero
        for k=1:numTools
            D_Filter{k} = D{k}.movingAverage( 0.3, 'Gaussian' );
        end%for
        
        %Write the Data object to file
        DataToAscTrack( D_Filter, replaceExtension(xmlPath,'_Filter.xml'), toolNames);
        
    end%for
    
    
end%for

%Clear all of the variables
clearvars;

%Indicate the function has been successful
status = 1;