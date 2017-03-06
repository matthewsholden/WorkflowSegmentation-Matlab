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


function DT = AscTrackToDataTask(subjNum,trial,skill,technique,toolNames)


%Find the location of the ascension tracking output file and segmention xlsx file
[procFile segFile] = findDataLP(subjNum,trial,skill,technique);
%Read the dom object from the xml file
D = xmlread(procFile);
%Now, find the document object held in the dom
R = D.getDocumentElement();
%Now, get an array of child nodes of the document object
C = R.getChildNodes();

%Read the task segmentation from the segmentation file
[transT transK] = readManSegLP(segFile,trial);
disp( [ 'Task: ', num2str( transK' ) ] );


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


%Next, determine the data points and read them into our matrices of
%data points and time steps
for i=1:length(type)
   
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





%Now that we have determined the data points, time stamps and segmentation
%points, we just need to determine the task at each time step. Note that
%the segmentation points indicate the end of the task.

%Calculate the total times
for j=1:numTools
    XTT{j} = XT{j} + XTN{j} / 1e9;
    XTT{j} = XTT{j} - min( XTT{j} );
end%for

%Add the time and time n values
for j=1:numTools
    
    %For any time stamps without a task assigned, chop them out
    K = segToTaskData( XTT{j}, transT, transK);
    chop = (K ~= 0);
    XTT{j} = XTT{j}(chop);
    X{j} = X{j}( chop, : );
    XK{j} = K(chop);
    
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
