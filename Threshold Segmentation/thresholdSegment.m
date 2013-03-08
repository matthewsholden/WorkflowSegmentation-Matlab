%This function will read a procedure record from file and determine what
%task the trainee is executing for each point in time, we can write the
%annotated procedure to file...

%Parameter num: The procedure number to perform a threshold segmentation on
%Parameter TP: The thresholding parameters

%Return task: The task segmentation of the procedure using the thresholds
function task = thresholdSegment(num,TP)

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, import the necessary task record from file
[T X] = readProcedure();
%Only use the specified procedure
T = T{num};
X = X{num};

%The number of time steps and the number of degrees of freedom are given by
%the size of the vector X
[dof n] = size(X);

%Also, import the LPPlan data to determine where the insertion point is
ET = o.read('ET');

%Now, if the user has supplied a TXV matrix then do not read it from file,
%but if they have, then we must read it from file
if (nargin < 2)
    TP = o.read('TP');
end

%Now, create a vector indicating the task number at each time step
task = zeros(1,n);

%Ok, so now we go through each time step and determine what task is
%currently being executed

%Note that at the first time step, we will assume that the zeroth point is
%the same as the first point

%Declare a variable which will keep track of the number of velocities we
%wish to compute (nothing to do with size of list)
calc = 1;

%Initialize our initial arrays
initTL=zeros(1,n+calc);
initXL=zeros(dof,n+calc);

%Create the initial arrays of data
%Add the points at the initial position to pad the data
initTL(1,1:calc) = T(1);
for i=1:dof
    initXL(i,1:calc) = X(i,1);
end
%Now, add the rest of the points
initTL(1,(calc+1):end)=T(1:end);
for i=1:dof
    initXL(i,(calc+1):end) = X(i,1:end);
end



%We will use a list to keep track of our values...
tl = dataList(n+calc,initTL(1,:));
%Now, go through all degrees of freedom. Each will have an associated list
%to store the time history (up to 2 points in this case)
for i=1:dof
    xl(i,1) = dataList(n+calc,initXL(i,:));
end


%Now, go through each time step and determine which task is being executed
%using the get task function
for j=1:n
    
    %Keep a reference to the most recent point (since this will yield the
    %value for the degree of freedom)
    currT=T(j);
    currX=X(:,j);
    %Also, determine the current velocity (using all previous ones)
    currV=velocityCalc(tl,xl,j,calc);
    
    %We need to indicate what was the previous task to help identify what
    %the next task is
    if (j == 1)
        prev=1;
    else
        prev=task(j-1);
    end
    
    %Now, determine which task is the one that is currently being executed
    task(j) = getTask(currX,currV(:,end),prev,ET,TP);
end


%This function takes a list of times and a list of data points and
%calculates the velocity at each point in time using a backward difference
%formula

%Parameter tl: A list of times
%Parameter xl: A vector of lists of data points in various degreees of
%freedom

%Return v: A vector of velocities at each point in time
function v = velocityCalc(tl,xl,j,calc)

%Determine the size of xl to figure out how many degrees of freedom we are
%working with
[dof one] = size(xl);

%Now, determine the number of entries we are storing in our lists
v = zeros(dof,calc);

%Now, for each degree of freedom
for i=1:dof
    
    %For each pair of values in the list
    for d=j:(j+calc-1)
        %Whatever the current time step value was, this will now be the
        %previous value
        x1 = xl(i).elementAt(d);
        t1 = tl.elementAt(d);
        %Retrieve the current time step value from the appropriate queue
        x2 = xl(i).elementAt(d+1);
        t2 = tl.elementAt(d+1);
        
        %Now that we have two points, calculate the velocity
        v(i,1+(d-j)) = (x2 - x1)/(t2 - t1);
    end
   
end

