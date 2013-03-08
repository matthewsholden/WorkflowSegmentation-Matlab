%This function will compute the cluster dimension weightings using the z3
%score as proposed by Steinley in 2008.

%Parameter X: A cell array of data classes to be clustered

%Return W: The weighting associated with each dimension of the space
function W = z3weight(X)


%Compute the means, variances, and ranges for each dimension of the data
vr = var(X,1);
sd = sqrt(vr);
rn = range(X,1);


%Small variances will create roundoff error, assume zero if too small
vr( vr < eps ) = 0;
sd( vr < eps ) = 0;
rn( vr < eps ) = 0;


%Now, compute the measure M from our variance and range
M = vr ./ (rn .^ 2);


%Calculate the dimension with the smallest measure M
mix = minIndex(M);


%Compute the relative clusterability measure of the dimension
RC = M / M(mix);


%Compute the standardized range of each dimension
rnz1 = rn ./ sd;


%Calculate the z3 weightings
W = sqrt( ( RC .* rnz1(mix).^2 ) ./ ( vr .* rnz1.^2 ) );
W( isnan(W) ) = 0;


%Normalize weighting
W = normr(W);

