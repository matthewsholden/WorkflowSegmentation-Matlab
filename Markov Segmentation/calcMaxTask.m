%This function will determine the maximum task number for a given set of
%task records by simply looking at all of them and finding the largest
%number

%Return maxTask: The largest task number in existence
function maxTask = calcMaxTask(Task)

%We need an organizer to read/write from file if we do not have the task
%records inputted
if (nargin == 0)
    [T Task] = readTask();
end
   
%Otherwise, there's nothing to read

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