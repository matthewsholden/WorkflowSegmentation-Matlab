%This function will determine the cluster to which a vector projected into
%a lower dimensional space belongs

%Parameter proj: The matrix projected into the lower dimensional space,
%where rows represent points, columns represent dimensions
%Parameter C: A matrix where each column represents the coordinates in our
%space of the centroids for each clusters
%Parameter W: The weighting of each dimension
%Parameter TC: A vector indicate which centroid corresponds to which
%dimensional weighting

%Return cluster: The index of the cluster to which the point belongs
function cluster = motionCluster(proj,C,W)

%Find the array of distances from the projected vector to each centroid
%using the appropriate norm
d = interDistances(proj,C,W);

%Initialize out vector of clusters
cluster = zeros(1,size(proj,1));

%Now, return the index yielding the minimum distance from the projected
%vector to centroid
for i=1:size(proj,1)
    cluster(i) = minIndex(d(i,:));
end