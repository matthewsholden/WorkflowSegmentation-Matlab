%This function will read a procedure record from file and determine what
%task the trainee is executing for each point in time, we can write the
%annotated procedure to file...

%Return status: Whether or not the function is done segmenting the
%procedure into tasks
function task = thresholdSegmentRT(T,X,prev,depth,ET,TP)

%Declare a variable which will keep track of the number of velocities we
%wish to compute (nothing to do with size of list)
calc = 1;

%Determine the size of the data we have
[dof n] = size(X);

%Presumably we should preeallocate these lists for efficiency, but it
%seems there is no way to initialize an array of objects...
%tq=0;
%xq=zeros(dof,1);

%We will use a list to keep track of our values...
tl = dataList(calc);
%Now, go through all degrees of freedom. Each will have an associated list
%to store the time history (up to 2 points in this case)
for i=1:dof
    xl(i,1) = dataList(calc);
end

%Now, suppose we want to create a list of 'calc' values, then we need to
%add all values from the array of points, but, if we do not have enough
%points, just add the first point continually
for d=0:calc
    %If we have enough data points, then...
    if (n > d)
        tl = tl.addRear(T(n-d));
        %Additionally, for each degree of freedom
        for i=1:dof
            xl(i,1) = xl(i,1).addRear(X(i,n-d));
        end
        %Otherwise, we have to add the first point continually
    else
        tl = tl.addRear(T(1));
        %Additionally, for each degree of freedom
        for i=1:dof
            xl(i,1) = xl(i,1).addRear(X(i,1));
        end
        
    end
    
end


%Keep a reference to the most recent point (since this will yield the
%value for the degree of freedom)
currT=T(n);
currX=X(:,n);
%Also, determine the current velocity (using all previous ones)
currV=velocityCalc(tl,xl,calc);

%Now, determine which task is the one that is currently being executed
task = getTask(currX,currV(:,end),prev,depth,ET,TP);



%This function takes a list of times and a list of data points and
%calculates the velocity at each point in time using a backward difference
%formula

%Parameter tl: A list of times
%Parameter xl: A vector of lists of data points in various degreees of
%freedom

%Return v: A vector of velocities at each point in time
function v = velocityCalc(tl,xl,calc)

%Determine the size of xl to figure out how many degrees of freedom we are
%working with
[dof one] = size(xl);

%Now, determine the number of entries we are storing in our lists
store = tl.getSize();
v = zeros(dof,calc);

%Now, for each degree of freedom
for i=1:dof
    
    %For each pair of values in the list
    for d=(store-calc):(store-1)
        %Whatever the current time step value was, this will now be the
        %previous value
        x1 = xl(i).elementAt(d);
        t1 = tl.elementAt(d);
        %Retrieve the current time step value from the appropriate queue
        x2 = xl(i).elementAt(d+1);
        t2 = tl.elementAt(d+1);
        
        %Now that we have two points, calculate the velocity
        v(i , 1+(d-(store-calc)) ) = (x2 - x1)/(t2 - t1);
    end
    
end


