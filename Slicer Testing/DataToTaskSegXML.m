%This function will take a data object, and write an Ascension tracking
%style file

%Parameter D: Cell array of data objects to write to file
%Parameter outFile: The name of the xml file to write the data
%Parameter toolNames: The names of the tools/transforms we wish to read

%Return status: Whether or not writing to file was successful
function status = DataToAscTrack(D,outFile,toolNames)

%Indicate the function has not finished
status = 0;

%Create cell array of each part of the data object
%We have up to n tools to record
numTools = length(toolNames);

XTT = cell(1,numTools);
XT = cell(1,numTools);
XTN = cell(1,numTools);
X = cell(1,numTools);
XK = cell(1,numTools);

%Grab the information from the data objects
for j=1:numTools
    XTT{j} = D{j}.T;
    XT{j} = floor( D{j}.T );
    XTN{j} = round( 1e9 * ( D{j}.T - floor(D{j}.T) ) );
    X{j} = D{j}.X;
    XK{j} = D{j}.K;
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
        if ( size(XTT{j},1) < 1 )
            continue;
        end%if
        
        %If the new tool has a smaller time stamp
        if ( XTT{j}(1,:) < minTime )
            minTool = j;
            minTime = XTT{j}(1,:);
        end%if
        
    end%for
    
    %Now, add the data from the minimum tool to the xml file
    thisElement = docNode.createElement('log'); 
    thisElement.setAttribute('TimeStampSec', num2str( XT{minTool}(1,:) ) );
    thisElement.setAttribute('TimeStampNSec', num2str( XTN{minTool}(1,:) ) );
    thisElement.setAttribute('type', 'task' );
    thisElement.setAttribute('DeviceName', toolNames{minTool} );
    %thisElement.setAttribute('transform', num2str( reshape( dofToMatrix(X{minTool}(1,:))',1,16 ) ) );
    thisElement.setAttribute('transform', num2str( X{minTool}(1,:) ) );
    docRootNode.appendChild(thisElement);

    %Now, remove a row from all observations
    XTT{minTool} = XTT{minTool}(2:end,:);
    XT{minTool} = XT{minTool}(2:end,:);
    XTN{minTool} = XTN{minTool}(2:end,:);
    X{minTool} = X{minTool}(2:end,:);
    
    %Check all cell arrays and see if time stamps remain
    moreTime = false;
    for j=1:numTools
        if (~isempty(XTT{j}))
            moreTime = true;
        end%if
    end%for
    
end%while


%Write the xml object to file
xmlwrite(outFile,docNode);

%Free the memory
clearvars;

%Indicate the function is finished
status = 1;