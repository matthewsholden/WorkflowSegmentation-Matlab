%This function will be used to replace outliers from the data in real-time
%IE it will smooth the data in real time
%In particular, we only care about replacing the last point

%Parameter T: The independent variable (dimension DT)
%Parameter X: The dependent variable (dimension DX)
%Parameter threshold: The acceptable ratio of new to old chi-squared values
%Parameter maxOrder: The highest order interpolation we will do
function XS = replaceOutlierFlip(T,X,threshold,maxOrder)

%If we aren't passed a threshold
if (nargin < 3)
    threshold = 1;
end%if

%Calculate the number and dimension observations
[n obsDim] = size(X);
[n varDim] = size(T);


%Assume all the points except the current are good
[PT PX] = matrixMirror(T(1:end-1,:),X(1:end-1,:),X(end,:),true);
[CT CX] = matrixMirror(T(1:end-1,:),X(1:end-1,:),X(end,:),false);

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
    C = vectorInterpolate(PT,PX,order);
   
    %Calculate the chi-squared value of the interpolation
    [~, prevSumChi] = chiSquared(PT,PX,C);
    %Calculate the current reduced chiSquared value
    redPrevChi = prevSumChi/(n-1);
    
end%while

%Now, calculate the chi-squared value while included the current point
[~, currSumChi] = chiSquared(CT,CX,C);
%Calculate the current reduced chiSquared value
redCurrChi = currSumChi/n;

%If the ratio of reduced chi-sqaured values is less than a particular threshold
if ( redCurrChi/redPrevChi < threshold )
    CXS = X(end,:);
else
    %Otherwise, replace the value with an interpolated value
    CXS = calcInterpolant(CT,C);
    CXS = CXS(n,:);
end%if

%Now, replace X(end,:) with CXS
XS = X;
XS(end,:) = CXS;


