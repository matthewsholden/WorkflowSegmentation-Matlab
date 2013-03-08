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



%This recursive method calculates the linear index corresponding to a
%vector given its size

%Parameter v: A vector locating the desired element
%Parameter sz: A vector indicate the size of the tensor

%Return ix: The linear index of the desired element
function ix = linearIndex(v,sz)

%The ith fraction of the array refers to the ith index in the last
%dimension
%Note that size(sz) <= size(v)
if (size(sz) == 1)
    ix = v(1);  
else
    %Recursively call, reducing the dimension each time
    ix = (linearIndex(v(2:end),sz(2:end)) - 1) * sz(1) + v(1);
    
end


