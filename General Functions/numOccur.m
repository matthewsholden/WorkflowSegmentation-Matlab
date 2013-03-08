%This function will return the number of times that a particular value
%occurs in an array

%Parameter arr: The array of values (may be multi-dimensional)
%Parameter value: The value of the thing which we wish to count

%Return count: A count of the number of times the value appears in the
%array
function count = numOccur(arr,value)

%Initialize the count to zero
count = 0;

%Determine the number of elements in the array and iterate over all
%elements
for i=1:numel(arr)
   %Determine if the current element is equal to the search value
   if (arr(i)==value)
      count = count + 1; 
   end
end