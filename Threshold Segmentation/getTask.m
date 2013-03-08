%This function will display what task is currently being executed

%Parameter x: A vector of values in each degree of freedom
%Parameter v: A vector of veclocities in each degree of freedom
%Parameter p: The previous task
%Parameter depth: The depth of the needle insertion
%Parameter ET: The referece vector for the entry-target line, note that
%this vector is not necessarily normalized
%Parameter TP: A matrix with the tresholds for each degree of freedom in
%each task

%Return task: The task number that is currently being executed
function task = getTask(x,v,p,ET,TP)

%Keep track of whether or not the needle is in the skin
in = (p == 3 || p == 4 || p == 5);

%Initialize task in case no task claims the motion
task=p;

%This task just asks if it is each particular task number
%More task should not claim the needle, but if more than one does, the
%first one (in order of occurrence) will receive it
if (isTask1(x,v,TP(:,1),in,ET))
   task=1;
   return;
end

if (isTask2(x,v,TP(:,2),in,ET))
   task=2;
   return;
end

if (isTask3(x,v,TP(:,3),in,ET))
   task=3;
   return;
end

if (isTask4(x,v,TP(:,4),in,ET))
   task=4;
   return;
end

if (isTask5(x,v,TP(:,5),in,ET))
   task=5;
   return;
end