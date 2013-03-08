%This function will increment a parameter in the task segmentation
%algorithm, to determine the optimal parameter value

%Parameter paramName: The name of the parameter we are optimzing
%Parameter param: A cell array of parameters we wish to test

%Return acc: A cell array of workflow segmentation accuracies
function acc = optimizeParam(paramName,param)

%Create an organizer object
o = Organizer();

%The number of parameter values
numVal = length(param);
acc = cell(size(param));

%Iterate over all parameter values
for i = 1:numVal
    %Assign the current accuracy to be empty
    currAcc = [];
    %Write the latest value of the parameter
    o.write(paramName,param{i});    
    %Perform the segmentation of the epidural procedure
    currAcc = cat(1, currAcc, segmentEpiduralType('Novice','CL') );
    currAcc = cat(1, currAcc, segmentEpiduralType('Novice','CR') );
    %Add this accuracy to the cell array of accuracies
    acc{i} = currAcc;
    %Display the current accuracy
    currAcc
end%for