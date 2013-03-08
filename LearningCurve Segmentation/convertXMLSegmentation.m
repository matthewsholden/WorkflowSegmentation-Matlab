%This function will take a directory of specified procedural recordings
%(recorded by fCal) and convert all of the mha files to xml files

%Parameter dirPath: The path with the specified subject folders

%Return status: Whether or not the conversion was successful
function status = convertXMLSegmentation(dirPath)

%Initialize the status to indicate incomplete
status = 0;

%Create an organizer to deal with the procedure files
o = Organizer();

%Search the directory for all folders with subjects within
subjDir = dir([dirPath, '/Subject*']);
numSubj = length(subjDir);

%The names of the relevant tools
toolNames = {'StylusTipToReference','StylusToNeedleBase'};
numTools = length(toolNames);
procNum = {1,2};

%Iterate over all subjects
for i = 1:numSubj
    
    %Get the mha contents of the directory of the current subject
    currSubjDir = dir([dirPath, '/', subjDir(i).name, '/*xml']);
    
    %Get the xlsx file contents of directory
    currSegDir = dir([dirPath, '/', subjDir(i).name, '/*xlsx']);
    
    %Iterate over all mha files for the current subject
    for j = 1:length(currSubjDir)
        
        %Delete all the previous procedural recordings
        o.deleteAll('Procedure');
        o.deleteAll('Task');
        o.deleteAll('Skill');
        
        %Get the full path of the xml file
        xmlPath = [ dirPath, '/', subjDir(i).name, '/' currSubjDir(j).name ];
        %Read the xml file
        D = xmlToTextNoMsg( toolNames, xmlPath );
        
        %Get the full path of the tfm file
        tfmPath = [ dirPath, '/', subjDir(i).name, '/' replceExtension(currSubjDir(j).name,'.tfm') ];
        %Read the tfm file
        StylusTipToStylus = dlmreadn(tfmPath);
        
        %Get the full path of the xlsx file
        currSegFile = [ dirPath, '/', subjDir(i).name, '/' currSegDir(1).name];
        %Read the xlsx file
        [transT transK] = readLCSegmentation( currSegFile, currSubjDir(j).name);
        %Get the inout segmentation of the
        seg = segmentationToRecord( D{1}.T, transT, transK);
        
        %Apply the StylusTipToStylus transform to the StylusToReference
        D{1} = D{1}.calibration( o.read('Identity') , StylusTipToStylus );
        
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
            %Write the Data objects to file
            writeRecord(D_Rem{k});
        end%for
        
        %Write the Data object to file
        textToXML( replaceExtension(xmlPath,'_Rem.xml'), toolNames, procNum);
        
    end%for
    
    
end%for

%Indicate the function has been successful
status = 1;