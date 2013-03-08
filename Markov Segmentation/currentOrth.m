%Suppose we have a complete procedural record. We want determine every
%point in the lower-dimensional space produced by this procedure.

%Parameter T: The vector of time stamps for the procedure
%Parameter X: The matrix of dofs for the procedure
%Parameter K: The vector of tasks for the procedure
%Parameter Orth: A vector of parameters that the procedure will use

%Return TO: The time stamps of the points corresponding to XO
%Return XO: The orthognally projected degrees of freedom
%Return KO: The task and the time stamps corresponding to XO
function [TO XO KO] = currentOrth(T,X,K,Orth)

%If necessary, read the parameters for the orthogonal projection
if (nargin < 4)
    %Create an organizer
    o = Organizer();
    %Read from file the parameters
    Orth = o.read('Orth');
end

%First, pad for the first few transformations
T_Pad = T; X_Pad = X; K_Pad = K;

%We need to know the time step
if ( size(T,1) == 1 )
    timeStep = 1;
else
    timeStep = (T(2)-T(1));
end%if

for i=1:(Orth(2)-1)
    T_Pad = cat(1,T(1) - i*timeStep,T_Pad);
    X_Pad = cat(1,X(1,:),X_Pad);
    K_Pad = cat(1,K(1),K_Pad);
end

%Determine the size of the matrix of X
[n dof] = size(X_Pad);

%Calculate the velocity at each time step for each points
V_Pad = velocityCalc(T_Pad,X_Pad);

%Calculate the range in time we will use to determine the spline
minHist = n - Orth(2) + 1; maxHist = n;
vHist = minHist:maxHist;

%Calculate the times at which the interpolated points will occur
t = splitInterval(T_Pad(minHist),T_Pad(maxHist),Orth(3))';

%Calculate the value of the degree of freedom at the interp
%points, using a velocity spline
x = velocitySpline(T_Pad(vHist),X_Pad(vHist,:),V_Pad(vHist,:),t);

%Perform a submotion transform on the interpolated data
TO = T_Pad(maxHist);
XO = subOrth(t,x,Orth(4));
KO = K_Pad(maxHist);

%
%
% %We can call this procedure on the velocities too!
% if (Orth(6) > 0)
%     %Create a vector with the derivatie parameter (6) one decreased...
%     tempOrth = Orth;
%     tempOrth(6) = tempOrth(6) - 1;
%     %Calculate the new orthogonal transformation
%     [~, XV, ~] = orth(T,V,K,tempOrth);
%     %Concatenate with the previous vector of orthogonally projected data
%     XO = cat(2,XO,XV);
% end







%This function will perform a submotion history transform on an array of
%data using the most recent m data points by an orthogonal transformation

%Parameter T: The vector of times up until the current time
%Parameter X: The matrix of values for each degree of freedom at the
%corresponding times
%Parameter order: The order of transformation (up to 6th) to be used

%Return trans: The orthogonal transformations of the times series
function trans = subOrth(T,X,order)

%Do not normalize the data, this removes information
%Time is normalized appropriately for transformation within Legendre
trans = Legendre(T,X,order);

%Now reshape our matrix into one long vector
trans = reshape( trans, 1, numel(trans) );