%This function will segment the task automatically, and adjust parameters
%such that the segmentation is the most accurate possible segmentation
%using the known segmentation. We want to show that the more sophisticated
%classifier does better than the best possible segmentation of this type
%(especially for noisy data)

%Parameter itr: The number of iterations of optimization that will occur
%(note that each automatic task segmentation takes approximately 0.5 seconds)
%Parameter num: The procedure number to perform a threshold segmentation on

%Return task: The optimal segmentation of the procedure
function [task TP] = thresholdSegmentOptimize(num,itr)

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, read from file the group assignments, the threshold distances and
%the threshold points
TP = o.read('TPOriginal');
[stepNum stepValue] = readTPO();

%The segment accuracy procedure already reads the data from file

%We can determine the number of tasks and the number of degrees of freedom
%from the size of the threshold matrices
[thresh kinv] = size(TP);

%Iterate the desired number of times...
for it=1:itr
    %For each iteration, we want to determine the threshold parameters
    origTP = TP;
    %For the given task
    for k=1:kinv
        %For the given threshold value (ie skin thickness, position, velocity)
        for i=1:thresh
            %Determine the default task segmentation accuracy between the actual
            %segmentation and the automatic segmentation
            task=thresholdSegment(num,origTP);
            acc=segmentAccuracy(num,task);
            %By default, let the current value be optimal
            optTP=origTP(i,k);
            %Iterate over all ranges in the threshold distance
            for step=1:stepNum
                %Rewrite the TVX matrix, with the value we are testing
                %for optimality
                TP(i,k) = origTP(i,k) + stepValue(i,k,step);
                %Determine the task segmentation accuracy between the actual
                %segmentation and defualt segmentation
                task=thresholdSegment(num,TP);
                %If the current threshold parameters produce a better
                %segmentation than any of the previous threshold distances then
                %assign the accuracy to be the new, better one
                if (segmentAccuracy(num,task) > acc)
                    acc=segmentAccuracy(num,task);
                    optTP=TP(i,k);
                end
            end
            %Once we have determined the optimal threshold parameter, then
            %finally write this to file
            TP(i,k)=optTP;
        end
    end
end

%Now that we have optimize the threshold parameters, write them to file
o.write('TP',TP);

%Now that we have finally calculated the optimal threshold parameters, find
%the task segmentation
task=thresholdSegment(num,TP);

%Display the accuracy of the segmentation with the optimal parameter values
segmentAccuracy(num,task);

