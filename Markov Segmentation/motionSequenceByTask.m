
%This function will convert a sequence of motions organized by procedure into a
%sequence of motions organized by task. When a task is performed more than
%once this produces multiple motion sequences

%Parameter procSeq: A sequence of motions grouped by procedure

%Return seq: A sequence of motions grouped by task and number of task
%[[Matrix of points] task]
%Row: Sequence of motions
%Column: Sequence of tasks (of unknown procedure)
%3rd dimension: Index of task
function motionSeq = motionSequenceByTask(procSeq, Task)

%First, find the maximum task number...
maxTask = calcMaxTask(Task);

%Recall that procs, the number of procedures is the length of taskArray
procs = length(Task);

%Now, we will have several sequences for each task, so we need to keep
%track of how many sequences there are for each task.
taskCount = zeros(1,maxTask);
%The task we were previous doing (to determine the sequence length)
prevTask = 0;
%The number of the point for the sequence
pointNum = 0;
%The sequence of tasks for the current procedure
motionSeq=cell(1,maxTask);
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
        %The point number in the sequence for the task, taskCount
        pointNum = pointNum + 1;
        %Determine what the current task is from the task record
        currTask = Task{p}(j);
        %Determine the task we are currently on and compare to the previous
        %task. If it has changed, start a new sequence, otherwise continue
        %the saem sequence
        if (currTask ~= prevTask)
            %If we are not on the same sequence, increment the taskCount,
            %reset the point number and change the previous task
            taskCount(currTask) = taskCount(currTask) + 1;
            pointNum = 1;
            prevTask = currTask;
        end
        %Add this point to the sequence for the current task
        motionSeq{currTask}{taskCount(currTask)}(pointNum) = procSeq{p}(j);

    end
    %Do not reset the task count at the end of each procedure
    prevTask = 0;
    
end

%That is all