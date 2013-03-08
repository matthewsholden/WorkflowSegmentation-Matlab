%Given a set of times corresponding to points, calculate the interval of
%times in which test point lies between

%Parameter T: A vector of times
%Parameter testT: A vector of times we want to test the interval of

%Return inv: The interval in which the test point lies
function inv = getInterval4(T,testT)

%Calculate the number of entries in the T vector
n = length(T);
testn = length(testT);

%Calculate the index of the largest time value that is less than the test
%time
inv = length(T<testT)

%Note that if no such time points in the vector exist, then this will
%return n
if (inv == n)
    %Assign it to be in the last interval
    inv = n-1;
end

%Alternatively, if we are not at first point yet, assign the first possible
%interval
if (inv==0)
    %Assign to be in the next interval
    inv = 1;
end