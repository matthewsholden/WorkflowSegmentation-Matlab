%This function will convert a sequence of motions organized by procedure into a
%sequence of motions organized by task. When a task is performed more than
%once this produces multiple motion sequences

%Parameter D: A cell array of data objects

%Return X_Skill: A sequence of observations organized by skill,task (specified type)
%{skill,task}{task number}(observation)
function D_Skill = motionSequenceBySkill(D)

%Recall that procs, the number of procedures is the length of D
procs = length(D);

%Count the number of tasks per procedure, points per task
taskNum = zeros(calcMax(D));  pointNum = 0;
%The task we were previously doing (to determine the sequence transition)
prevTask = 0;
%The sequence of motion for the current task in the current procedure
T_Skill = cell(calcMax(D));
X_Skill = cell(calcMax(D));
K_Skill = cell(calcMax(D));
S_Skill = cell(calcMax(D));

%Iterate over all procedures
for p=1:procs
    %If the skill-level of this procedure is zero, then skip it
    if (D{p}.S == 0)
        continue;
    end
    %Iterate over all time steps in the procedure
    for j=1:D{p}.n
        %The point number in the sequence for the task, taskNum
        pointNum = pointNum + 1;
        %Determine the task we are currently on, compare to previous one.
        %If changed, start a new sequence, otherwise continue same one
        if (D{p}.K(j) ~= prevTask)
            %Increment taskNum; reset pointNum, change prevTask to current
            taskNum(D{p}.S,D{p}.K(j)) = taskNum(D{p}.S,D{p}.K(j)) + 1;
            pointNum = 1;
            prevTask = D{p}.K(j);
        end
        %Add this point to the sequence of clusters for the current task
        T_Skill{D{p}.S,D{p}.K(j)}{taskNum(D{p}.S,D{p}.K(j))}(pointNum,:) = D{p}.T(j,:);
        X_Skill{D{p}.S,D{p}.K(j)}{taskNum(D{p}.S,D{p}.K(j))}(pointNum,:) = D{p}.X(j,:);
        K_Skill{D{p}.S,D{p}.K(j)}{taskNum(D{p}.S,D{p}.K(j))}(pointNum,:) = D{p}.K(j,:);
        S_Skill{D{p}.S,D{p}.K(j)}{taskNum(D{p}.S,D{p}.K(j))}(pointNum,:) = D{p}.S;
        
        
    end
    %Reset task count after the procedure is finished
    pointNum = 0;
end

%Create a cell array of data objects
D_Skill = cell(calcMax(D));

%Iterate over all skill levels
for i=1:calcMax(D,'Skill')
    %Iterate over all tasks
    for j=1:calcMax(D,'Task')
        %Iterate over all occurrances of the task at the skill-level
        for k=1:taskNum(i,j)
            %Create the new data object
            D_Skill{i,j}{k} = Data(T_Skill{i,j}{k},X_Skill{i,j}{k},K_Skill{i,j}{k},S_Skill{i,j}{k});
        end
    end
end