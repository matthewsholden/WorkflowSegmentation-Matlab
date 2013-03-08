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

%Determine the size of our input points
[n dim] = size(X);
%Create a vector counting the number of points
v=1:n;

%Keep a vector of centroids from the previous number of clusters
C = zeros(0,size(X,2));
ix = ones(1,size(X,1));
dis = zeros(size(X,1),k);
D = zeros(1,size(X,1));

%We need only calculate the distance between any two points once
disX2 = interDistances(X,X,W) .^ 2;

%Iterate over all values of k
for j=1:k
    
    %disp (['Clusters: ', num2str(j) ]);
    
    %First, calculate the distance from each point to its centroid
    %Find the linear index corresponding
    lix = sub2ind(size(dis),v,ix(v));
    %Next, calculate the vector of corresponding points
    disXC2 = dis(lix).^2;
    %Calculate the improvement at each point using bsxfun
    improve = bsxfun(@minus,disXC2,disX2);
    %Next, assign zero if improve has any elements less than zero
    improve = max(improve,0);
    %Finally, determine the improvement for each point
    b = sum(improve,2);
    
    %The index of the data point at which we will place the next centroid
    %is the index of the maximum b(l)
    [~, new] = max(b);
    
    %Now, calculate the new clustering
    [ix C dis D] = kmeansWeightOne(X,C,W,new);

end




%This function will perform a kmeans clustering algorithm, given the
%location of the new point we wish to add

%Parameter X: A matrix of data points to cluster; rows correspond to
%points, columns correspond to variables
%Parameter C: The centroids for the solution to the clustering problem for
%k-1 clusters
%Parameter W: The weighting associated with each dimension
%Parameter new: The index of the data point at which the new cluster will
%be located

%Return ix: A vector indicating the cluster index of each point above
%Return C: The locations of the centroids of each cluster
%Return dis: The distance from each data point to each cluster
%Return D: A matrix indicating the weighted cluster error for each cluster
function [ix C dis D] = kmeansWeightOne(X,C,W,new)

%Determine the size of our input points
[n, ~] = size(X);
%Create a vector counting the number of points
v=1:n;

%Allocate the newest centroid to have location specified by the data point
%with index new
C = cat(1,C,X(new,:));

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

%Now, calculate the distance of member points to each centroid
%Create a matrix of zeros the same size as dis
D = zeros(size(dis));
%Find the linear index corresponding
lix = sub2ind(size(dis),v,ix(v));
%Now, only consider the appropriate indices for D
D(lix) = dis(lix).^2;
%And sum over all rows
D = sum(D,1);


%The error is the difference between the previous sum of squared
%distances and the current
D = sqrt(D);