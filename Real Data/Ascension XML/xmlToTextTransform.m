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


function DT = xmlToTextTransform(toolNames,fileName,transName)

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

%Determine the transform that we use (reference to RAS)
o = Organizer();
transValue = o.read(transName);

%We have up to n tools to record
T = cell(1,numTools);
TN = cell(1,numTools);
X = cell(1,numTools);
K = cell(1,numTools);

%Count the number of data points we have for each tool
countT = cell(1,numTools);
countTN = cell(1,numTools);
countX = cell(1,numTools);
%Initialize the count to zero for all tools
for j=1:numTools
    countT{j} = 0;
    countTN{j} = 0;
    countX{j} = 0;
end%for

%Next, determine the data points and read them into our matrices of
%data points and time steps
for i=1:length(type)
    
    %Skip the iteration if the observation is not a transform
    if (~strcmp(type{i},'transform'));
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
    
    %Check all attributes if they are the transform attribute
    for j=1:length(name{i})
        %If we have the transform attribute, convert it to a
        %vector, reshape to a matrix, and convert to quaternion
        %form
        if (strcmp(name{i}{j},'transform'))
            %Increment the number of data points
            countX{tool} = countX{tool} + 1;
            %Assign points to a string
            str = value{i}{j};
            %Convert this to numeric vector
            num = str2num(str);
            %Convert the num to a matrix form
            mat = reshape(num,4,4);
            %Convert the matrix to a quaternion
            x = matrixToDOF(mat',transValue);
            %Add the quaternion to the list of data points
            X{tool}(:,countX{tool}) = x;
        end
        
        %If we have the time attribute, add it to the time vector
        if (strcmp(name{i}{j},'TimeStampSec'))
            %Increment the number of time stamps
            countT{tool} = countT{tool} + 1;
            %Assign points to a string
            str = value{i}{j};
            %Convert this to numeric scalar
            num = str2num(str);
            %Add the time to the list of data points
            T{tool}(countT{tool}) = num;
        end
        
        %If we have a nanosecond time, add it to the tiem vector
        if (strcmp(name{i}{j},'TimeStampNSec'))
            %Increment the number of time stamps
            countTN{tool} = countTN{tool} + 1;
            %Assign points to a string
            str = value{i}{j};
            %Convert this to numeric scalar
            num = str2num(str);
            %Add the time to the list of data points
            TN{tool}(countTN{tool}) = num/1000000000;
        end
    end
    
    
end


%Now that we have determined the data points, time stamps and segmentation
%points, we just need to determine the task at each time step. Note that
%the segmentation points indicate the end of the task.

%Add the time and time n values
for j=1:numTools
    
    %Take the transposes
    T{j} = T{j} + TN{j};
    T{j} = T{j}';
    X{j} = X{j}';
    K{j} = zeros(size(T{j}));
        
    %The recorded data is not necessarily sorted, so we must sort it
    TXK = cat(2, T{j}, X{j}, K{j});
    TXK_Sorted = sortrows(TXK,1);
    
    %Remove repeated time stamps from the value
    %TXK_Sorted = TXK_Sorted( diff(TXK_Sorted(:,1)) ~= 0 , : ); %Grab last
    TXK_Sorted = TXK_Sorted( [1; diff(TXK_Sorted(:,1))] ~= 0 , : ); %Grab first
    
    T{j} = TXK_Sorted(:,1);
    X{j} = TXK_Sorted(:,2:end-1);
    K{j} = TXK_Sorted(:,end);
    
end%for

%Initialize our cell array of tool data objects
DT = cell(1,numTools);

%And output these
for j=1:numTools
    DT{j} = Data(T{j},X{j},K{j},0);
end%for

%Free the memory
clearvars -except DT;
