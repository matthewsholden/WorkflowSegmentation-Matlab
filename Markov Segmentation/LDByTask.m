%This function will convert a sequence of LD's organized by procedure into a
%sequence of LD's organized by task. When a task is performed more than
%once this produces multiple LD sequences

%Parameter procSeq: A sequence of LD's grouped by procedure
%Parameter Task: The task corresponding to each LD point

%Return proSeq: A sequence of LD's grouped by task and number of task
function LDSeq = LDByTask(procSeq, Task)

%First, find the maximum task number...
maxTask = calcMaxTask(Task);

%Recall that procs, the number of procedures is the length of taskArray
procs = length(Task);

%The number of the point for the sequence
pointNum = zeros(1,maxTask);
%The sequence of tasks for the current procedure
LDSeq=cell(maxTask,1);
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
        %The point number in the sequence for the task, taskCount
        pointNum(currTask) = pointNum(currTask) + 1;
        %Add this point to the sequence for the current task
        LDSeq{currTask}(pointNum(currTask),:) = procSeq{p}(j,:);
    end
    
end

%That is all