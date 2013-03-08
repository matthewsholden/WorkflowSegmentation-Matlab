%Calculate the length of each task in a procedure.

%Parameter T: The vector of times at which each observation is recorded
%Parameter Task: The vector of tasks being performed at each time

%Return length: The length of each task performed
function tLen = taskLength(T,Task)

%First, find the maximum task number...
maxTask = max(Task);

%Let length be a cell array of vectors, each with a task length
tLen = cell(1,maxTask);

%The task we were previously doing (to determine the sequence length)
prevTask = 0;
%The time at which the prevTask started
prevTime = 0;
%The total number of tasks within the procedure we are considering
taskNum = zeros(1,maxTask);


%Iterate over all time steps in the procedure
for j=1:length(Task)
    %Determine the task we are currently on and compare to the previous
    %task. If it has changed, start a new sequence, otherwise continue
    %the saem sequence
    if (Task(j) ~= prevTask)
        %If we are not on the same sequence, add to the taskSeq,
        %reset the point number and change the previous task
        if (prevTask ~= 0)
            taskNum(prevTask) = taskNum(prevTask) + 1;
            %Determine the task length
            tLen{prevTask}(taskNum(prevTask)) = T(j) - prevTime;
        end
        %Reset the prevTask and prevTime
        prevTask = Task(j);
        prevTime = T(j);
    end
end


taskNum(prevTask) = taskNum(prevTask) + 1;
%Determine the task length
tLen{prevTask}(taskNum(prevTask)) = T(j) - prevTime;
%That is all