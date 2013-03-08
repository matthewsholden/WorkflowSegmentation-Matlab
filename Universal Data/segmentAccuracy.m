%This function determines the percentage accuracy of a segmentation by
%comparing the task classification at each time step with the actual task
%being executed

%Parameter trueTask: The ground truth task segmentation
%Parameter segTask: The proposed automatic task segmentation

%Return acc: Accuracy of the automatic task segmentation (percentage)
function acc = segmentAccuracy(trueTask,segTask)


%Remove zeros from both task segmentations
trueTask = trueTask( trueTask~=0 );
segTask = segTask( segTask~=0 );


%Plot the ground truth and automatic task segmentations
% hold on;
% plot(trueTask,'r');
% plot(segTask,'b');
% hold off;


%Compare the ground truth versus automatically segmented tasks
accVector = (trueTask == segTask);
acc = 100 * numOccur(accVector,1) / length(accVector);