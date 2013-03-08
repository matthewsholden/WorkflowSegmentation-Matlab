%This function will compute a weighting scheme for clustering based on the
%intraclass and interclass variances in each dimension, using knowledge of
%the original task classification, but no knowledge of the motion
%classification

%Parameter X: A cell array of data, where each cell contains data
%corresponding to a class

%Return W: The weighting associated with each dimension of the space
function W = classWeight(X)

%Determine the number of classes we have
setNum = length(X);

%Initialize C to be an empty matrix
C = [];

%First, calculate the intra class variance
for i = 1:setNum
    %Determine the interclass variance for each class
    vr = var(X{i},1);
    %Concatenate this variance into a single matrix
    C = cat(1,C,vr);
end

%Calculate the average class variance in each dimension
intra = mean(C,1);

%Initialize C to be an empty matrix
C = [];

%Next, calculate the total variance between classes, using the centroid for
%each class
for i = 1:setNum
    %Determine the centroid for each class
    mn = mean(X{i},1);
    %Concatenate the centroids into a single matrix
    C = cat(1,C,mn);
end

%Finally, calculate the variance in centroids for each dimension
inter = var(C);

%Now the weighting shall be the ratio of inter class variance to intra
%class variance
W = inter ./ intra;

%Ensure the weights are normalized...
W = normr(sqrt(W));


