%This function will perform a nearest neighbour clustering algorithm. For
%each cluster, find the closest point and merge the two clusters.

%Parameter X: A set of points that we wish to cluster
%Parameter W: The weighting associated with each dimension
%Parameter k: The number of clusters we want to create (when everything is
%all said and done)

%Return ix: A vector indicating the cluster index of each point above
function [ix D] = clusternn(X,W,k)

%First, determine the size of our matrix of points
[n dof] = size(X);

%Initialize our vector of indices and distances
ix = zeros(1,n);
D = zeros(1,k);

%Calculate a matrix with the distance between each pair of points, using
%the specified weighting
dis = intraDistances(X,W);

%Also, keep track of the distances, but add NaNs where the distance is no
%longer required for determining the nearest neighbour
disnn = dis + diag( ones(1,n) * NaN );

%Additionally, assign each point to its own cluster
for i=1:n
   ix(i) = i; 
end

%We to create k clusters, from n points, so we need n-k mergers
for j=1:(n-k)
   %Find the minimum index of distance between any two points 
   mlix1 = minIndex(disnn);
   %Next, calculate the vector index given the linear index we have found
   mvix1 = vectorIndex(mlix1,[n n]);
   %And the vector index for the other distance storage location
   mvix2 = fliplr(mvix1);
   %Determine the linear index of the other distance storage location
   mlix2 = linearIndex(mvix2,[n n]);
   
   %Find the cluster numbers of the relevant points
   c1 = ix(mvix1(1));
   c2 = ix(mvix2(1));
   
   %If we find c2, then change it to c1
   ix(ix==c2) = c1;
    
   %Additionally, any point that is already in the same cluster as this new
   %point
   disnn(ix==c1,ix==c1) = NaN;
   
end

%Now, we might no have the cluster numbers we are looking for, so let's
%ensure that we only have the numbers one through k
for j=1:k
   %Check how many times this cluster appears, and if it is zero, then take 
   %one of the cluster numbers that is too large and change it to this
   %cluster number
   if (numOccur(ix,j)==0)
      %Determine the maximum cluster number (which will certainly be 
      %greater than k)
      maxK = max(ix);
      %Now, any point that is associated with that number shall now be
      %associated with the number j
      ix(ix==maxK) = j;
   end
end

%Now that we have assigned each point to its cluster, let's determine the
%sum of distances between the points within each cluster
for j=1:k
    %Find all distances that are of the cluster number j
    jDis = dis(ix==j,ix==j);
    %Add them together to find the jth entry of D, dividing by two since
    %each distance shall appear twice
    D(j) = sum(sum(jDis))/2;
end
