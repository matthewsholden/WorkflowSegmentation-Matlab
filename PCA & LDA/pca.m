%This function will perform a principal component analysis on a set of data
%to extract the dimensions or linear combination of dimensions that yield
%the largest information about the data

%Parameter X: A matrix of data observations
%Parameter userComp: The number of principal components we wish to keep

%Return X_Trans: PCA transformed data, where variance is maximized
%Return Trans: The projection vectors of the data
%Return Mn: The mean of the data in each dimension
function [X_Trans Trans Mn] = pca(X,numComp)

%Determine the dimension of X and the number of observations
[~, dim] = size(X);

%Calculate the mean in each dimension
Mn = mean(X,1);

%Subtract from each dimension the mean
for i=1:dim
    X(:,i) = ( X(:,i) - Mn(i) );
end

%Calculate the covariance matrix for the dimensions
%Use the covariance matrix, not the correlation matrix [Cserhati 1991]
cv = cov(X);

%Calculate the eigen vectors and eigenvalues of the covariance matrix
%This returns the Jordan canonical form of the matrix
[evector jordan] = eig(cv);

%Convert the Jordan canonical form into a vector of eigenvalues
evalue = diag(jordan);

%Order the eigenvalues and eigenvectors from largest to smallest
[~, eix] = sort( evalue, 'descend' );
Trans = evector( :, eix(1:numComp) );

%Left multiply the data by the transformation matrix
X_Trans = X * Trans;