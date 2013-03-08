%This function will compute a weighted p-norm given a weighting
%corresponding to each dimension of the vector

%Parameter X: A vector of points we wish to determine the norm of
%Parameter W: The weightings associated with each dimension of the vector
%Parameter p: The order of norm we wish to use

%Return res: The weighted norm of the vector
function res = normWeight(X,W,p)

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
res = 0;

%Iterate over each dimension of the vector
for d=1:size(X,2)
    %Multiply the vector by the weighting
    X = X.*W;
    %Calculate the norm of this weighted vector using the typical method
    %for calculating a norm
    res = norm(X,p);
end