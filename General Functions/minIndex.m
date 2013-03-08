%This function will return the index of the minimum value in an array

%Parameter A: The array containing our values
%Return ix: The index of the minimum value in the array
function ix = minIndex(A)

%Reduce the array such that is a one-dimensional vector
dims = ndims(A);

%Assign our array to be A
arr = A;

%Use the predefined Matlab function max to find the minimum value of the
%array
for i=1:dims
arr=min(arr);
end

%Determine the minimum value
minValue = min(arr);

%Now, find the index of the minValue
ix=find(A==minValue);
%Ensure that we only return one index value
ix=ix(1);