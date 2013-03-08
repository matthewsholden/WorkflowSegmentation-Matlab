%This function will read a sequence of tasks orgainzed by procedure

%Parameter taskArray: An array of file names containg the task numbers for a
%procedural record

%Return taskSeq: A sequence of tasks organized by procedure [procedure
%task]
function taskSeq = taskSequenceConvert(Task)

%First, find the maximum task number...
maxTask = 0;

%Recall that procs, the number of procedures is the length of taskArray
procs = length(Task);

%Look through all procedure files
for p=1:procs
    %Find the maximum task number and if it is larger than the previous
    %maximum task number the proceed
    if (max(Task{p}) > maxTask)
        maxTask = max(Task{p});
    end
end


%The task we were previously doing (to determine the sequence length)
prevTask = 0;
%The sequence of tasks for the current procedure
taskSeq=cell(1,procs);
%The total number of tasks within the procedure we are considering
taskNum = 0;
%Initialize n to have size the same as the number of procedures
n = cell(1,procs);

%We can just reorganize the cluster vector
%Iterate over all procedures
for p=1:procs
    %Recall that n is the number of time stamps for each cluster
    n{p} = length(Task{p});
    %Iterate over all time steps in the procedure
    for j=1:n{p}
        %Determine the task we are currently on and compare to the previous
        %task. If it has changed, start a new sequence, otherwise continue
        %the saem sequence
        if (Task{p}(j) ~= prevTask)
            %If we are not on the same sequence, add to the taskSeq,
            %reset the point number and change the previous task
            taskNum = taskNum + 1;
            taskSeq{p}(taskNum) = Task{p}(j);
            prevTask = Task{p}(j);
        end
    end
    %At the end of the procedure, reset the task number
    taskNum = 0;
end

%That is all