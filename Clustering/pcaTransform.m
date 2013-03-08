%Given the transform vector and the means, this function will transform
%data into the PCA space using the precalculated transformation

%Parameter X: The data that we wish to perform a PCA transform on
%Parameter Trans: The transform vector
%Parameter Mn: The means

%Return TD: The data transformed using this PCA transform
function TD = pcaTransform(X,Trans,Mn)

%First, for each dimension, subtract off the mean
X = bsxfun(@plus,X,Mn); 

%Now apply the transformation vector to the data
TD = (X * Trans);