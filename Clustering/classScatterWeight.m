%This function computes a clustering weighting scheme to maximize the ratio
%of between-class to within-class variance

%Parameter X: A cell array of data classes to be clustered

%Return W: The weighting associated with each dimension of the space
function W = classScatterWeight(X)


%Count the number of classes
numClass = length(X);


%Calculate the mean of each class of data
Mn = [];
%Iterate over all classes and find the mean of each one
for j=1:numClass
    Mn = cat( 1, Mn, mean( X{j}, 1 ) );
end%for


%Calculate the class mean variance (between-class scatter)
SB = std( Mn, 1);


%Calculate the average within class variance
SW = 0;
for j=1:numClass
    SW = SW + std( X{j}, 1);
end%for


%Weighting is ratio of inter class variance to intra class variance
W = SB ./ SW;


%Normalize weighting
W = normr(W);
