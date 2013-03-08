%This function will parse an mha file generated from fCal

%Parameter fileName: The name of the file storing the data
%Parameter toolNames: The names of the tools/transforms we wish to read

%Return DT: A cell array of data object for each tool/transform
function DT = fCalTrackToData(fileName,toolNames)


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
XTT = cell(1,numTools);
X = cell(1,numTools);
XK = cell(1,numTools);

%Count the number of data points we have for each tool
countX = cell(1,numTools);

%Initialize the count to zero for all tools
for j=1:numTools
    %Preallocate vectors
    countX{j} = 0;
    XTT{j} = zeros(0,1);
    X{j} = zeros(0,8);
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
            
            %Add the transform
            countX{tool} = countX{tool} + 1;
            mat = reshape( str2num( value{i}{j} ), 4, 4);
            X{tool}(countX{tool},:) = matrixToDOF( mat' );
            
            %Add the time stamp
            for l=1:length(name{i})
                if (strcmp(name{i}{l},'Timestamp'))
                    XTT{tool}(countX{tool},:) = str2num( value{i}{l} );
                end%if
            end%for
            
        end%if
        
    end%for
    
end%for


%Calculate the total times
for j=1:numTools
    XTT{j} = XTT{j} - min( XTT{j} );
end%for


%Now that we have determined the data points, time stamps and segmentation
%points, we just need to determine the task at each time step. Note that
%the segmentation points indicate the end of the task.

%Add the time and time n values
for j=1:numTools
    
    %The recorded data is not necessarily sorted, so we must sort it
    XK{j} = zeros( size(XTT{j}) );
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
