%This function will calculate a fast kmeans algorithm by iteratively adding
%centroids. The mean of the data set will be taken as the first centroid,
%the farthest point from all centroids will be taken as succeeding
%centroids

%Parameter X: Matrix of data points. rows = points, columns = variables
%Parameter k: Number of clusters (k)
%Parameter W: Weight associated with each dimension

%Return ix: A vector indicating the cluster index of each point
%Return cent: The locations of the centroids of each cluster
%Return centDis: The distance from each point to each cluster
%Return SSD: Sum of squared distances from each centroid to its points
%Return clout: The clout (number of clustands) for each centroid
function [ix cent centDis SSD clout] = fwdkmeans(X,k,W)

%If the weighting is not specified, assume equal weighting
if (nargin < 3)
    W = ones( 1, size(X,2) );
end%if

%Preallocate the output parameters
ix = ones(1,size(X,1));
cent = zeros(0,size(X,2));

%Iterate, adding all k centroids to clustering
for j=1:k
    
    %Choose the farthest point if we have centroids, mean if we don't
    if (isempty(cent))
        %Find the mean of the data
        testCent = mean(X,1);
        %Find the distance from each point to the test centroid
        centDis = interDistances(X,testCent,W);
        %Choose the closest point to be the next centroid
        [~, newCent] = min( centDis );
    else
        %Choose the furthest point to be the next centroid
        [~, newCent] = max( min( centDis, [], 2 ) );
    end%if
    
    %Now, calculate the new clustering
    [ix cent centDis] = fwdkmeansLast(X,cent,W,newCent);

end%for

%Calculate the distance from each point to each cluster
centDis = interDistances( X, cent, W);

%Calculate the sum of squared distances from each centroid to its points
SSD = min( centDis, [], 2);
SSD = sqrt( sum( SSD .^ 2 ) );

%Calculate the clout for each point
clout = numOccur(ix,1:k) / size(X,1);



%This function will perform a kmeans clustering algorithm, given the
%location of the new point we wish to add

%Parameter X: Matrix of data points. rows = points, columns = variables
%Parameter cent: Centroids for k-1 clusters
%Parameter W: Weight associated with each dimension
%Parameter newCent: The index of the point which is the new cluster

%Return ix: A vector indicating the cluster index of each point
%Return cent: The locations of the centroids of each cluster
%Return centDis: The distance from each point to each cluster
%Return SSD: Sum of squared distances from each centroid to its points
function [ix cent centDis] = fwdkmeansLast(X,cent,W,newCent)

%Allocate the newest centroid to have location specified by the data point
%with index new
cent = cat( 1, cent, X(newCent,:) );

%Preallocate the cluster index of each point
ix = zeros(1,size(X,1));

%The number of points changing centroid
change = -1;
%Whether or not there exist empty clusters
empty = false;

%Now, determine the cluster which is closest to each point
while (change ~= 0 || empty)
    
    %Calculate the cluster to which each point currently belongs
    centDis = interDistances( X, cent, W);
    
    %Assign each data point to its cluster
    [ix numMember change] = assignClusters(centDis,ix);
    
    %Ensure that each cluster has at least one member
    %Otherwise, reassign centroid to point farthest from all centroids
    [cent empty] = moveEmpty(X,cent,numMember);
    
    %Reassign the clusters to their centres if necessary
    if (empty)
        continue;
    end
    
    %Now, find the centroid to each cluster (note that the weighting does
    %not matter)
    cent = calcCentroid(X,ix);
    
end%while