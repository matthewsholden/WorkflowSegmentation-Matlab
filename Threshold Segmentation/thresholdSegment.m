%This function will read a procedure record from file and determine what
%task the trainee is executing for each point in time, we can write the
%annotated procedure to file...

%Parameter D: A data object storing the appropriate procedural record
%Parameter TP: The thresholding parameters

%Return task: The task segmentation of the procedure using the thresholds
function K = thresholdSegment(D,TP)

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%The number of time steps and the number of degrees of freedom are given by
%the size of the vector X
[n dof] = size(D.X);

%Also, import the LPPlan data to determine where the insertion point is
ET = o.read('ET');
%Separate the entry-target points into the entry and target individually
Entry = ET(1,:);
Target = ET(2,:);

%Now, if the user has supplied a TP matrix then do not read it from file,
%but if they have, then we must read it from file
if (nargin < 2)
    TP = o.read('TP');
end

%Ok, so now we go through each time step and determine what task is
%currently being executed

%Note that at the first time step, we will assume that the zeroth point is
%the same as the first point

%Create a vector to store the task segmentation at each time step
K = zeros(n,1);


%Now, go through each time step and determine which task is being executed
%using the get task function
for j=1:n
    
    %Also, determine the current velocity (using the degrees of freedom for
    %the previous time step)
    %If we are at the first time step, let V be zero
    if (j == 1)
        V = zeros(2,dof);
    else
        V=velocityCalc(D.T(j-1:j),D.X(j-1:j,:));
    end
    
    %We need to indicate what was the previous task to help identify what
    %the next task is
    %At the first time step, assume the previous task was the first task
    if (j == 1)
        prevTask = 1;
    else
        prevTask = K(j-1);
    end
    
    %Now, determine which task is the one that is currently being executed
    K(j) = getTask(D.X(j,:),V(2,:),prevTask,Entry,Target,TP);
end