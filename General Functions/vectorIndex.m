%This recursive method calculates the linear index corresponding to a
%vector given its size

%Parameter ix: The linear index of the desired element
%Parameter sz: A vector indicate the size of the tensor

%Return ix: The vector index of the desired element
function v = vectorIndex(ix,sz)

%The ith fraction of the array refers to the ith index in the last
%dimension

%Note that size(sz) <= size(v)
if (length(sz) == 1)
    v = ix;
else
    %This is the number of indices to skip
    skip = prod( sz(2:end) );
    %This will index the index in the last dimension
    ixLast = ceil( ix / skip );
    %Recursively call, reducing the dimension each time
    v = cat(2 , vectorIndex(ix - (ixLast-1) * skip, sz(1:end-1)) , ixLast );
    
end
