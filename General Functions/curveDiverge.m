%this function will compare two curves, each generated from an average of
%several points, and determine whether or not they were produced from the
%same distribution, using the t-test to compare the data

%Parameter x: A matrix of values from the distributions. Rows correspond to a
%particular sample number, Columns correspond to a particular distribution
%Parameter y: A matrix of values from the distributions. Rows correspond to a
%particular sample number, Columns correspond to a particular distribution
%Parameter a: The level of siginificance we would like to obtain for each
%individual pair of distributions

%Return sig: A vector indicating whether a particular pair of columns in
%the x and y matrices are significantly from different distributions
%Return p: A vector of p-values for each pair of columns
function [sig p] = curveDiverge(x,y,a)

%Assume that the distributions have different variances, and use a
%two-tailed distribution
[sig p] = ttest2(x,y,a,'both','unequal');