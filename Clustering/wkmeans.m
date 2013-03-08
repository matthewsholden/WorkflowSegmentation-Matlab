%This function will perform a wkmeans clustering algorithm, using specified
%weighting. Use the fast global k-means algorithm proposed by Likas in
%2003, and the dimension weighting scheme proposed by Huang in 2005.

%Parameter X: A matrix of data points to cluster; rows correspond to
%points, columns correspond to variables
%Parameter W: An initial estimate of the weighting. We will use an initial
%weighting which normalizes the variance in each dimension
%Parameter k: The maximum number of clusters to produce
%Parameter bet: The beta value for our weighting scheme
%Parameter itr: The number of iteration to perform to calculate the actual
%Huang weighting

%Return ix: A vector indicating the cluster index of each point above
%Return C: The locations of the centroids of each cluster
%Return dis: The distance from each point to each cluster
%Return D: A matrix indicating the weighted cluster error for each cluster
%Return W: The weightings calculated by the method of Huang
function [ix C dis D W] = wkmeans(X,W,k,bet,maxItr)

%Determine the size fo our input matrix
[n dim] = size(X);

%Keep a vector of centroids from the previous number of clusters
C = zeros(0,dim);
ix = ones(1,n);
dis = zeros(n,k);
D = zeros(1,n);

%We need to calculate the intrapoint distances every time now since the
%weighting changes each iteration
disX = intraDistances(X,W);

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
            improve = dis(m,ix(m))^2 - disX(l,m);
            %For each point, add whichever is larger, the distance to its
            %cluster centroid or the distance to the new centroid
            b(l) = b(l) + max(improve,0);
        end
    end
    
    %The index of the data point at which we will place the next centroid
    %is the index of the maximum b(l)
    new = maxIndex(b);
    
    %Now, calculate the new clustering and the new weighting
    [ix C dis D W] = wkmeansOne(X,C,W,new,bet,maxItr);
    
end







%This function will perform a kmeans clustering algorithm, but use the
%automatic variable weighting method proposed by [Huang 2005].

%Parameter X: A matrix of data points to cluster; rows correspond to
%points, columns correspond to variables
%Parameter PC: The centroids for the solution to the clustering problem for
%k-1 clusters
%Parameter new: The index of the data point at which the new cluster will
%be located
%Parameter bet: The beta value for the dimension weighting scheme
%Parameter maxItr: The maximum number of iterations the clustering may
%occur over

%Return ix: A vector indicating the cluster index of each point above
%Return C: The locations of the centroids of each cluster
%Return dist: The distance from each data point to each cluster
%Return currDist: A matrix indicating the weighted cluster error for each cluster
function [ix C dis D W] = wkmeansOne(X,C,W,new,bet,maxItr)

%Concatenate the new centroid with the previous matrix of centroids
C = cat(1,C,X(new,:));
%Determine the size of the data
[n dim] = size(X);
%Let k be the number of centroids
k = size(C,1);
%Preallocate the cluster index of each point
ix = zeros(1,n);

%Count the number of iterations required to perform a single kmeans
%clustering
itr = 0;
%The number of points changing centroid
change = -1;
%There exist empty clusters at the moment
empty = true;

%Now, determine the cluster which is closest to each point
while ((change ~= 0 || empty) && itr < maxItr )
    
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
    
    %Recalculate the weightings associated with each dimension
    W = clusterWeights(X,C,ix,bet);
    
end

%Calculate the sum of all distances from points to their corresponding
%centroids using the weighting
D = zeros(1,k);
%Iterate over each point and compare to each other point
for i=1:n
    %Calculate the distance between each point and its centroid
    D(ix(i)) = D(ix(i)) + dis(i,ix(i));
end

