%This function will display what task is currently being executed

%Parameter x: A vector of values in each degree of freedom
%Parameter v: A vector of veclocities in each degree of freedom
%Parameter prevTask: The previous task
%Parameter depth: The depth of the needle insertion
%Parameter Entry: The coordinates of the entry point of the plan
%Parameter Target: The coordinates of the target point of the plan
%Parameter TP: A matrix with the tresholds for each degree of freedom in
%each task

%Return K: The task number that is currently being executed
function K = getTask(x,v,prevTask,Entry,Target,TP)

%Keep track of whether or not the needle is in the skin
in = (prevTask == 3 || prevTask == 4 || prevTask == 5);

%Initialize the task to the previous task in case no task claims the motion
K = prevTask;

%This task just asks if it is each particular task number
%More task should not claim the needle, but if more than one does, the
%first one (in order of occurrence) will receive it
if (isTask1(x,v,TP(:,1),in,Entry,Target))
   K = 1;
   return;
end

if (isTask2(x,v,TP(:,2),in,Entry,Target))
   K = 2;
   return;
end

if (isTask3(x,v,TP(:,3),in,Entry,Target))
   K = 3;
   return;
end

if (isTask4(x,v,TP(:,4),in,Entry,Target))
   K = 4;
   return;
end

if (isTask5(x,v,TP(:,5),in,Entry,Target))
   K = 5;
   return;
end