%This function will parse an mha file generated from fCal

%Parameter toolNames: The names of the tools/transforms we wish to read
%Parameter fileName: The name of the file storing the data
%Parameter transName: The name of the transform we will apply

%Return DT: A cell array of data object for each tool/transform
function DT = mhaToText(toolNames,fileName)

%Get a string for each line of the mha file
lines = filereadn(fileName);

%Determine the number of lines we have in the file
numLines = length(lines);

%We will have a cell array of attributes
name = cell(1,1);
value = cell(1,1);

%The current time stamp
currTimeStamp = 0;
currTimeStampName = '';
j = 0;
i = 0;
k = 0;

%Iterate over all lines
while (i < numLines)
    
    i = i + 1;
    
    %Get the current string
    Curr = lines{i};
    
    %Grab the frame if it is a time stamp
    if ( strfind( Curr, 'Seq_Frame' ) == 1 )
        
        %Get the underscore location
        undLoc = strfind( Curr, '_' );
        
        %Get the location of the equals sign
        eqLoc = strfind( Curr, '=' );
        
        %Add to the current time stamp parameters if it is the same
        if ( strcmp( currTimeStampName, Curr(10:undLoc(end)-1) ) )
            
            j = j+1;
            name{k}{j} = Curr(undLoc(end)+1:eqLoc(end)-2);
            value{k}{j} = Curr(eqLoc(end)+2:end);
            
            %Otherwise, create a new timestamp
        else
            
            j = 0;
            k = k + 1;
            currTimeStamp = currTimeStamp + 1;
            currTimeStampName = Curr(10:undLoc(end)-1);
            i = i - 1; %Repeat the previous time stamp
            
        end%if
        
    end%if
    
end%while


%Calculate the number of tools we have
numTools = length(toolNames);

%We have up to n tools to record
T = cell(1,numTools);
X = cell(1,numTools);
K = cell(1,numTools);

%Count the number of data points we have for each tool
countT = cell(1,numTools);
countX = cell(1,numTools);

%Initialize the count to zero for all tools
for j=1:numTools
    %Initialize counts
    countT{j} = 0;
    countX{j} = 0;
    %Preallocate vectors
    T{j} = zeros(1,1);
    X{j} = zeros(1,8);
end%for


%Next, determine the data points and read them into our matrices of
%data points and time steps
for i=1:length(name)
    
    %First, check if the tool transforms are valid
    for j=1:length(name{i})
        
        %Set the status of the tool to OK
        toolStatus = 'OK';
        %Iterate over all tool names to find the status
        for k=1:numTools
            if (strcmp(name{i}{j},[toolNames{k},'Status']))
                toolStatus = value{i}{j};
            end%if
        end%for
        
        %If the tool status is invalid, then erase everything we have done
        if ( strcmp(toolStatus,'INVALID') )
            warning('Invalid transform');
            break;
        end%if
        
    end%for
    
    
    %Don't bother reading the tool stuff if it is invalid
    if ( strcmp(toolStatus,'INVALID') )
        continue;
    end%if
    
    
    %Check all attributes if they are the transform attribute
    for j=1:length(name{i})
        
        %Assume the tool number is zero
        tool = 0;
        %Iterate over all tool names to find the number
        for k=1:numTools
            if (strcmp(name{i}{j},toolNames{k}))
                tool = k;
            end%if
        end%for
        
        %Convert transform attribute -> vector -> matrix -> quaternion
        if (tool ~= 0)
            %Increment the number of data points
            countX{tool} = countX{tool} + 1;
            %Convert the value to a vector
            num = str2num( value{i}{j} );
            %Convert the num to a matrix form
            mat = reshape(num,4,4);
            %Convert the matrix to a quaternion
            x = matrixToDOF(mat');
            %Add the quaternion to the list of data points
            X{tool}(countX{tool},:) = x;
        end%if
        
        %Add the time attribute to the time matrix
        if (strcmp(name{i}{j},'Timestamp'))
            
            %Iterate over all tools
            for k=1:numTools
                %Increment the number of time stamps
                countT{k} = countT{k} + 1;
                %Convert the value to a numeric scalar
                num = str2num( value{i}{j} );
                %Add the time to the list of data points
                T{k}(countT{k},:) = num;
            end%for
            
        end%if
        
    end%for
    
end%for


%Now that we have determined the data points, time stamps and segmentation
%points, we just need to determine the task at each time step. Note that
%the segmentation points indicate the end of the task.

%Add the time and time n values
for j=1:numTools
     
    %Create the vector of tasks (assume to be zeros, since unknown)
    K{j} = zeros(size(T{j}));
    
    %The recorded data is not necessarily sorted, so we must sort it
    TXK = padcat(2, T{j}, X{j});
    TXK = padcat(2, TXK, K{j});
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
