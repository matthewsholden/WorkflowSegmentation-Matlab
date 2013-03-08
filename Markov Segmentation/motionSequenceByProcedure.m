%This function will convert a sequence of motions organized by procedure into a
%sequence of motions organized by task. When a task is performed more than
%once this produces multiple motion sequences

%Parameter procSeq: A sequence of motions grouped by procedure

%Return motionSeq: A sequence of motions grouped by task and number of task
%[[Matrix of points] procedure]
%Row: Sequence of motions
%Column: Sequence of tasks (of unknown index)
%3rd dimension: Index of procedure
function motionSeq = motionSequenceByProcedure(procSeq, Task)

%Recall that procs, the number of procedures is the length of taskArray
procs = length(Task);

%Keep track of the total number of different (but possibly repeated) tasks
%in the procedure
taskCount = 0;
%The task we were previously doing (to determine the sequence length)
prevTask = 0;
%The number of the point for the sequence
pointNum = 0;
%The sequence of motion for the current task in the current procedure
motionSeq=cell(procs,1);
%Initialize n to have size the same as the number of procedures
n = cell(1,procs);

%Our seq tensor will be: [taskCount point task] so that we can easily read
%a matrix if we only are considering one task

%We can just reorganize the cluster vector
%Iterate over all procedures
for p=1:procs
    %Recall that n is the number of time stamps for each procedure
    n{p} = length(Task{p});
    %Iterate over all time steps in the procedure
    for j=1:n{p}
        %The point number in the sequence for the task, taskCount
        pointNum = pointNum + 1;
        %Determine the task we are currently on and compare to the previous
        %task. If it has changed, start a new sequence, otherwise continue
        %the saem sequence
        if (Task{p}(j) ~= prevTask)
            %If we are not on the same sequence, increment the taskCount,
            %reset the point number and change the previous task
            taskCount = taskCount + 1;
            pointNum = 1;
            prevTask = Task{p}(j);
        end
        %Add this point to the sequence of clusters for the current task
        motionSeq{p}{taskCount}(pointNum) = procSeq{p}(j);

    end
    %Do not reset task count after the procedure is finished
    taskCount = 0;
    pointNum = 0;
end

%That is all