%This function will, given a vector of times and values, integrate the
%function over the given range of times

%Parameter T: The vector of time stamps
%Parameter X: The matrix of values at the corresponding time stamps

%Return I: The result of the definite integral
function I = vectorIntegrate(T,X)

%Use the trapezoidal rule since Simpson's rule requires that the time
%interval be of constant width (which is not necessarily the case). We
%could use a quadratic method, but this would be fairly inefficient, and
%we require a fairly efficient method for implementation in real time...

%First, determine the size of the vectors (which is the same)
n = length(T);

%Create a vector from 1->n-1, and from 2->n
v1 = 1:n-1;
v2 = 2:n;

%Calculate the height and width at each point using the trpaezoidal rule 
%(the height of the interval is the average of the heights of the endpoints)
I = bsxfun(@times, ( T(v2) - T(v1) ), ( X(v2,:) + X(v1,:) ) ) / 2;

%Now, sum over all times (to create a row vector)
I = sum(I,1);