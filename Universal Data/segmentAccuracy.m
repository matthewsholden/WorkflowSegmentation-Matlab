%This function determines the percentage accuracy of a segmentation by
%comparing the task classification at each time step with the actual task
%being executed

%Parameter trueTask: The ground truth task segmentation
%Parameter segTask: The proposed automatic task segmentation

%Return acc: Accuracy of the automatic task segmentation (percentage)
%Return fullAcc: A matrix of which task is classified as which
%Return extraTrans: Extra transitions occuring in automatic segmentation
function [acc fullAcc extraTrans] = segmentAccuracy(trueTask,segTask)


%Remove zeros from both task segmentations
trueTask = trueTask( trueTask~=0 );
segTask = segTask( segTask~=0 );


%Plot the ground truth and automatic task segmentations
figure;
hold on;
plot(trueTask,'k','LineWidth',2);
plot(segTask,'g','LineWidth',2);
xlabel('Time Stamp');
ylabel('Task');
legend('True Segmentation','Automatic Segmentation','Location','NorthWest');
hold off;
set(gca,'YTick',[1 2 3 4 5]);


%Compare the ground truth versus automatically segmented tasks
accVector = (trueTask == segTask);
acc = 100 * numOccur(accVector,1) / length(accVector);


%Initialize the matrix of zeros
maxTask = max( max(trueTask), max(segTask) ); 
fullAcc = zeros( maxTask, maxTask );
%Iterate over all time stamps to determine classification matrix
for i = 1:length(trueTask)
    %Each time we classify, add the point to the matrix
    %True task is columns, estimated task is rows
    fullAcc( segTask(i), trueTask(i) ) = fullAcc( segTask(i), trueTask(i) ) + 1;
end%for


%Also, calculate how many more (supposed) transitions occur in estimation
extraTrans = numOccur( diff(segTask) ~= 0, 1 ) - numOccur( diff(trueTask) ~= 0, 1 );