%Here are the details on reading xml files in Matlab

%D = xmlread(filename)
%This returns a DOM

%R = D.getDocumentElement()
%This returns a document object

%C = R.getChildNodes()
%This returns an array of child nodes of the document object

%C.item(i)
%This returns the item contained in the ith child node of the document object

%A = C.getAttributes()
%This returns a cell array of attribute nodes

%A.item(i)
%This returns the item contained in the ith attribute node of the childe
%node

%A.item(i).getValue()
%This returns the value of the ith attribute node

%A.item(i).getName()
%This returns the name of the ith attribute node


function DT = AscTrackToData(fileName,toolNames,messageNames)


%If the message names are not specified, assume empty
if (nargin < 3)
    messageNames = {};
end%if

%Read the dom object from the xml file
D = xmlread(fileName);
%Now, find the document object held in the dom
R = D.getDocumentElement();
%Now, get an array of child nodes of the document object
C = R.getChildNodes();


%We will have a cell array of attributes
name = cell(1,1);   value = cell(1,1);
%Also, keep track of whether this is a message or a time stamp
type = cell(1,1);


i = 1;
%While we still have child nodes remaining
while (i < C.getLength)
    A = C.item(i).getAttributes();
    %Iterate over all attributes of the child
    j=0;
    while (j < A.getLength)
        name{i}{j+1} = char(A.item(j).getName());
        value{i}{j+1} = char(A.item(j).getValue());
        j = j+1;
    end
    i = i+2;
end


%Determine what is a transform and what is a message
for i=1:length(name)
    for j=1:length(name{i})
        %Check if the points are messages or transforms (data points)
        if (strcmp(name{i}{j},'type'))
            type{i} = value{i}{j};
        end%if
    end%for
end%for






%Calculate the number of tools we have
numTools = length(toolNames);

%We have up to n tools to record
XT = cell(1,numTools);
XTN = cell(1,numTools);
XTT = cell(1,numTools);
X = cell(1,numTools);
XK = cell(1,numTools);

%Count the number of data points we have for each tool
countX = cell(1,numTools);

%Initialize the count to zero for all tools
for j=1:numTools
    %Preallocate vectors
    countX{j} = 0;
    XT{j} = zeros(0,1);
    XTN{j} = zeros(0,1);
    X{j} = zeros(0,8);
    
end%for

%Keep track of the messages
countM = 0;
MT = zeros(0,1);
MTN = zeros(0,1);
M = cell(0,1);
MK = zeros(0,1);




%Next, determine the data points and read them into our matrices of
%data points and time steps
for i=1:length(type)
    
    %Check if the xml tag is a message
    if (strcmp(type{i},'message'))
        countM = countM + 1;
        
        %Check all attributes if they are the transform attribute
        for j=1:length(name{i})
            
            %Add the message to a cell array of messages
            if (strcmp(name{i}{j},'message'))
                M{countM} = value{i}{j};
            end%if
            
            %Add the time attribute to the time vector
            if (strcmp(name{i}{j},'TimeStampSec'))
                MT(countM,:) = str2num( value{i}{j} );
            end%if
            
            %Add the nanosecond time attribute to the time vector
            if (strcmp(name{i}{j},'TimeStampNSec'))
                MTN(countM,:) = str2num( value{i}{j} );
            end%if
            
        end%for
        
    end%if
    
    
    
    
    %Skip the iteration if the observation is not a transform
    if (~strcmp(type{i},'transform'))
        continue;
    end%if
    
    
    %First, iterator over all tags, and identify the tool name/number
    for j=1:length(name{i})
        %Iterate over all attributes to find the tool
        if (strcmp(name{i}{j},'DeviceName'))
            %Assume the tool number is zero
            tool = 0;
            %Iterate over all tool names to find the number
            for k=1:numTools
                if (strcmp(value{i}{j},toolNames{k}))
                    tool = k;
                end%if
            end%for
        end%if
    end%for
    
    
    
    %If no tool with that name is found, then move on
    if (tool == 0)
        continue;
    end%if
    
    %Increment the count of tool transforms
    countX{tool} = countX{tool} + 1;
    
    %Check all attributes if they are the transform attribute
    for j=1:length(name{i})
        
        %Convert transform attribute to dof vector
        if (strcmp(name{i}{j},'transform'))
            mat = reshape( str2num( value{i}{j} ), 4, 4);
            X{tool}(countX{tool},:) = matrixToDOF( mat' );
        end%if
        
        %Add the time attribute to the time vector
        if (strcmp(name{i}{j},'TimeStampSec'))
            XT{tool}(countX{tool},:) = str2num( value{i}{j} );
        end%if
        
        %Add the nanosecond time attribute to the time vector
        if (strcmp(name{i}{j},'TimeStampNSec'))
            XTN{tool}(countX{tool},:) = str2num( value{i}{j} );
        end%if
        
    end%for
    
end%for


%Calculate the task segmentation using the messages
for j=1:countM
    %Iterate over all possible message names
    for k=1:length(messageNames)
        if (strcmp(M{j},messageNames{k}))
            MK(j,:) = k;
        end%if
    end%for
end%for


%Calculate the total times
MTT = MT + MTN / 1e9;
for j=1:numTools
    XTT{j} = XT{j} + XTN{j} / 1e9;
    %XTT{j} = XTT{j} - min( XTT{j} );
    %Calculate the task segmentation for the procedure
    XK{j} = segToTaskData(XTT{j},MTT,MK);
end%for


%Now that we have determined the data points, time stamps and segmentation
%points, we just need to determine the task at each time step. Note that
%the segmentation points indicate the end of the task.

%Add the time and time n values
for j=1:numTools
    
    %The recorded data is not necessarily sorted, so we must sort it
    TXK = cat(2, XTT{j}, X{j}, XK{j});
    TXK_Sorted = sortrows(TXK,1);
    
    %Ignore sorting if we are empty (error otherwise)
    if (~isempty(XTT{j}))
        %Remove repeated time stamps from the value
        %TXK_Sorted = TXK_Sorted( diff(TXK_Sorted(:,1)) ~= 0 , : ); %Grab last
        TXK_Sorted = TXK_Sorted( [1; diff(TXK_Sorted(:,1))] ~= 0 , : ); %Grab first
        
        XTT{j} = TXK_Sorted(:,1);
        X{j} = TXK_Sorted(:,2:end-1);
        XK{j} = TXK_Sorted(:,end);
    end%if
    
end%for

%Initialize our cell array of tool data objects
DT = cell(1,numTools);

%And output these
for j=1:numTools
    DT{j} = Data(XTT{j},X{j},XK{j},0);
end%for

%Free the memory
clearvars -except DT;
