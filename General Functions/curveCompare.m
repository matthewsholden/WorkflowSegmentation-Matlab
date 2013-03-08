%this function will compare two curves, each generated from an average of
%several points, and determine whether or not they were produced from the
%same distribution, using the t-test to compare the data

%Parameter x: A matrix of values from the distributions. Rows correspond to a
%particular sample number, Columns correspond to a particular distribution
%Parameter y: A matrix of values from the distributions. Rows correspond to a
%particular sample number, Columns correspond to a particular distribution
%Parameter a: The level of siginificance we would like to obtain for each
%individual pair of distributions

%Return diff: Whether or not the two curves are significantly different
function diff = curveCompare(x,y,a)

%Calculate the alpha value for individual procedures using the BY-FDR
%method
a = byfdr(a,size(x,2));

%Assume that the distributions have different variances, and use a
%two-tailed distribution
[sig p] = ttest2(x,y,a,'both','unequal');

%If all of the ttests are satisfied then we are good
if (sig)
   diff = true;
else
    diff = false;
end
