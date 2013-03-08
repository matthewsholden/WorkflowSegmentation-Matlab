%This function will compute the cluster dimension weightings using the z3
%score as proposed by Steinley in 2008.

%Parameter X: A matrix containing the points that we wish to cluster

%Return W: The weighting which will benefit the clustering the most
function W = z3weight(X)

%Compute the means, variances, and ranges for each dimension of the data
mn = mean(X);
vr = var(X);
sd = sqrt(vr);
rn = range(X);

%If the variance is too small and will cause roundoff error, then just
%ignore the dimension
for j=1:size(X,2)
    %Test if the variance in the dimension is less than the machine
    %epsilon, and if it is, then we can say the variance is effectively
    %zero, because this would cause roundoff troubles anyway
    if (vr(j) < eps)
        vr(j) = 0;
        sd(j) = 0;
        rn(j) = 0;
    end
end

%Compute the standard deviation after zeroing any insignificant variances


%Now, compute the measure M from our variance and range. I don't know where
%the factor of 12 comes into play, but it does apparently...
M = 12 * vr ./ (rn .^ 2);

%Calculate the index of the minimum value of M
mix = minIndex(M);

%Compute the relative clusterability measure of the dimension
RC = M / M(mix);

%Initialize the matrix of z1 scores to have the same size as the initial
%matrix of points
z1 = zeros(size(X));
%Now, compute the z1 score for each value
for i=1:size(X,1)
    z1(i,:) = (X(i,:) - mn) ./ sd;
end

%Compute the range of each dimension in z1
rnz1 = range(z1);

%Initialize the vector of weightings
W = zeros(1,size(X,2));
%Finally, calculate the z3 weightings
for j=1:size(X,2)
    %If the variance is non-zero, else ignore this dimension
    if (sd(j) ~= 0)
        W(j) = sqrt( ( RC(j) * rnz1(mix).^2 ) ./ ( vr(j) .* rnz1(j).^2 ) );
    end
end

%Normalize the weightings
W = normr(W);





