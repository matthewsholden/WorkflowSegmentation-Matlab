%This function will convert a sequence of motions organized by procedure into a
%sequence of motions organized by task. When a task is performed more than
%once this produces multiple motion sequences

%Parameter D: A cell array of data objects

%Return D_Task: A sequence of data objects organized by task (specified type)
%{task}{count}(observation)
function D_Task = byTask(D)

%Calculate the number of procedures
numProc = length(D);
%Calculate the maximum task number
maxTask = calcMax(D,'Task');

%Count the number of tasks per procedure
taskCount = zeros(1,calcMax(D,'Task'));
%The previously and currently performed tasks
prevTask = 0;


%The sequence of points for the current task in the current procedure
T_Task = cell(1,maxTask);
X_Task = cell(1,maxTask);
K_Task = cell(1,maxTask);
S_Task = cell(1,maxTask);


%Iterate over all procedures
for p=1:numProc
    
    %Iterate over all time steps in the procedure
    for j=1:D{p}.count
        
        %Read current task from data object
        currTask = D{p}.K(j);
        
        %If task changed, start a new sequence, otherwise continue same one
        if (currTask ~= prevTask)
            
            %Increment taskNum; change prevTask to current
            taskCount(currTask) = taskCount(currTask) + 1;
            prevTask = currTask;
            
            %Initialize the associated cell arrays
            T_Task{currTask}{taskCount(currTask)} = [];
            X_Task{currTask}{taskCount(currTask)} = [];
            K_Task{currTask}{taskCount(currTask)} = [];
            S_Task{currTask}{taskCount(currTask)} = [];

        end%if
        
        %Add this point to the sequence of clusters for the current task
        T_Task{currTask}{taskCount(currTask)} = cat(1, T_Task{currTask}{taskCount(currTask)}, D{p}.T(j,:) );
        X_Task{currTask}{taskCount(currTask)} = cat(1, X_Task{currTask}{taskCount(currTask)}, D{p}.X(j,:) );
        K_Task{currTask}{taskCount(currTask)} = cat(1, K_Task{currTask}{taskCount(currTask)}, D{p}.K(j,:) );
        S_Task{currTask}{taskCount(currTask)} = cat(1, S_Task{currTask}{taskCount(currTask)}, D{p}.S );

    end%for

end%for


%Create a cell array of data objects
D_Task = cell(1,maxTask);

%Iterate over all task numbers
for i=1:maxTask
    
    %Iterate over all occurrances of the task
    for j=1:taskCount(i)
        
        %Create the new data object
        D_Task{i}{j} = Data(T_Task{i}{j},X_Task{i}{j},K_Task{i}{j},S_Task{i}{j});
        
    end%for
    
end%for
