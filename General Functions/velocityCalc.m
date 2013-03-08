%Given the point at which we want to calculate the velocity, calculate it
%using the time interval and values at the adjacent key points.
%If we are at the beginning (ie i=1) use a forward difference formula.
%If we are at the end (ie i=kn) use a backward difference formula.
%Otherwise use a centred difference formula.

%Paratmer T: A vector of times
%Parameter X: A matrix of points in time

%Return V: A vector of velocities at each point in time
function V = velocityCalc(T,X)

%Calculate the number of points we have
n = length(T);

%Initially, assume the the 'otherwise' (centred difference formula) holds
left = (1:n) - 1;
right = (1:n) + 1;

%Now, correct for the endpoints
left(1) = 1;
right(n) = n;

%Now, calculate the velocity using the appropriate difference formula
V = bsxfun(@rdivide, ( X(right,:) - X(left,:) ), ( T(right) - T(left) ) );

