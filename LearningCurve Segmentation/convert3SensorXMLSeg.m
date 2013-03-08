%This function will take a directory of specified procedural recordings
%(recorded by fCal) and convert all of the mha files to xml files

%Parameter dirPath: The path with the specified subject folders

%Return status: Whether or not the conversion was successful
function status = convert3SensorXMLSeg(dirPath,subjName)

%Initialize the status to indicate incomplete
status = 0;

%Search the directory for all folders with subjects within
subjDir = dir([dirPath, '/', subjName, '*']);
numSubj = length(subjDir);

%The names of the relevant tools
toolNames = {'StylusTipToReference','StylusToNeedleBase'};
numTools = length(toolNames);

%Iterate over all subjects
for i = 1:numSubj
    
    %Get the mha contents of the directory of the current subject
    currSubjDir = dir([dirPath, '/', subjDir(i).name, '/*Parse.xml']);
    
    %Get the xlsx file contents of directory
    currSegDir = dir([dirPath, '/', subjDir(i).name, '/*xlsx']);
    
    %Skip this iteration if there is no segmentation file in directory
    if (isempty(currSegDir))
        continue;
    end%if
    
    %Iterate over all mha files for the current subject
    for j = 1:length(currSubjDir)

        %Get the full path of the xml file
        xmlPath = [ dirPath, '/', subjDir(i).name, '/' currSubjDir(j).name ];
        %Read the xml file
        D = AscTrackToData( xmlPath, toolNames);
        
        %Get the full path of the xlsx file
        currSegFile = [ dirPath, '/', subjDir(i).name, '/' currSegDir(1).name];
        %Read the xlsx file
        [transT transK] = readManSegLC( currSegFile, currSubjDir(j).name);
        %Get the inout segmentation of the
        seg = segToTaskData( D{1}.T, transT, transK);
        
        %Create a new cell array of Data objects with removed time stamps
        D_Rem = cell(size(D));
        
        %Remove any time stamps where the inout segmentation is zero
        for k=1:numTools
            %Remove the bad time stamps
            T_Rem = D{k}.T(seg~=0,:);
            X_Rem = D{k}.X(seg~=0,:);
            K_Rem = D{k}.K(seg~=0,:);
            %Create a Data object with good time stamps
            D_Rem{k} = Data(T_Rem,X_Rem,K_Rem,D{k}.S);
        end%for
        
        %Write the Data object to file
        DataToAscTrack( D_Rem, replaceExtension(xmlPath,'_Rem.xml'), toolNames);
        
    end%for
    
    
end%for

%Clear all of the variables
clearvars;

%Indicate the function has been successful
status = 1;