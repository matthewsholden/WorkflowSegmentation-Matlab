%This function will concatenate two arrays of different sizes (no matter
%what the sizes are) by padding the arrays with the specified values

%Parameter dir: The direction along which we wish to concatenate
%Parameter A: The first matrix we wish to concatenate
%Parameter B: The second matrix we wish to concatenate
%Parameter value: The value we want to pad with

%Return C: The concatenated arrays
function C = padcat(dir,A,B,value)

%First, if the value is not specified assume it to be zero
if (nargin < 4)
    value = 0;
end

%First, determine the size of each matrix
szA = size(A);
szB = size(B);

%First, if the dimensionality of the two arrays are different, then pad the
%dimensionality of the lesser dimensional one with ones
ndimA = length(szA);
ndimB = length(szB);

%Determine the smaller dimension and pad
if (ndimA < ndimB)
    szA = padarray(szA,[0 ndimB-ndimA],1,'post');
elseif (ndimA > ndimB)
    szB = padarray(szB,[0 ndimA-ndimB],1,'post');
end

%Dimensionalities are equal; determine how to pad each
padA = max(0,szB - szA);
padB = max(0,szA - szB);

%Along the direction of concatenation, however, we need not pad
padA(dir) = 0;  padB(dir) = 0;

%Pad the arrays as appropriate
A = padarray(A,padA,value,'post');
B = padarray(B,padB,value,'post');

%Concatenate padded matrices using cat function in desired dimension
C = cat(dir,A,B);
    
    
    