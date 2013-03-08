%Suppose we have a complete procedural record. We want determine every
%point in the lower-dimensional space produced by this procedure.

%Parameter filename: The name of the file from which we will read the
%procedural record

%Return LDPoint: A matrix where each row represents a point in the lower
%dimensional space
function [LD TD TaskD] = LDTransform(T,X,Task,LDParam)

%Determine the size of the matrix of X
[n dof] = size(X);

%Also, read the parameters relevant to determining the points in lower
%dimensional space from file if they haven't already been passed in
if (nargin < 4)
    %Create an organizer
    o = Organizer();
    %Read from file the parameters
    LDParam = o.read('LD');
end

%Assign the LD parameters their names
elapse = LDParam(1);
history = LDParam(2);
interp = LDParam(3);
order = LDParam(4);
retain = LDParam(5);

%Calculate the number of procjected data points that will result
nD = round(n/elapse - history);
%Calculate the dimension of the lower dimensional space
dim = (order+1)*dof;

%Use a format similar to the thresholdSegment procedure (but we will not
%need to calculate velocities for this)
LD = zeros(nD,dim);
TD = zeros(nD,1);
TaskD = zeros(nD,1);

%Preallocate the size of the t and x arrays
x = zeros(dof,interp);

%Intialize j to be zero (number of projections)
projs=0;
%Initialize k to be the history minus the elapse (since elapse time steps
%will occur prior to our first projection)
steps=history-elapse;
%Keep a count of how many time steps have elapsed
elapseCount=0;


%k will indicate the time step at which we are
%j will indicate the projection number at which we are
while (steps < n)
    %Increment the count of total time steps (k)
    steps = steps + 1;
    %Increment the count of elapsed time steps
    elapseCount = elapseCount + 1;
    
    %Only do anything when the count equals the number of required elapsed
    %time steps between projections
    if (elapseCount == elapse)
        
        %Increment the count of total projections in LD space (j)
        projs = projs + 1;
        
        %Calculate the points we will use to determine the spline. minHist
        %and maxHist indicate the points that are the maximum and minimum
        %index.
        minHist = steps - history + 1;
        maxHist = steps;
        
        %Now, iterate over all interp points and determine the times at
        %which these points shall occur
        t = splitInterval(T(minHist),T(maxHist),interp);
        
        %Now iterate over all degrees of freedom
        for i=1:dof
            %For each interp point
            for l=1:interp
                %Calculate the value of the degree of freedom at the interp
                %points using a velocity spline interpolation
                x(i,l) = velocitySpline(T(minHist:maxHist),X(i,minHist:maxHist),t(l));
            end
        end
        
        %Finally, we can perform a submotion transform on these interp data
        LD(projs,:) = submotionTransform(t,x,order);
        TD(projs) = T(maxHist);
        TaskD(projs) = Task(maxHist);
        
        %Reset the count variable for the number of elapsed time steps
        elapseCount = 0;
    end
    
end