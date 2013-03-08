%Given the point at which we want to calculate the acceleration, calculate it
%using the time interval and values at the adjacent key points.
%If we are at the beginning (ie i=1) use a forward difference formula.
%If we are at the end (ie i=kn) use a backward difference formula.
%Otherwise use a centred difference formula.

%Paratmer T: A vector of times
%Parameter X: A matrix of points in time

%Return A: A vector of velocities at each point in time
function A = accelCalc(T,X)

%Calculate the number of points we have
n = length(T);

%Initially, assume the the 'otherwise' (centred difference formula) holds
left = (1:n) - 1;
centre = (1:n);
right = (1:n) + 1;

%Now, correct for the endpoints
left(1) = 1;
right(n) = n;

%Now, calculate the velocity using the appropriate difference formula
A = bsxfun(@rdivide, ( X(right,:) - 2 * X(centre,:) + X(left,:) ), ( ( T(right) - T(left) ) ./ 2) .^ 2 );

