%Given a set of times corresponding to points, calculate the interval of
%times in which test point lies between

%Parameter endPoints: A vector of end points
%Parameter test: A vector of test points to find the interval

%Return inv: The interval in which the test points lie
function inv = getInterval(endPoints,testPoints)

%The number of time points and test points
numEndPoints = length(endPoints);
numTestPoints = length(testPoints);


%Replicate the matrics for comparison
endPointsRep = repmat( endPoints, 1, numTestPoints);
testPointsRep = repmat( testPoints', numEndPoints, 1);


%Determine the matrix of intervals
%Note, classify in upper interval if on border
invMatrix = endPointsRep < testPointsRep;


%Create a matrix of interval labels
invVector = ones( 1, numEndPoints);


%The intervals are the product of this vector with the invMatrix
inv = (invVector * invMatrix)';


%Ensure that everything is within some interval
inv(inv==numEndPoints) = numEndPoints - 1;
inv(inv<=0) = 1;