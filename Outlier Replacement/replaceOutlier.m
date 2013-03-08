%This function will be used to replace outliers from the data in real-time
%IE it will smooth the data in real time
%In particular, we only care about replacing the last point

%Parameter T: The independent variable (dimension DT)
%Parameter X: The dependent variable (dimension DX)
%Parameter threshold: The acceptable ratio of new to old chi-squared values
%Parameter maxOrder: The highest order interpolation we will do

%Return XS: The smoothed data (endpoint only)
%Return chiRat: The ratio of chi-squared values
function [XS chiRat] = replaceOutlier(T,X,threshold,maxOrder)

%If we aren't passed a threshold
if (nargin < 3)
    threshold = 1;
end%if

%Calculate the number and dimension observations
[n obsDim] = size(X);
[n varDim] = size(T);


%Assume all the points except the current are good
PT = T(1:end-1,:);
PX = X(1:end-1,:);
CT = T(end,:);
CX = X(end,:);

%Calculate the previous weighting
PW = zeros(n-1,1);
for i=1:(n-1)
    PW(i) = ( T(i) - T(1) ) ./ ( T(n) - T(1) );
end%for

%Calculate the total weighting
W = zeros(n,1);
for i=1:n
    W(i) = ( T(i) - T(1) ) ./ ( T(n) - T(1) );
end%for

%Perform an interpolation of increasing order until we acheieve a
%chi-squared value of one or less

%Initialize this to be infinity, say
redPrevChi = Inf;
%Consider an interpolation of order
order = 0;

while (redPrevChi > 1 && order < maxOrder)
    %Increase the order (ignore order zero, its bad)
    order = order + 1;
    
    %Perform an interpolation of the previous points
    %(These are assumed to contain no outliers)
    C = vectorInterpolate(PT,PX,PW,order);
   
    %Calculate the chi-squared value of the interpolation
    [~, prevSumChi] = chiSquared(PT,PX,PW,C);
    %Calculate the current reduced chiSquared value
    redPrevChi = prevSumChi/(n-1);
    
end%while

%Now, calculate the chi-squared value while included the current point
[~, currSumChi] = chiSquared(T,X,W,C);
%Calculate the current reduced chiSquared value
redCurrChi = currSumChi/n;
%Calculate the chi ratio
chiRat = redCurrChi/redPrevChi;

%If the ratio of reduced chi-sqaured values is less than a particular threshold
if ( chiRat < threshold)
    CXS = CX;
else
    %Otherwise, replace the value with an interpolated value
    CXS = calcInterpolant(CT,C);
end%if

%Now, replace X(end,:) with CXS
XS = CXS;
    


