%This function will compute the distances between all sets of two points in
%a matrix

%Parameter X1: A matrix of points we wish to determine the norms of. Rows
%represent points, columns correspond to dimensions
%Parameter X2: A matrix of points we wish to determine the norms of. Rows
%represent points, columns correspond to dimensions
%Parameter W: The weightings associated with each dimension of the vector
%Parameter p: The order of norm we wish to use

%Return res: The weighted norm of the vector
function res = interDistances(X1,X2,W,p)

%If p is not given, assume p=2 since this is standard
if (nargin < 4)
    p=2;
end

%If W is not given, assume that the weighting for each dimension is one (no
%weighting)
if (nargin < 3)
    W=ones(1,size(X1,2));
end

%Reshape X1 such that it is in the first, third dimension
X1 = reshape(X1,[size(X1,1) 1 size(X1,2)]);
%Now, reshape the X2 such that it is in the second, third dimension
X2 = reshape(X2,[1 size(X2,1) size(X2,2)]);

%Subtract the two matrices, expanding along singleton dimensions
res = bsxfun(@minus,X1,X2);

%Reshape W into the third dimension
W = reshape(W,[1 1 numel(W)]);

%Use the bsxfun with times to weight the values appropriately
res = bsxfun(@times,res,W);

%Calculate the weighted distance to the pth power to the result
res = sum(res.^p,3).^(1/p);