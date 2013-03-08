%This function will revive empty clusters by making its new centroid the
%point farthest from all other centroids

%Parameter X: Matrix of points in our space that we want to cluster
%Parameter cent: Matrix of cluster centroids in our space
%Parameter numMember: Number members for each cluster (ie some have zeros)

%Return cent: Matrix of cluster centroids after relocating empty clusters
%Return empty: Whether or not empty clusters were relocated
function [cent empty] = moveEmpty(X,cent,numMember)

%Determine the number and dimension of our points in space
[n dim] = size(X);

%Initialize empty to be false
empty = false;

%Iterate over all clusters without members
for j=find(~numMember)
    
    %Calculate the centroid-point distances
    centDis = interDistances( X, cent, W);
    
    %Reassign centroid to be furthest point from all other centroids
    [~, farthest] = max( min( centDis, [], 2 ) );
    
    %Reassign centroid to be the farthest point from previous centroid
    cent(j,:) = X(farthest,:);
    
    %Indicate that there was an empty clusters
    empty = true;
    
end%for