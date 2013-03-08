%This function will perform a principal component analysis on a set of data
%to extract the dimensions or linear combination of dimensions that yield
%the largest information about the data

%Parameter X: A matrix of points, where rows corresponds to observations,
%and columns to dimensions
%Parameter userComp: The number of principal components we wish to keep

%Return TD: The transformed data into a space in which all of the
%dimensions hold pertinent information about the data
%Return TV: The series of vectors over which we project our original data,
%the transformation vector
%Return MN: The mean of the data in each dimension
function [TD TV MN] = pca(X,userComp)

%Determine the dimension of X and the number of observations
[~, dim] = size(X);


%Calculate the mean in each dimension
MN = mean(X,1);

%Subtract from each dimension the mean
for i=1:dim
    X(:,i) = ( X(:,i) - MN(i) );
end

%Calculate the covariance matrix for the dimensions
%Use the covariance matrix, not the correlation matrix, as advocated by Cserhati
cv = cov(X);


%Calculate the eigen vectors and eigenvalues of the covariance matrix. Note
%that evalue is the Jordan canonical form of our matrix, but the
%covariance matrix should always have dim real eigenvalues (I think...)
[evector jordan] = eig(cv);

%Convert the Jordan canonical form into a vector of eigenvalues, since I
%believe the eigenvalues will always be real (and exist). The weighting of
%each dimension will be the eigenvalue
evalue = diag(jordan);

%Flip the eigenvector and eigenvalue vector since we want the eigenvalues
%in order from largest to smallest
evalue = fliplr(evalue);
evector = fliplr(evector);

%Determine the number of components we should use
numComp = calcComp(evalue,userComp);

%Now, concatenate together the necessary eigenvectors
TV = evector(:,1:numComp);

%Left multiply the adjusted data by the tranpose of the feature vector
TD = (X * TV);