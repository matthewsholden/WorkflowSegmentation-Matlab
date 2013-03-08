%This function will compute the distances between all sets of two points in
%a matrix

%Parameter X: A matrix of points we wish to determine the norms of. Rows
%represent points, columns correspond to dimensions
%Parameter W: The weightings associated with each dimension of the vector
%Parameter p: The order of norm we wish to use

%Return res: The weighted norm of the vector
function res = intraDistances(X,W,p)

%If p is not given, assume p=2 since this is standard
if (nargin < 3)
    p=2;
end

%If W is not given, assume that the weighting for each dimension is one (no
%weighting)
if (nargin < 2)
    W=ones(1,size(X,2));
end

%Assign the result to initial be zero and we will add to it
res = zeros(size(X,1),size(X,1));

%Create a new matrix for each point we want to iterate through the original
%matrix
for i=1:size(X,1)
    %For each row in the original matrix
    for j=1:size(X,1)
        %Subtract the appropriate row
        weightX = X(j,:) - X(i,:);
        %Multiply by the weighting
        weightX = weightX.*W;
        
        %Add the weighted distance to the pth power to the result
        res(i,j) = norm(weightX,p);
        
    end
end