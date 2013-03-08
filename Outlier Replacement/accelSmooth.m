%This function will replace outliers by placing a maximum possible
%curvature (acceleration) on each degree of freedom

%Parameter T: The independent variable (dimension DT)
%Parameter X: The dependent variable (dimension DX)
%Parameter threshold: The acceptable ratio of new to old chi-squared values
%Parameter maxOrder: The highest order interpolation we will do

%Return XS: The smoothed data (endpoint only)
%Return accel: The non-smoothed acceleration
function [XS accel] = accelSmooth(T,X,maxAccel,goodAccel)

%Calculate the number and dimension observations
[n obsDim] = size(X);
[n varDim] = size(T);

%initialize the smoothed observations
XS = zeros(1,obsDim);

%Calculate the time step
h1 = T(end-2,:) - T(end-1,:);
h2 = T(end,:) - T(end-1,:);

%Calculate the values
xp = X(end-2,:);
xc = X(end-1,:);
xn = X(end,:);


%Calculate the acceleration
accel = 2/(h1*h2) .* ( (h2*xp - h1*xn)./(h1-h2) + xc);

%Now,determine if we have the maximum acceleration
%Do this for each degree of freedom independently
for i=1:obsDim
    if (abs(accel(i)) <= maxAccel)
        XS(i) = xn(i);
    else
        %Calculate the new point
        XS(i) = ( h2.*xp(i) - (h1 - h2) * (h1.*h2/2 .* goodAccel .* sign(accel(i)) - xc(i)) ) ./ h1;
    end%if
end%for