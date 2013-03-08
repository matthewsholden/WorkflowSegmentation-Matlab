%This function will be responsible for reading a threshold distance
%iteration step from file and returning it to the calling function

%Parameter fileName: The name of the file in which the optimal threshold
%parameter stepper is found

%Return stepTXVO: A matrix containing vectors each with values of the
%parameter which should be tried
function [stepNum stepValue] = readTPO()

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, use a dlmread on the file to get a matrix with all of the values in
%the file
rawData = o.read('TPO');

%The number of keypoints and degrees of freedom
%There are three threshold parameters for each task (thickness, position,
%velocity), kinv number of intervals and two (step number, step size)
[maxTask] = size(rawData,2);

%Also, initialize the stepValue. Note that we have three as the first
%parameter because each task has three parameters associated with its
%threshold.
stepValue = cell(3,maxTask);

%Now, first assume that the default value is zero, and determine the steps
stepSize = rawData(:,:,1);
stepNum = rawData(:,:,2);

%Calculate the total range over which all steps cover
totalStep = stepSize .* (stepNum - 1);

%Now, calculate each value that we will test the parameter on
%For each threshold parameter
for p=1:3
    %For each task
    for k=1:maxTask
        
        %Initialize the stepValue cell array entry to be a vector of the
        %appropriate length
        stepValue{p,k} = zeros(1,stepNum(p,k));
        
        %For each step in the optimization procedure
        for d=1:stepNum(p,k)
            
            %Calculate the value of the parameter at each step
            stepValue{p,k}(d) = (d-1) * stepSize(p,k);
            
        end
        
        %Shift all the values such that the default parameter
        %value is in the middle of the range of steps
        stepValue{p,k} = stepValue{p,k} - totalStep(p,k)/2;
        
    end
    
end

%Now, we had 0 - - - - - - but now we get - - - 0 - - - as the interval