%Given a set of times corresponding to points, calculate the interval of
%times in which test point lies between

%Parameter T: A vector of times, in order
%Parameter testT: The vector of times we want to test the interval of

%Return inv: The interval in which the test point lies
function rinv = getInterval3(T,testT)

%Calculate the number of entries in the T vector
n = length(T);
testn = length(testT);

%The upper and lower bounds on our interval
a = ones(testn,1); b = ones(testn,1)*n;

%Perform a binary search do determine what interval we are in
found = zeros(testn,1);
%Have a value to test our found with
testFound = ones(testn,1);

%Iterate until we have found the appropriate interval
while (found ~= testFound)
    
    %The new test point is halfway between the upper and lower bounds
    inv = (a + b) ./ 2;
    %We will store the rounded interval separately
    rinv = round(inv);
    
    %Get a true/false on the first condition, using vector AND
    tf1 = testT < T(rinv) & (rinv) > 1;
    %And a true/false on the second condition, using vector AND
    tf2 = testT > T(rinv+1) & (rinv+1) < n;
    
    %Now, assign the interval appropriately using vector mulitplication
    b = inv .* tf1;
    a = inv .* tf2;
    
    %Reset our found variable
    found = (~tf1 & ~tf2);
    
end