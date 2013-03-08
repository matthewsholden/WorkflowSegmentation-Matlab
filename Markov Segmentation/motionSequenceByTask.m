%This function will convert a sequence of motions organized by procedure into a
%sequence of motions organized by task. When a task is performed more than
%once this produces multiple motion sequences

%Parameter D: A cell array of data objects

%Return X_Task: A sequence of observations organized by task (specified type)
%{task}{task number}(observation)
function D_Task = motionSequenceByTask(D)

%Recall that procs, the number of procedures is the length of D
procs = length(D);

%Count the number of tasks per procedure, points per task
taskNum = zeros(1,calcMax(D,'Task'));  pointNum = 0;
%The task we were previously doing (to determine the sequence transition)
prevTask = 0;
%The sequence of points for the current task in the current procedure
T_Task = cell(1,calcMax(D,'Task'));
X_Task = cell(1,calcMax(D,'Task'));
K_Task = cell(1,calcMax(D,'Task'));
S_Task = cell(1,calcMax(D,'Task'));

%Iterate over all procedures
for p=1:procs
    %Iterate over all time steps in the procedure
    for j=1:D{p}.n
        %The point number in the sequence for the task, taskNum
        pointNum = pointNum + 1;
        %Determine the task we are currently on, compare to previous one. 
        %If changed, start a new sequence, otherwise continue same one
        if (D{p}.K(j) ~= prevTask)
            %Increment taskNum; reset pointNum, change prevTask to current
            taskNum(D{p}.K(j)) = taskNum(D{p}.K(j)) + 1;
            pointNum = 1;
            prevTask = D{p}.K(j);
        end
        %Add this point to the sequence of clusters for the current task
        T_Task{D{p}.K(j)}{taskNum(D{p}.K(j))}(pointNum,:) = D{p}.T(j,:);
        X_Task{D{p}.K(j)}{taskNum(D{p}.K(j))}(pointNum,:) = D{p}.X(j,:);
        K_Task{D{p}.K(j)}{taskNum(D{p}.K(j))}(pointNum,:) = D{p}.K(j,:);
        S_Task{D{p}.K(j)}{taskNum(D{p}.K(j))}(pointNum,:) = D{p}.S;

    end
    %Reset task count after the procedure is finished
    pointNum = 0;
end

%Create a cell array of data objects
D_Task = cell(1,calcMax(D,'Task'));

%We shall create a cell array of cell arrays of data objects
for i=1:calcMax(D,'Task')
    %Iterate over all occurrances of the task
    for j=1:taskNum(i)
        %Create the new data object
        D_Task{i}{j} = Data(T_Task{i}{j},X_Task{i}{j},K_Task{i}{j},S_Task{i}{j});
    end
end