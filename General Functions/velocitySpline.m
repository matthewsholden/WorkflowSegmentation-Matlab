%This function will, given a vector of points and a vector of times at
%which these points are recorded, generate a velocity spline (as described
%by [Murphy 2004]). Note that the splines are dependent on only the 
%position and velocities at their endpoints and do not depend on the spline
%over other intervals

%Parameter T: A vector of points in time
%Parameter X: A vector of points in value, and 
%Parameter t: A vector of points at which we wish to evaluate the spline
%Return x: The value of the spline at the point at which we wish to evaluate
%the spline
function x = velocitySpline(T,X,V,t)

%Calculate the number of point and dofs involved
[~, dof] = size(X);

%First, calculate the interval in which we lie
inv = getInterval3(T,t);

%Now, calculate the point values and velocities at the endpoint of the
%interval
t1=T(inv);        t2=T(inv+1);
p1=X(inv,:);      p2=X(inv+1,:);
v1=V(inv,:);    v2=V(inv+1,:);

%Replicate t1, t2 over all dofs
t1 = repmat(t1,[1 dof]);
t2 = repmat(t2,[1 dof]);

%We have solved this system symbolically using Maple. Now, we just plug in
%the values to the result
A = -(-t1.*v1+2.*p1+t2.*v1+t2.*v2-t1.*v2-2.*p2)./(-t2.^3-3.*t2.*t1.^2+t1.^3+3.*t1.*t2.^2);
B = -1/2*(3.*A.*t1.^2-3.*A.*t2.^2+v2-v1)./(-t2+t1);
C = -3.*A.*t2.^2-2.*B.*t2+v2;
D = -A.*t2.^3-B.*t2.^2-C.*t2+p2;

%Replicate t over all dofs (similar to above with t1,t2)
t = repmat(t,[1 dof]);

%Finally, now that we have solved the linear system for the coefficients of
%the spline, we can easily calculate the value of the spline at the point
%of interest. Use Horner's algorithm
x =( ( A .* t + B ) .* t + C ) .* t + D;