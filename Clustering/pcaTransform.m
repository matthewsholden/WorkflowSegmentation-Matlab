%Given the transform vector and the means, this function will transform
%data into the PCA space using the precalculated transformation

%Parameter X: The data that we wish to perform a PCA transform on
%Parameter TV: The transform vector
%Parameter MN: The means

%Return TD: The data transformed using this PCA transform
function TD = pcaTransform(X,TV,MN)

%Calculate the dimensions and the number of points
[n dim] = size(X);

%First, for each dimension, subtract off the mean
for i=1:dim
   X(:,i) = X(:,i) - MN(i); 
end

%Now apply the transformation vector to the data
TD = (X * TV);