%This function will return the number of times that a particular value
%occurs in an array

%Parameter arr: The array of values (may be multi-dimensional)
%Parameter value: The value of the thing which we wish to count

%Return count: Count number of times value appears in array
function count = numOccur(arr,value)


%Make the array a column vector, and value a row vector
arr = reshape( arr, numel(arr), 1 );
value = reshape( value, 1, numel(value) );


%Subtract the array from the value
subMat = bsxfun(@minus,arr,value);


%Find where all the zeros are
indMat = subMat == 0;


%Sum down the rows, but return a column vector
count = sum( indMat, 1)';