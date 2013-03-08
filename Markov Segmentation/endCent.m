%This function will take a sequence of observations, and determine the mean
%observation value at which each task ends

%Parameter D: A cell array of data objects

%Return End: A matrix of mean observation values at the end of each task
function End = endCent(D)

%We might have just a single record as an input...
D = makeCell(D);

%Recall that procs, the number of procedures is the length of D
procs = length(D);

%Count the number of tasks per procedure, points per task
taskNum = zeros(1,calcMax(D,'Task'));
%The task we were previously doing (to determine the sequence transition)
prevTask = 0;
%The sequence of motion for the current task in the current procedure
endPoint = cell(1,calcMax(D,'Task'));
%The matrix of end centroids
End = zeros( calcMax(D,'Task'), size(D{1}.X,2) );

%Iterate over all procedures
for p=1:procs
    %Iterate over all time steps in the procedure
    for j=1:D{p}.n
        %Determine the task we are currently on, compare to previous one.
        %If changed, and an end point.
        if (D{p}.K(j) ~= prevTask || j == D{p}.n)
            %Increment taskNum; reset pointNum, change prevTask to current
            taskNum(D{p}.K(j)) = taskNum(D{p}.K(j)) + 1;
            %Add this point to the sequence of clusters for the current task
            endPoint{D{p}.K(j)}(taskNum(D{p}.K(j)),:) = D{p}.X(j,:);
            %Change prevTask to current
            prevTask = D{p}.K(j);
            
        end
        
    end
    
end

%Calculate the average end of task observation just by averaging
for t=1:calcMaxTask(D)
    %Find the average for each task
    endPoint{t} = mean(endPoint{t},1);
    %Add this to a matrix
    End(t,:) = endPoint{t};
end