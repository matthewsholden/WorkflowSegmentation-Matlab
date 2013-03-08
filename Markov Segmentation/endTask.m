%This function will take a sequence of LD points grouped by procedure, and
%compute the centroid of the LD points ending each task. This will give an
%estimate on the end states for all tasks

%Parameter procSeq: A cell array of LD points for a procedure
%Parameter Task: A cell array of task records

%Return endCentroid: A matrix of points each representing the centroid of
%the LD points ending the relevant task
function endCentroid = endTask(procSeq, Task)

%First, find the maximum task number...
maxTask = calcMaxTask(Task);

%Recall that procs, the number of procedures is the length of taskArray
procs = length(Task);

%Now, we will have several sequences for each task, so we need to keep
%track of how many sequences there are for each task.
taskCount = zeros(1,maxTask);
%The task we were previous doing (to determine the sequence length)
prevTask = 0;
%The sequence of tasks for the current procedure
endPoint=cell(maxTask,1);
%Initialize n to have size the same as the number of procedures
n = cell(1,procs);

%Our seq tensor will be: [taskCount point task] so that we can easily read
%a matrix if we only are considering one task

%We can just reorganize the cluster vector
%Iterate over all procedures
for p=1:procs
    %Recall that n is the number of time stamps for each cluster
    n{p} = length(Task{p});
    %Iterate over all time steps in the procedure
    for j=1:n{p}
        %Determine what the current task is from the task record
        currTask = Task{p}(j);
        %Determine the task we are currently on and compare to the previous
        %task. If it has changed, start a new sequence, otherwise continue
        %the saem sequence
        if (Task{p}(j) ~= prevTask || j == n{p})
            %If the previous task was zero then we are just starting the
            %procedure
            if (prevTask ~= 0)
                %Add the endpoint to the matrix of endpoints
                endPoint{prevTask}(taskCount(prevTask),:) = procSeq{p}(j,:);
            end
            %If we are not on the same sequence, increment the taskCount,
            %reset the point number and change the previous task
            taskCount(currTask) = taskCount(currTask) + 1;
            %Change the task
            prevTask = currTask;
            
        end
        
    end
    %Do not reset the task count at the end of each procedure
    prevTask = 0;
    
end


%Initialize the end centroid to have maxTask rows and columns equal to the
%number of columns in procSeq
endCentroid = zeros(maxTask,size(procSeq{1},2));

%Now, we have the end points for each task, calculate the end centroid for
%each task. Iterate over all tasks
for t=1:maxTask
    %Sum along the columns and divide by the number of points we are summing
    %over to find the end centroid for each task
    endCentroid(t,:) = sum(endPoint{t},1) / taskCount(t);
    
end

%That is all


%This function will take a sequence of observations, and determine the mean
%observation value at which each task ends

%Parameter D: A cell array of data objects

%Return End: A matrix of mean observation values at the end of each task
function End = endCent(D)

%Recall that procs, the number of procedures is the length of D
procs = length(D);

%Count the number of tasks per procedure, points per task
taskNum = zeros(1,calcMaxTask(D));  pointNum = 0;
%The task we were previously doing (to determine the sequence transition)
prevTask = 0;
%The sequence of motion for the current task in the current procedure
End = cell(1,calcMaxTask(D));

%Iterate over all procedures
for p=1:procs
    %Iterate over all time steps in the procedure
    for j=1:D{p}.n
        %Determine the task we are currently on, compare to previous one.
        %If changed, and an end point.
        if (D{p}.K(j) ~= prevTask && prevTask ~= 0)
            %Increment taskNum; reset pointNum, change prevTask to current
            taskNum(D{p}.K(j)) = taskNum(D{p}.K(j)) + 1;
            prevTask = D{p}.K(j);
            %Add this point to the sequence of clusters for the current task
            End{D{p}.K(j)}(taskNum(D{p}.K(j)),:) = D{p}.X(j,:);
            
        elseif (D{p}.K(j) ~= prevTask && prevTask == 0)
            %Change prevTask to current
            prevTask = D{p}.K(j);
        end
        
    end

end

%Calculate the average end of task observation just by averaging
for t=1:calcMaxTask(D)
    %Find the average for each task
    End{t} = mean(End{t},1);
end