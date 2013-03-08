%This function will determine the number of data points associated with
%each task, given the data object

%Parameter D: A cell array of data objects (with task classification)

%Return taskSizes: A vector of the percentage of data points for each task
function taskSizes = calcTaskSizes(D)

%Concatenate all of the data objects together
D_Cat = Data([],[],[],[]);

for p = 1:length(D)
        D_Cat = D_Cat.concatenate( D{p} );
end%for

%First, determine the number of tasks present
numTask = max(D_Cat.K);

%Use the num occur function do determine how many times each task occurs
taskSizes = numOccur( D_Cat.K, 1:numTask );

%Calculate each task size as a percentage of the whole
taskSizes = taskSizes / sum(taskSizes);