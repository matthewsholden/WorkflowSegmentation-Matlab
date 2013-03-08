%This function will convert a task segmentation in which we have the time
%stamp at which each task starts to a task record in which we have the task
%at each point in time

%Parameter T: Times of task classification
%Parameter transT: Times at which new tasks start
%Parameter transK: Labels of the tasks occurring at each transition

%Return K: The task occurring at each time stamp specified by T
function K = segToTaskData(T,transT,transK)

%If we have any inconsistencies, just return all zeros
if ( size(transT) ~= size(transK) )
    warning('Inconsistent task delineation');
    K = zeros(size(T));
    return;
end%if
if ( isempty(transT) || isempty(transK) || isempty(T) )
    K = zeros(size(T));
    return;
end%if

%Determine the task segmentation interval in which each time stamp occurs
inv = getInterval(transT,T);

%Assign task at time T be transK at the interval corresponding to each T
K = transK(inv);

%Anything outside the first or last transition should be zero
K( T < min(transT) ) = 0;
K( T > max(transT) ) = 0;