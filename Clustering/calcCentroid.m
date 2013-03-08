%This function will calculate the centroids of the clustering given the
%memberships of each of the points.

%Parameter X: A matrix of points in our space
%Parameter ix: A vector indicating the cluster membership of each point in
%our space

%Return C: The centroid of each cluster
function C = calcCentroid(X,ix)

%The number of centroids is the maximum cluster index, since we have
%ensured that all cluster have at least one member
k = max(ix);
%Determine the size of our matrix of points
[n dim] = size(X);
%Initialize the size of our matrix of cluster centroids
C = zeros(k,dim);

%Iterate over all clusters
for j=1:k
    %Add the unweighted distance (since weighting does not matter)
    C(j,:) = mean(X(ix==j,:),1);
end