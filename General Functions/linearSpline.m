%This function will, given a vector of points and a vector of times at
%which these points are recorded, generate a linear spline

%Parameters: A vector of points in time, a vector of points in value, and a
%point at which we wish to evaluate the spline
%Return: The value of the spline at the point at which we wish to evaluate
%the spline
function x = linearSpline(kt,kp,ti)

%Note that the splines are dependent on only the positions at
%their endpoints and do not depend on the spline over other intervals

%Calculate the number of key points we have
kn = length(kt);
ki=0;

%First, calculate the interval in which we lie
%Just use a linear search of kt to find the times between which the point
%lies
%i will be the interval number in which the point of interest resides
for j=1:(kn-1)
    %If we are between the current and next point then this is the interval
    %index the point resides in and we will use for the spline
    if ( ti >= kt(j) && ti <= kt(j+1) )
        ki=j;
    end
end

%Now, calculate the point values at the endpoint of the
%interval
t1=kt(ki);                     t2=kt(ki+1);
p1=kp(ki);                     p2=kp(ki+1);

%Now that we have the correct positions, construct the time matrix, which
%we can use along with a vector of positions to solve for
%the coefficient vector
%Time matrix T
T(1,1)=t1;        T(1,2)=1;
T(2,1)=t2;        T(2,2)=1;

%Next, we will setup the position vector P
P(1)=p1;            P(2)=p2;

%Now, solve this linear system, and we will call the solution vector aa
A=linsolve(T,P');

%Finally, now that we have solved the linear system for the coefficients of
%the spline, we can easily calculate the value of the spline at the point
%of interest
x=A(1)*ti+A(2);