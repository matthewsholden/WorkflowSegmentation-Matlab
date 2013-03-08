%This function determines the percentage accuracy of a segmentation by
%comparing the task classification at each time step with the actual task
%being executed

%Parameter num: The number of the ground truth task segmentation
%Parameter task: A task segmentation vector in time

%Return acc: A percentage accuracy of the task segmentation
function acc = segmentAccuracy(num,task)

%To determine the actual segmentation, we require the keypoint data and the
%procedural record
[T Task] = readTask();

%Only consider the first time and position record...?
T = T{num};
Task = Task{num};

%This will also plot the task as a function of time for both the calculated
%task and the actual task
plot(T(task~=0),task(task~=0));
hold on;
plot(T,Task,'r');
hold off;

%Now, compare the automatically segmented task with the manually segmented
%task
right=0;
wrong =0;

%Go through all time steps
for j=1:length(T)
   %Compare the actual to the automatic segmentation
   if (task(j) == Task(j))
       right = right + 1;
   elseif (task(j) ~= 0)
       wrong = wrong + 1;
   end
end

%The accuracy can be determine from the number right and number wrong
acc = (right)/(right+wrong)*100;