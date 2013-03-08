%This function will assign each point in our space to the closest cluster
%using a weighted distance metrics which has already been calculated and is
%passed as an input parameter.

%Parameter dis: A matrix of weighted distances from each point to each
%centroid
%Parameter ix: A vector indicating each point's cluster (previously)

%Return ix: A vector yielding the cluster associated with each point
%Return hasMember: If the cluster has a member associated with it
%Return change: The number of points that have changed cluster this
%iteration
function [ix hasMember change] = assignClusters(dis,ix)

%Calculate the number of points and the number of clusters
[n k] = size(dis);

%Initialize numMember to be a row vector of zeros for each cluster
numMember = zeros(1,k);

%Initialize change to be zero, and we will add as we notice that points
%have changed their cluster
change = 0;

%Determine the smallest distance and assign the point to that
%cluster
[~, ixi] = min(dis,[],2);
%Transpose because we want a row vector
ixi = ixi';
%If we have a different index than previously, indicate that a
%change in clusters has been made
if (~(ixi==ix))
    change = 1;
end
%Set the new cluster index
ix = ixi;
%Note that the cluster is not empty
hasMember = ismember(ixi,1:k) + 1;
