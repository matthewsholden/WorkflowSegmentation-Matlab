%This method will, given a vector, determine a scalar representing the an
%index corresponding to the particular entry in the tensor

%Parameter A: A matrix which we wish to find the element in
%Parameter v: A vector indicating the index of the element we wish to
%access

%Return elem: The element we have found
function elem = getElement(A,v)

%Calculate the size of our tensor A
sz = size(A);

%Recursively call the method
elem = A(linearIndex(v,sz));
