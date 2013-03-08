%This function will perform a nearest neighbour clustering algorithm. For
%each cluster, find the closest point and merge the two clusters.

%Parameter X: A set of points that we wish to cluster
%Parameter W: The weighting associated with each dimension
%Parameter ix: The cluster associated with each point of training data
%Parameter new: A matrix specifying the locations of test points we want to
%classify using the clustering

%Return cluster: A vector indicating the cluster index of each test point
function clust = clusternnFind(N,X,W,ix)

%And determine the size of our matrix of new points
[n dof] = size(N);

%Initialize our vector of clusters
clust = zeros(1,n);

%Calculate a matrix with the distance between each pair of points, using
%the specified weighting
dis = interDistances(X,N,W);

%Iterate over all new points, and determine what point they are closest to,
%and thus, what cluster it corresponds to
for j=1:n
   %Find the minimum index of distance between the current point we want to
   %add, and the closest point to it
   clust(j) = ix(minIndex(dis(:,j)));
   
end
