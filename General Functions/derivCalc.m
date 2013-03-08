%Given the point at which we want to calculate the derivative, calculate it
%using the time interval and values at the adjacent key points.
%If we are at the beginning (ie i=1) use a forward difference formula.
%If we are at the end (ie i=kn) use a backward difference formula.
%Otherwise use a centred difference formula.

%Paratmer T: A vector of times
%Parameter X: A matrix of points in time

%Return V: A vector of velocities at each point in time
function D = derivCalc(T,X,order)

%Calculate the number of points we have
n = length(T);

%Initially, assume the the 'otherwise' (centred difference formula) holds
left = (1:n) - 1;
right = (1:n) + 1;

%Now, correct for the endpoints
left(1) = 1;
right(n) = n;

%Now, calculate the derivative using the appropriate difference formula
D = bsxfun(@rdivide, ( X(right,:) - X(left,:) ), ( T(right) - T(left) ) );

%Now, higher order
if (order > 1)
    D = derivCalc(T,D,order-1);
end%if

