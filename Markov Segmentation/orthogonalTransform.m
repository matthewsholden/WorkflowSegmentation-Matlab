%Suppose we have a complete procedural record. We want determine every
%point in the lower-dimensional space produced by this procedure.

%Parameter D: A data object with un-orthogonally transformed data
%Parameter orthParam: A vector of parameters that the procedure will use

%Return DO: A data object with orthogonally transformed data
function DO = orthogonalTransform(D,orthParam)


%If necessary, read the parameters for the orthogonal projection
if (nargin < 2)
    %Create an organizer
    o = Organizer();
    %Read from file the parameters
    orthParam = o.read('Orthogonal');
end


%Initialize the parameters of the orthogonal transformation
numPoints = orthParam(1); %Number of observation used in transformation
interpPoints = orthParam(2); %Interpolate observations to get more/less
order = orthParam(3); %The order of the orthogonal transformation
dim = ( order + 1 ) * D.dim; %Dimension of orthogonally transformed data


%Calculate the average time step, so we can extrapolate "negative" times
if ( D.count == 1 )
    timeStep = 1;
else
    timeStep = ( D.T(end) - D.T(1) ) / (D.count - 1);
end%if


%Pad the observations with "negative" time stamps
T_Pad = D.T;
X_Pad = D.X;
K_Pad = D.K;
%Iterate over all required negative time stamps
for i = 1:(numPoints-1)
    T_Pad = cat(1,D.T(1) - i*timeStep,T_Pad);
    X_Pad = cat(1,D.X(1,:),X_Pad);
    K_Pad = cat(1,D.K(1),K_Pad);
end%for
%Calculate the velocity at each time step for each points
V_Pad = derivCalc(T_Pad,X_Pad,1);


%Initialize the matrices for our orthogonally transformed data
T_Orth = zeros(D.count,1);
X_Orth = zeros(D.count,dim);
K_Orth = zeros(D.count,1);


%Set the initial count to be
count = 0;


%Iterate over all time steps in the original data
while (count < D.count)
    %Increment the count of total time steps
    count = count + 1;
    
    %Calculate the range in time we will use to determine the spline
    minHist = count;
    maxHist = count + numPoints - 1;
    vHist = minHist:maxHist;
    
    %Calculate the times at which the interpolated points will occur
    T_Split = splitInterval( T_Pad(minHist), T_Pad(maxHist), interpPoints )';
    
    %Use a velocity spline to interpolate the observations
    X_Interp = velocitySpline( T_Pad(vHist), X_Pad(vHist,:), V_Pad(vHist,:), T_Split );
    
    %Perform a submotion transform on the interpolated data
    T_Orth(count) = T_Pad(maxHist);
    X_Orth_Curr = Legendre( T_Split, X_Interp, order );
    X_Orth(count,:) = reshape( X_Orth_Curr, 1, numel(X_Orth_Curr) );
    K_Orth(count) = K_Pad(maxHist);
    
end%while

%Create the data object to output
DO = Data( T_Orth, X_Orth, K_Orth, D.S );