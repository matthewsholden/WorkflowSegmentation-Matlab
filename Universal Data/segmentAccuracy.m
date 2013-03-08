%This function determines the percentage accuracy of a segmentation by
%comparing the task classification at each time step with the actual task
%being executed

%Parameter trueTask: The ground truth task segmentation
%Parameter segTask: The proposed automatic task segmentation

%Return acc: Accuracy of the automatic task segmentation (percentage)
%Return fullAcc: A matrix of which task is classified as which
%Return extraTrans: Extra transitions occuring in automatic segmentation
function [acc fullAcc extraTrans accDTW ssod n] = segmentAccuracy(trueTask,segTask)

% 0 sigma
window = 0;
% 1 Sigma
%window = 6;
% 2 Sigma
%window = 13;
% 3 Sigma
%window = 19;

%Font size
FONT_SIZE = 36;

%Remove zeros from both task segmentations
maxTask = max( max( trueTask ), max( segTask ) );
numStamps = length(trueTask);


%Plot the ground truth and automatic task segmentations

% figure;
% hold on;
% plot((1:numStamps) / 20, trueTask, 'k','LineWidth',4);
% plot((1:numStamps) / 20, segTask,'g','LineWidth',4);
% xlabel('Time (s)','FontName','Arial','FontSize',FONT_SIZE);
% ylabel('Task','FontName','Arial','FontSize',FONT_SIZE);
% legend('True Segmentation','Automatic Segmentation','Location','NorthWest');
% hold off;
% set(gca,'YTick',[1 2 3 4 5]);
% set(gca,'YTickLabel',[' Translation'; '    Rotation'; '   Insertion'; 'Verification'; '  Retraction']);
% set(gca,'FontName','Arial','FontSize',FONT_SIZE);


% Create a matrix with ground-truth segmentations allowing windowing
trueMatrix = zeros( maxTask, numStamps );
for i = 1:numStamps
    % Add windowing as we go
    for j = -window:window
        if ( i + j > 0 && i + j <= numStamps && trueTask(i) ~= 0 );
            trueMatrix( trueTask(i), i + j ) = 1;
        end
    end
end


% Compare matrices
right = 0;
wrong = 0;
for i = 1:numStamps
    if ( segTask(i) == 0 || trueTask(i) == 0 )
        continue
    end
    if ( trueMatrix( segTask(i), i ) == 1 )
        right = right + 1;
    else
        wrong = wrong + 1;
    end
end

acc = 100 * right / ( right + wrong );

fullAcc = 0;
extraTrans = 0;

goodStamps = (trueTask ~= 0 & segTask ~= 0 );

[dtw ssod n] = accuracyDTW( trueTask(goodStamps) , segTask(goodStamps) );
accDTW = 100 * ( 1 - dtw );

%For each time stamp, find the minimum distance...
totalTime = 0;
for i = 1:numStamps
    %Check the closest time with same task
    closestTime = numStamps;
    for j = 1:numStamps
        %IF we find a closer one...
        if ( trueTask(i) == 0 || segTask(i) == 0 )
            closestTime = 0;
        elseif ( trueTask(j) == segTask(i) && abs(i-j) < closestTime )
            closestTime = abs(i-j);
        end
    end
    totalTime = totalTime + closestTime;
end

accMMD = totalTime / numStamps;


% %Initialize the matrix of zeros
% maxTask = max( max(trueTask), max(segTask) );
% fullAcc = zeros( maxTask, maxTask );
% %Iterate over all time stamps to determine classification matrix
% for i = 1:length(trueTask)
%     %Each time we classify, add the point to the matrix
%     %True task is columns, estimated task is rows
%     fullAcc( segTask(i), trueTask(i) ) = fullAcc( segTask(i), trueTask(i) ) + 1;
% end%for
%
%
% %Also, calculate how many more (supposed) transitions occur in estimation
% extraTrans = numOccur( diff(segTask) ~= 0, 1 ) - numOccur( diff(trueTask) ~= 0, 1 );