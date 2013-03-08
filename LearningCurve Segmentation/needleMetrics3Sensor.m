%This function will take a directory of specified procedural recordings
%(recorded by fCal) and convert all of the mha files to xml files

%Parameter dirPath: The path with the specified subject folders

%Return status: Whether or not the conversion was successful
function status = needleMetrics3Sensor(dirPath,subjName)

%Initialize the status to indicate incomplete
status = 0;

%Manually add the corners of the prism
corner = cell(1,4);
corner{1} = [ 102.272 49.483 113.091 ];
corner{2} = [ 101.532 -75.752 113.405 ];
corner{3} = [ 287.480 32.689 121.359 ];
corner{4} = [ 80.154 40.147 -69.466 ];


%Search the directory for all folders with subjects within
subjDir = dir([dirPath, '/', subjName, '*']);
numSubj = length(subjDir);

%The names of the relevant tools
toolNames = {'StylusTipToReference'};
numTools = length(toolNames);

%The file name to write the metrics
metricFile = [dirPath, '/Metrics.xlsx'];

%Cell array of metric values with subject names
nameArray = cell(0,1);
metricArray = cell(0,1);

%Iterate over all subjects
for i = 1:numSubj
    
    %Get the mha contents of the directory of the current subject
    currSubjDir = dir([dirPath, '/', subjDir(i).name, '/*Rem.xml']);
    currSubjName = replaceExtension( subjDir(i).name, '');
    currMetrics = [];
    
    %Iterate over all mha files for the current subject
    for j = 1:length(currSubjDir)

        %Get the full path of the xml file
        xmlPath = [ dirPath, '/', subjDir(i).name, '/' currSubjDir(j).name ];
        %Read the xml file
        D = AscTrackToData( xmlPath, toolNames);
        
        %Calculate the needle metrics
        StyTip_Ref = D{1};
        [timeTotal timeInside pathTotal pathInside tissueDamage] = needleMetrics(StyTip_Ref,corner);
        
        disp( [ subjDir(i).name, '/' currSubjDir(j).name ] );
        disp( [ 'Path Length Inside: ', num2str( pathInside ) ] );
        
        %Add the needle metrics to the cell array
        currMetrics = padcat( 1, currMetrics, [timeTotal timeInside pathTotal pathInside tissueDamage]);
               
    end%for
    
    nameArray = cat( 1, nameArray, currSubjName);
    metricArray = cat( 1, metricArray, currMetrics);    
    
end%for

%Write the array to excel file
%Iterate over all worksheets and add data
for i = 1:numel(nameArray)
   xlswrite( metricFile, metricArray{i}, nameArray{i} );
end%for

%Clear all of the variables
clearvars;

%Indicate the function has been successful
status = 1;