%Given a set of times corresponding to points, calculate the interval of
%times in which test point lies between. If we are on the border, always
%pick the higher interval/

%Parameter T: A vector of times, in order
%Parameter testT: The vector of times we want to test the interval of

%Return invFound: The interval in which the test point lies
function invFound = getInterval3(T,testT)

%Calculate the number of entries in the T vector
n = length(T);
testn = length(testT);

%The upper and lower bounds on our interval
a = ones(testn,1); b = ones(testn,1)*n;

%Perform a binary search do determine what interval we are in
found = zeros(testn,1);
%Have a value to test our found with
testFound = ones(testn,1);
%The interval values which we have found for our points
invFound = zeros(testn,1);
%Initialize our rounded intervals
finv = zeros(testn,1);      cinv = zeros(testn,1);

%Before we even begin, lump any outliers into the max or min interval
testT(testT > max(T)) = max(T);
testT(testT < min(T)) = min(T);

%Iterate until we have found the appropriate interval
while (~isequal(found,testFound))
    
    %The new test point is halfway between the upper and lower bounds
    inv = (a + b) / 2;
    %We will store the rounded interval separately
    finv = floor(inv) .* (~found) + finv .* found;
    cinv = ceil(inv) .* (~found) + cinv .* found;
    
    %If we have a rinv < 1 or a rinv > n-1 we are in trouble...
    finv(finv < 1) = 1;
    cinv(cinv > n) = n;
    
    %Determine whether we need to shift a or b
    tfa = testT >= T(finv);
    tfb = testT <= T(cinv);
    
    %Shift as needed
    a = inv .* tfa + a .* (~tfa);
    b = inv .* tfb + b .* (~tfb);
    
    %Reset our found variable, which is true if the range encompasses the
    %value and b = a + 1
    found = (testT >= T(finv) & testT <= T(cinv));
    %The interval is equal to a (only if found is true)
    invFound = finv .* found;
    
end