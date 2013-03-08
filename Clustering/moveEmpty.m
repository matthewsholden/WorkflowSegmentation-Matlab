%This function will be responsible for reviving empty clusters. This will
%be accomplished by making the centroid of any empty cluster to be the
%point that is farthest from its cluster centroid.

%Parameter X: A matrix of points in our space that we want to cluster
%Parameter C: A matrix of cluster centroids in our space
%Parameter dis: A matrix of weighted distances from each point to each
%centroid
%Parameter ix: The cluster index associated witheach point in our space
%Parameter numMember: The number of members each cluster has (we are
%particularly interested in clusters with zero members)

%Return C: A matrix of cluster centroids after we have relocated the empty
%clusters
%Return empty: Whether or not there were any empty clusters which we had to
%relocate
function [C empty] = moveEmpty(X,C,dis,ix,numMember)

%Determine the number and dimension of our points in space
[n dim] = size(X);

%Initialize empty to be false
empty = false;

%Iterate over all clusters without members
for j=find(~numMember)
    
    %If the cluser does not have any members, determine the point
    %farthest from its cluster
    farthest = 1;
    farDist = 0;
    
    %Iterate over each point
    for i=1:n
        %Determine the point farthest from its cluster
        if (dis(i,ix(i)) > farDist)
            farthest = i;
            farDist = dis(i,ix(i));
        end
    end
    
    %Determine the largest distance and assign the cluster to be at
    %the corresponding point
    C(j,:) = X(farthest,:);
    
    %Replace the index of this point such that no more empty clusters
    %are sent to this point
    ix(farthest) = j;
    
    %Indicate that there was an empty clusters
    empty = true;
end