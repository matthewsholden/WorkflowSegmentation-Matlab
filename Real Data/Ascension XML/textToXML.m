%This function will write an xml file given the procedure text files the
%trajectory is defined by

function D = textToXML(outFile,toolNames,procNums)

%First, get data objects for each of the tools
numTools = length(toolNames);
numProcs = length(procNums);
D = cell(1,numTools);
%Read all procedural records
D_All = readRecord();
%Read each procedural record
for j=1:numTools
    D{j} = D_All{procNums{j}};
end%for




%Create cell array of each part of the data object
%We have up to n tools to record
T = cell(1,numTools);
TN = cell(1,numTools);
X = cell(1,numTools);
K = cell(1,numTools);
%Grab the information from the data objects
for j=1:numTools
    T{j} = floor(D{j}.T);
    TN{j} = round( 1e9 * ( D{j}.T - floor(D{j}.T) ) );
    X{j} = D{j}.X;
    K{j} = D{j}.K;
end%for


%Create the root node
docNode = com.mathworks.xml.XMLUtils.createDocument('TransformRecorderLog');
docRootNode = docNode.getDocumentElement();

%This is true as long as there is more time stamps to add to the xml file
moreTime = true;


while (moreTime)
    
    %Find the tool with the minimum time stamp to add
    minTool = 1;
    minTime = Inf;
    %Check if the time stamp for any other tool is smaller
    for j=1:numTools
        %Skip the step if there are no remaining time stamps
        if ( size(T{j},1) < 1 )
            continue;
        end%if
        %If the new tool has a smaller time stamp
        if ( T{j}(1,:) + 1e-9 * TN{j}(1,:) < minTime )
            minTool = j;
            minTime = T{minTool}(1,:) + 1e-9 * TN{minTool}(1,:);
        end%if
    end%for
    
    %Now, add the data from the minimum tool to the xml file
    thisElement = docNode.createElement('log'); 
    thisElement.setAttribute('TimeStampSec', num2str( T{minTool}(1,:) ) );
    thisElement.setAttribute('TimeStampNSec', num2str( TN{minTool}(1,:) ) );
    thisElement.setAttribute('type', 'transform' );
    thisElement.setAttribute('DeviceName', toolNames{minTool} );
    thisElement.setAttribute('transform', num2str( reshape( dofToMatrix(X{minTool}(1,:))',1,16 ) ) );
    docRootNode.appendChild(thisElement);

    %Now, remove a row from all observations
    T{minTool} = T{minTool}(2:end,:);
    TN{minTool} = TN{minTool}(2:end,:);
    X{minTool} = X{minTool}(2:end,:);
    
    %Check all cell arrays and see if time stamps remain
    moreTime = false;
    for j=1:numTools
        if (~isempty(T{j}))
            moreTime = true;
        end%if
    end%for
    
end%while

xmlFileName = outFile;
xmlwrite(xmlFileName,docNode);

%Free the memory
clearvars -except D;