%This function will convert a sequence of motions organized by procedure into a
%sequence of motions organized by task. When a task is performed more than
%once this produces multiple motion sequences

%Parameter D: A cell array of data objects

%Return K_Task: A sequence of tasks organized by prcoedure (specified type)
%{procedure}(observation)
function K_Task = taskSequenceConvert(D)

%Recall that procs, the number of procedures is the length of D
procs = length(D);

%Count the number of tasks per procedure, points per task
pointNum = 0;   taskNum = 0;    prevTask = 0;
%The sequence of motion for the current task in the current procedure
K_Task = cell(1,procs);



%Iterate over all procedures
for p=1:procs
    %Iterate over all time steps in the procedure
    for j=1:D{p}.n
        %The point number in the sequence for the task, taskNum
        pointNum = pointNum + 1;
        if (D{p}.K(j) ~= prevTask)
            %Increment the taskNum
            taskNum = taskNum + 1;
            %Increment taskNum; reset pointNum, change prevTask to current
            K_Task{p}(taskNum) = D{p}.K(j);
            pointNum = 1;
            prevTask = D{p}.K(j);
        end

    end
    %Reset task count after the procedure is finished
    pointNum = 0;
    taskNum = 0;
end