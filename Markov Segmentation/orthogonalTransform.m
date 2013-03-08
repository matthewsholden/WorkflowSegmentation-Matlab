%Suppose we have a complete procedural record. We want determine every
%point in the lower-dimensional space produced by this procedure.

%Parameter D: A data object with un-orthogonally transformed data
%Parameter orthParam: A vector of parameters that the procedure will use

%Return DO: A data object with orthogonally transformed data
function DO = orthogonalTransform(D,orthParam)

%If necessary, read the parameters for the orthogonal projection
if (nargin < 4)
    %Create an organizer
    o = Organizer();
    %Read from file the parameters
    orthParam = o.read('Orthogonal');
end

%First, pad for the first few transformations
T_Pad = D.T; X_Pad = D.X; K_Pad = D.K;

%We need to know the time step
if ( D.count == 1 )
    timeStep = 1;
else
    timeStep = ( D.T(end) - D.T(1) ) / (D.count - 1);
end%if

for i=1:(orthParam(2)-1)
    T_Pad = cat(1,D.T(1) - i*timeStep,T_Pad);
    X_Pad = cat(1,D.X(1,:),X_Pad);
    K_Pad = cat(1,D.K(1),K_Pad);
end%for

%Calculate the dimension of the lower dimensional space
dim = ( orthParam(4) + 1 ) * D.dim;

%Calculate the velocity at each time step for each points
V_Pad = derivCalc(T_Pad,X_Pad,1);

%Initialize the matrices for our orthogonally transformed data
TO = zeros(D.count,1);   XO = zeros(D.count,dim);     KO = zeros(D.count,1);

%Set the initial count to be
count = 0;

%Iterate over all time steps in the original data
while (count < D.count)
    %Increment the count of total time steps
    count = count + 1;
    
    %Calculate the range in time we will use to determine the spline
    minHist = count; maxHist = count + orthParam(2) - 1;
    vHist = minHist:maxHist;
    
    %Calculate the times at which the interpolated points will occur
    t = splitInterval(T_Pad(minHist),T_Pad(maxHist),orthParam(3))';
    
    %Calculate the value of the degree of freedom at the interp
    %points, using a velocity spline
    x = velocitySpline(T_Pad(vHist),X_Pad(vHist,:),V_Pad(vHist,:),t);
    
    %Perform a submotion transform on the interpolated data
    TO(count) = T_Pad(maxHist);
    xo = Legendre(t,x,orthParam(4));
    XO(count,:) = reshape( xo, 1, numel(xo) );
    KO(count) = K_Pad(maxHist);
    
end%while

%Create the data object to output
DO = Data(TO,XO,KO,D.S);