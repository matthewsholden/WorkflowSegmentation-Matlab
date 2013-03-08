%Given a set of times corresponding to points, calculate the interval of
%times in which test point lies between

%Parameter T: A vector of times
%Parameter testT: The time we want to test the interval of

%Return inv: The interval in which the test point lies
function inv = getInterval2(T,testT)

%Calculate the index of the largest time value that is less than the test
%time
inv = find(T>=testT,1,'first') - 1;

%Note that if no such time points in the vector exist, then this will
%return an empty matrix
if (isempty(inv))
    %Assign it to be in the last interval
    inv = length(T)-1;
end

%Alternatively, if we are not at first point yet, assign the first possible
%interval
if (inv==0)
    %Assign to be in the next interval
    inv = 1;
end