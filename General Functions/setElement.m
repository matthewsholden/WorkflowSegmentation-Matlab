%This method will, given a vector, determine a scalar representing the an
%index corresponding to the particular entry in the tensor

%Parameter A: A matrix which we wish to find the element in
%Parameter v: A vector indicating the index of the element we wish to
%access
%Parameter value: The value to which we want to set the desired element

%Return elem: The element we have found
function status = setElement(A,v,value)

%Indicate that the functio is not finished yet
status=0;

%Calculate the size of our tensor A
sz = size(A);

%Recursively call the method
A(linearIndex(v,sz))=value;

%The function is completed
status=1;

