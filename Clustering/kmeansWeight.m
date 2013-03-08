%This function will perform a kmeans clustering algorithm, using specified
%weighting. Use the fast global k-means algorithm proposed by Likas in
%2003.

%Parameter X: A matrix of data points to cluster; rows correspond to
%points, columns correspond to variables
%Parameter W: The weighting associated with each dimension
%Parameter k: The maximum number of clusters to produce

%Return ix: A vector indicating the cluster index of each point above
%Return C: The locations of the centroids of each cluster
%Return dis: The distance from each point to each cluster
%Return D: A matrix indicating the weighted cluster error for each cluster
function [ix C dis D] = kmeansWeight(X,W,k)

%Keep a vector of centroids from the previous number of clusters
C = zeros(0,size(X,2));
ix = ones(1,size(X,1));
dis = zeros(size(X,1),k);
D = zeros(1,size(X,1));

%We need only calculate the distance between any two points once
disX2 = intraDistances(X,W).^2;



%Iterate over all values of k
for j=1:k
    
    %Calculate the point at which the new centroid will be added
    b = zeros(1,size(X,1));
    %Consider a new centroid at the point with the lth index
    for l=1:size(X,1)
        %The guaranteed error reducation vector b is calculated by
        %iterating over all points
        for m=1:size(X,1)
            %Let improve be the improvement in error between the current
            %centroid and the added centroid
            improve = dis(m,ix(m))^2 - disX2(l,m);
            %For each point, add whichever is larger, the distance to its
            %cluster centroid or the distance to the new centroid
            b(l) = b(l) + max(improve,0);
        end
    end
    
    %The index of the data point at which we will place the next centroid
    %is the index of the maximum b(l)
    new = maxIndex(b);
    
    %Now, calculate the new clustering
    [ix C dis D] = kmeansWeightOne(X,C,W,new);

end




%This function will perform a kmeans clustering algorithm, but normalize
%the variance in each dimension such that no particular dimension is
%favoured

%Parameter X: A matrix of data points to cluster; rows correspond to
%points, columns correspond to variables
%Parameter C: The centroids for the solution to the clustering problem for
%k-1 clusters
%Parameter new: The index of the data point at which the new cluster will
%be located

%Return ix: A vector indicating the cluster index of each point above
%Return C: The locations of the centroids of each cluster
%Return dist: The distance from each data point to each cluster
%Return currDist: A matrix indicating the weighted cluster error for each cluster
function [ix C dis D] = kmeansWeightOne(X,C,W,new)

%Allocate the newest centroid to have location specified by the data point
%with index new
C = cat(1,C,X(new,:));
%Let k be the number of centroids
k = size(C,1);

%Preallocate the cluster index of each point
ix = zeros(1,size(X,1));

%Count the number of iterations required to perform a single kmeans
%clustering
itr = 0;
%The number of points changing centroid
change = -1;
%Whether or not there exist empty clusters
empty = false;

%Now, determine the cluster which is closest to each point
%Now, determine the cluster which is closest to each point
while (change ~= 0 || empty)
    
    %Reset the relevant variables
    itr=itr+1;
    %disp(['Clusters: ', num2str(k), ', Iteration: ', num2str(itr)]);
    
    %First, calculate the cluster to which each point belongs
    dis = interDistances(X,C,W);
    
    %Assign each data point to its cluster
    [ix numMember change] = assignClusters(dis,ix);
    
    %Now, ensure that each cluster has at least one member. If one cluster
    %does not have a member, determine the farthest point from its cluster
    [C empty] = moveEmpty(X,C,dis,ix,numMember);
    
    %Reassign the clusters to their centres if necessary
    if (empty)
        continue;
    end
    
    %Now, find the centroid to each cluster (note that the weighting does
    %not matter)
    C = calcCentroid(X,ix);
    
end

%Calculate the sum of all distances from points to their corresponding
%centroids using the weighting
D = zeros(1,k);

%Iterate over each point and compare to each other point
for i=1:size(X,1)
    %Calculate the distance between each point and its centroid
    D(ix(i)) = D(ix(i)) + dis(i,ix(i))^2;
end


%The error is the difference between the previous sum of squared
%distances and the current
D = sqrt(D);