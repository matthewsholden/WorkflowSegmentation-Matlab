%This function will return the index of the maximum value in an array

%Parameter A: The array containing our values
%Return ix: The index of the maximum value in the array
function ix = maxIndex(A)

%Reduce the array such that is a one-dimensional vector
dims = ndims(A);

%Assign our array to be A
arr = A;

%Use the predefined Matlab function max to find the maximum value of the
%array
for i=1:dims
arr=max(arr);
end

%Determine the maximum value
maxValue = max(arr);

%Now, find the index of the maxValue
ix=find(A==maxValue);
%Ensure that we only return one index value
ix=ix(1);