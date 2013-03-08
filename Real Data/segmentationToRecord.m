%This function will convert a task segmentation in which we have the time
%stamp at which each task starts to a task record in which we have the task
%at each point in time. We should be able to do this fairly readily. Treat
%NaNs as the end of the procedure if a task labelled 'NaN' begins.

%Parameter T: The times at which we want to know what task is being
%completed
%Parameter transT: The times at which new tasks start
%Parameter transK: The labels of the tasks occurring at each transition

%Return K: The task occurring at each time stamp specified by T
function K = segmentationToRecord(T,transT,transK)

%We can use the get interval function here, to determine the task
%segmentation interval in which each time stamp occurs
inv = getInterval3(transT,T);

%Now, we can assign the task at time T be indexing transK at the interval
%corresponding to each T
K = transK(inv);

%But, recall that anything outside the intervals is assigned the first or
%last interval, but in this case we would rather assign them zero, so let's
%do this
K( T < min(transT) ) = 0;
K( T > max(transT) ) = 0;