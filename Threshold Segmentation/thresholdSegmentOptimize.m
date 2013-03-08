%This function will segment the task automatically, and adjust parameters
%such that the segmentation is the most accurate possible segmentation
%using the known segmentation. We want to show that the more sophisticated
%classifier does better than the best possible segmentation of this type
%(especially for noisy data)

%Parameter num: The procedure number to perform a threshold segmentation on
%Parameter itr: The number of iterations of optimization that will occur
%(note that each automatic task segmentation takes approximately 0.5 seconds)

%Return K: The optimal segmentation of the procedure
function K = thresholdSegmentOptimize(num,itr)

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, read from file the group assignments, the threshold distances and
%the threshold points
TP = o.read('TP');
TP_Stat = TP;
[stepNum stepValue] = readTP_Opt();

%Read the procedural record from file
D = readRecord();
D = D{num};

%We can determine the number of tasks and the number of degrees of freedom
%from the size of the threshold matrices
[maxTask] = size(TP,2);

%Iterate the desired number of times...
for it=1:itr
    
    %For the given task
    for k=1:maxTask
        
        %For the given threshold value (ie skin thickness, position, velocity)
        for i=1:3
            
            %Determine the default task segmentation accuracy
            K = thresholdSegment(D,TP);
            acc = segmentAccuracy(num,K);
            
            %By default, assume the current value to be optimal
            TP_Opt = TP(i,k);
            
            %Iterate over all ranges in the threshold distance
            for step=1:stepNum(i,k)
                
                %Change the value of the threshold parameter to the step
                %value we are testing
                TP(i,k) = TP_Stat(i,k) + stepValue{i,k}(step);
                
                %Determine the task segmentation with new the value
                K = thresholdSegment(D,TP);
                
                %If the current parameters produce a better accuracy
                %segmentation, then they are optimal
                if ( segmentAccuracy(num,K) > acc )
                     %Calculate the new accuracy
                    acc=segmentAccuracy(num,K);
                    %Save the new optimal parameter
                    TP_Opt = TP(i,k);
                end
                
            end
            
            %Now that we have determined the optimal paramter, put this
            %back into our matrix of parameters
            TP(i,k) = TP_Opt;
            %Update the static threshold parameters also
            TP_Stat = TP;
            
        end %Parameters 1,2,3 (thickness,position,velocity)
        
    end %Tasks
    
end %Iterating

%Now that we have optimize the threshold parameters, write them to file
o.write('TP',TP);

%Now that we have finally calculated the optimal threshold parameters, find
%the task segmentation
K = thresholdSegment(D,TP);

%Display the accuracy of the segmentation with the optimal parameter values
segmentAccuracy(num,K);

