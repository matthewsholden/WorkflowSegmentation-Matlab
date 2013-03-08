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

%This function will convert an xml file with data for an experimental
%procedures into a procedural record that is readable for our segmentation
%algorithms

%Parameter subjNum: The number of the subject we are interested in
%Parameter procType: The type of procedural we are interested in for the
%particular subject (ie Trial 1, Practice 4, etc...)
%Parameter virtual: A string indicating if the subject was in the Control
%group or the VR group
%Parameter lumbarJoint: Whether the procedure is L3-4 or L4-5

%Return D: A pointer to the data object containing all of the information
%for the procedure
function D = xmlToRecord(subjNum,procType,virtual,lumbarJoint)

%Determine the appropriate filenames for the segmentation and for the
%procedure itself using the findData methods (for finding the path name of
%where our data is located)
[procFile segFile] = findData(subjNum,procType,virtual,lumbarJoint);

%Read the dom object from the xml file
D = xmlread(procFile);

%Now, find the document object held in the dom
R = D.getDocumentElement();

%Now, get an array of child nodes of the document object
C = R.getChildNodes();

%We will have a cell array of attributes
name = cell(1,1);
value = cell(1,1);
%Also, keep track of whether this is a message or a time stamp
type = cell(1,1);


%Read the data from file


i = 1;
%While we still have child nodes remaining
while (2*i-1 < C.getLength)
    A = C.item(2*i-1).getAttributes();
    j=0;
    while (j < A.getLength)
        name{i}{j+1} = char(A.item(j).getName());
        value{i}{j+1} = char(A.item(j).getValue());
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

%Convert the read data to the T and X data form that we use in our
%segmentation algorithm implementation here

%Initialize our variables
T = zeros(1,1);
TN = zeros(1,1);
X = zeros(1,8);

%Count the number of data points we have
countX = 0;
countT = 0;
countTN = 0;

%Create an organizer object to read the registration transform
o = Organizer();
%Determine the registration transform
Registration = o.read('Registration');
Rotation = o.read('Rotation');
Tool = o.read('Tool');

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
                num = str2num(str); %#ok<*ST2NM>
                %Convert the num to a matrix form
                mat = reshape(num,4,4)';
                %Convert the matrix to a quaternion
                x = matrixToDOF(mat,Registration,Rotation);
                %Add the quaternion to the list of data points
                X(countX,:) = x';
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
        
         %In this case we don't care about the messages, because we will
         %get the task segmentation from our manual annotation
    end
        
end

%Now that we have determined the data points, time stamps and segmentation
%points, we just need to determine the task at each time step. Note that
%the segmentation points indicate the end of the task.

%Add the time and time n values
T = T + TN;
%And ensure that T is a column vector
T = T';
%Finally, we will subtract the minimum value for T from all entries, such
%that our times start at zero
T = T - min(T);

%Read the manual segmentation points from the Microsoft Excel file we have
%compiled
[transT transK] = readManualSegmentation(segFile,procType);

%Now, turn the segmentation into a task record
K = segmentationToRecord(T,transT,transK);

%Now, finally, for any times that the task is not assigned, crop them out
T = T( K ~= 0 );
X = X( K ~= 0 , : );
K = K( K ~= 0 );

%And write these to file...
D = Data(T,X,K,0);
writeRecord(D);

%Free the memory
clearvars -except D;
