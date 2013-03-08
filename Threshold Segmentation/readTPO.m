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
[three kinv two] = size(rawData);

%Also, initialize the stepTXVO
stepValue = zeros(three, kinv, two);

%Now, first assume that the default value is zero, and determine the steps
stepSize = rawData(:,:,1);
stepNum = rawData(:,:,2);

%The steps are calculated assuming the default value for the parameter is
%zero
totalStep=stepSize.*(stepNum-1);

%Now, calculate each step (starting from zero as the lowest value)
%For each threshold parameter
for i=1:3
    %For each task
    for k=1:kinv
        %For each step in the optimization procedure
        for d=1:stepNum(i,k)
            stepValue(i,k,d)=(d-1)*stepSize(i,k);
            %Now, we want to shift based upon the totalStep
            stepValue(i,k,d) = stepValue(i,k,d) - totalStep(i,k)/2;
        end
    end
end

%Now, we had 0 - - - - - - but now we get - - - 0 - - - as the interval