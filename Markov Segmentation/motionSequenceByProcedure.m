%This function will convert a sequence of motions organized by procedure into a
%sequence of motions organized by task. When a task is performed more than
%once this produces multiple motion sequences

%Parameter D: A cell array of data objects

%Return X_Proc: A sequence of observations organized by procedure, and
%task (of unspecified type)
%{procedure number}{task number}(observation)
function D_Proc = motionSequenceByProcedure(D)

%Recall that procs, the number of procedures is the length of D
procs = length(D);

%Count the number of tasks per procedure, points per task
taskNum = zeros(1,procs);  pointNum = 0;
%The task we were previously doing (to determine the sequence transition)
prevTask = 0;
%The sequence of motion for the current task in the current procedure
T_Proc = cell(1,procs);
X_Proc = cell(1,procs);
K_Proc = cell(1,procs);
S_Proc = cell(1,procs);

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
            taskNum(p) = taskNum(p) + 1;
            pointNum = 1;
            prevTask = D{p}.K(j);
        end
        %Add this point to the sequence of clusters for the current task
        T_Proc{p}{taskNum}(pointNum,:) = D{p}.T(j,:);
        X_Proc{p}{taskNum}(pointNum,:) = D{p}.X(j,:);
        K_Proc{p}{taskNum}(pointNum,:) = D{p}.K(j,:);
        S_Proc{p}{taskNum}(pointNum,:) = D{p}.S;

    end
    %Reset point count after the procedure is finished
    pointNum = 0;
    
end

%Create a cell array of data objects
D_Proc = cell(1,procs);

%We shall create a cell array of cell arrays of data objects
for i=1:procs
    %Iterate over all occurrances of the task
    for j=1:taskNum(i)
        %Create the new data object
        D_Proc{i}{j} = Data(T_Proc{i}{j},X_Proc{i}{j},K_Proc{i}{j},S_Proc{i}{j});
    end
end