%This function will perform a principal component analysis on a set of data
%to extract the dimensions or linear combination of dimensions that yield
%the largest information about the data

%Parameter X: A matrix of points, where rows corresponds to observations,
%and columns to dimensions

%Return TD: The transformed data into a space in which all of the
%dimensions hold pertinent information about the data
%Return TV: The series of vectors over which we project our original data,
%the transformation vector
%Return MN: The mean of the data in each dimension
function [TD TV MN] = pca(X)

%Determine the dimension of X and the number of observations
[n dim] = size(X);

%Calculate the mean in each dimension
MN = mean(X,1);

%Subtract from each dimension the mean
for i=1:dim
    X(:,i) = X(:,i) - MN(i);
end

%Calculate the covariance matrix for the dimensions
%Use the covariance matrix, not the correlation matrix, as advocated by Cserhati
cv = cov(X);


%Calculate the eigen vectors and eigenvalues of the covariance matrix. Note
%that evalue is the Jordan canonical form of our matrix, but the
%covariance matrix should always have dim real eigenvalues (I think...)
[evector jordan] = eig(cv);

%The vector of eigenvalues will have length dim
evalue = zeros(1,dim);

%Convert the Jordan canonical form into a vector of eigenvalues, since I
%believe the eigenvalues will always be real (and exist). The weighting of
%each dimension will be the eigenvalue
for k=1:dim
    evalue(k) = jordan(k,k);
end
%Flip the eigenvector and eigenvalue vector since we want the eigenvalues
%in order from largest to smallest
evalue = fliplr(evalue);
evector=fliplr(evector);


%Start the feature vector as just the first eigenvector, since this is
%guaranteed to be part of the feature vector
TV = evector(:,1);

%We will choose a stopping rule such that we stop when the rate of
%eigenvalue decrease becomes positive (second derivative negative)

%Matlab automatically orders the eigenvectors in increasing eigenvalue and
%normalizes the eigenvectors
for k=2:dim
    %Calculate the concavity of the eigenvalues. If it is concave down then
    %stop.
    conc = evalue(k-1) - 2*evalue(k) + evalue(k+1);
    %Concatenate the feature vector with the eigenvector
    TV = cat(2,TV,evector(:,k));
    %If it is concave down (the next one) then stop
    if (conc < 0)
        break;
    end
end

%Left multiply the adjusted data by the tranpose of the feature vector
TD = (X * TV);