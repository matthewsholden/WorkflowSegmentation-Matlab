%This function will calculate the weight associated with each dimension of
%the space on which we are clustering. We use the weighting proposed by
%Huang in 2005.

%Parameter X: The points which we are clustering
%Parameter C: The centroids of the clusters
%Parameter bet: The beta value for the clustering scheme proposed by Huang
%in 2005.

%Return W: The weighting associated with each vector.
function W = clusterWeights(X,C,ix,bet)

%Determine the size of our data
[n dim] = size(X);

%Initialize the value of W
W = zeros(1,dim);
%And initialize our vector dimD
vr = zeros(1,dim);

%Now calculate the weightings by the method proposed by Huang

%First, calculate the within cluster variances
for i=1:n
    vr = vr + ( X(i,:) - C(ix(i),:) ).^2;
end

%Take the standard deviation
%sd = sqrt(vr);

%Now, we must invert any non-zero components and leave any zero
%components as zero
for d=1:dim
    %Only if vr is presently non-zero
    if (vr(d) ~= 0)
        W = W + (vr./vr(d)).^(1/(bet-1));
    end
end

%Invert the values of W
for d=1:dim
    %Only if W is presently non-zero
    if (W(d) ~= 0)
        W(d) = 1./W(d);
    end
end

%Finally, normalize the weightings
W = W / sum(W);

%And we will apply th exponent beta in here rather than outside
W = sqrt(W.^bet);