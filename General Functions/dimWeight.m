%This function will determine the weighting in each dimension such that
%comparisons between dimensions is acceptable by normalize the data along
%each of the dimensions


%Parameter X: A matrix of data where rows are points and columns are
%dimensions

%Return W: The normalized weightings
function W = dimWeight(X)

%Find the stddev in each dimension
sd = std(X,1,1);
%Preallocate the weighting vector for speed
W = zeros(1,length(sd));

%The weighting is equal to the inverse of the stddev
for i=1:length(sd)
    %Ensure that the standard deviation is not zero, else, let the
    %weighting be zero
    if (sd(i) ~= 0)
        W(i) = 1/sd(i);
    end
end