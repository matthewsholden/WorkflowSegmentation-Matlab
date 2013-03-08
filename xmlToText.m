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


function [T X Task] = xmlToText(fileName)

%Set the status to be zero
status=0;

%Read the dom object from the xml file
D = xmlread(fileName);

%Now, find the document object held in the dom
R = D.getDocumentElement();

%Now, get an array of child nodes of the document object
C = R.getChildNodes();

%We will have a cell array of attributes
name = cell(1,1);
value = cell(1,1);
%Also, keep track of whether this is a message or a time stamp
type = cell(1,1);

%The message names
messages{1} = 'Start';
messages{2} = 'Entry Found';
messages{3} = 'Pierce Skin';
messages{4} = 'Verifying Target';
messages{5} = 'Retraction';
messages{6} = 'Stop';

i = 1;
%While we still have child nodes remaining
while (2*i-1 < C.getLength)
    A = C.item(2*i-1).getAttributes();
    j=0;
    while (j < A.getLength)
        name{i}{j+1} = char(A.item(j).getName());
        value{i}{j+1} = char(A.item(j).getValue());
        %B = A.removeNamedItem('type');
        %type{i} = char(B.getName());
        j = j+1;
    end
    i = i+1;
end

%Now, determine the size of the cell arrays and read the task segmentation
%points from them
for i=1:length(name)
    for j=1:length(name{i})
        
        %Check if the points are messages or transforms (data points)
        if (strcmp(name{i}{j},'type'))
            type{i} = value{i}{j};
        end
    end
end


%Initialize our variables
T = zeros(1,1);
TN = zeros(1,1);
X = zeros(8,1);

%Count the number of data points we have
countX = 0;
countT = 0;
countTN = 0;
countTask = 0;
countMessage = zeros(1,length(messages));

%Next, determine the data points and read them into our matrices of
%data points and time steps
for i=1:length(name)
    
    
    %If the points are of type transform then these are data points,
    %add the point to our array
    if (strcmp(type{i},'transform'))
        
        %Check all attributes if they are the transform attribute
        for j=1:length(name{i})
            %If we have the transform attribute, convert it to a
            %vector, reshape to a matrix, and convert to quaternion
            %form
            if (strcmp(name{i}{j},'transform'))
                %Increment the number of data points
                countX = countX + 1;
                %Assign points to a string
                str = value{i}{j};
                %Convert this to numeric vector
                num = str2num(str);
                %Convert the num to a matrix form
                mat = reshape(num,4,4);
                %Convert the matrix to a quaternion
                x = matrixToDOF(mat');
                %Add the quaternion to the list of data points
                X(:,countX) = x;
            end
            
            %If we have the time attribute, add it to the time vector
            if (strcmp(name{i}{j},'TimeStampSec'))
                %Increment the number of time stamps
                countT = countT + 1;
                %Assign points to a string
                str = value{i}{j};
                %Convert this to numeric scalar
                num = str2num(str);
                %Add the time to the list of data points
                T(countT) = num;
            end
            
            %If we have a nanosecond time, add it to the tiem vector
            if (strcmp(name{i}{j},'TimeStampNSec'))
                %Increment the number of time stamps
                countTN = countTN + 1;
                %Assign points to a string
                str = value{i}{j};
                %Convert this to numeric scalar
                num = str2num(str);
                %Add the time to the list of data points
                TN(countTN) = num/1000000000;
            end
        end
        
        %If the points are of type message
    elseif (strcmp(type{i},'message'))
        
        %Check all attributes if they are the message attribute
        for j=1:length(name{i})
            %If we indeed have a segmentation point, we must determine what
            %it is indicating
            if (strcmp(name{i}{j},'message'))
                %Now iterate through our message vector to see what message
                %corresponds to the end of what task
                for k=1:length(messages)
                    %Compare to each entry in our messages vector
                    if (strcmp(value{i}{j},messages{k}))
                        %Increment the count for that particular message
                        countMessage(k) = countMessage(k) + 1;
                        %Now assign the segmentation point to the vector of
                        %task segmentation points
                        
                        %Iterate over all attributes (again)
                        for l = 1:length(name{i})
                            %Find the time attribute
                            if (strcmp(name{i}{l},'TimeStampSec'))
                                TaskSegment{k}(countMessage(k)) = str2num(value{i}{l});
                            end
                            %Find the time n attribute
                            if (strcmp(name{i}{l},'TimeStampNSec'))
                                TaskSegmentN{k}(countMessage(k)) = str2num(value{i}{l})/1000000000;
                            end
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
    end
        
end

%Now that we have determined the data points, time stamps and segmentation
%points, we just need to determine the task at each time step. Note that
%the segmentation points indicate the end of the task.

%Add the time and time n values
T = T + TN;
for k=1:length(TaskSegment)
    TaskSegment{k} = TaskSegment{k} + TaskSegmentN{k};
end

%Intialize the Task vector to have the same length as the T vector
Task = zeros(size(T));

%The minimum distance to the task segmentation and index of the task
%yielding the minimum distance
minIndex = 0;

%We will traverse the time vector
for j=1:length(T)
    %Assign min index to be zero and dist to be zero in case we are done all
    %of the tasks but the procedural recording is still going
    minDist = max(T) - min(T);
    
    %For each point in time, find the closest segmentation point that is
    %larger. This will yield the task
    for k=1:length(TaskSegment)
        %And iterate over each segmentation point for each task
        for l=1:length(TaskSegment{k})
            %Determine the distance from the time of the current time step
            %to the segmetnation point
            dist = T(j) - TaskSegment{k}(l);
            %Compare to minimum distance and ensure positivity
            if ( dist < minDist && dist >= 0)
                minDist = dist;
                minIndex = k;
            end
        end
    end
    
    %Now that we have determined the minimum index, this is the task at the
    %current time step
    Task(j) = minIndex;
    
    %If the next time step does not have a specified task, assume the task
    %is the same as the previous task
    
end

%And write these to file...
D = Data(T',X',Task',0);
writeRecord(D);


