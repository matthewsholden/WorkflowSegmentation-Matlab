%Suppose we have a complete procedural record. We want determine every
%point in the lower-dimensional space produced by this procedure.

%Parameter T: The vector of time stamps for the procedure
%Parameter X: The matrix of dofs for the procedure
%Parameter K: The vector of tasks for the procedure
%Parameter Orth: A vector of parameters that the procedure will use

%Return TO: The time stamps of the points corresponding to XO
%Return XO: The orthognally projected degrees of freedom
%Return KO: The task and the time stamps corresponding to XO
function [TO XO KO] = orth(T,X,K,Orth)

%Determine the size of the matrix of X
[n dof] = size(X);

%If necessary, read the parameters for the orthogonal projection
if (nargin < 4)
    %Create an organizer
    o = Organizer();
    %Read from file the parameters
    Orth = o.read('Orth');
end

%Calculate the number of procjected data points that will result
no = round( n / Orth(1) - Orth(2) );
%Calculate the dimension of the lower dimensional space
dim = ( Orth(4) + 1 ) * dof;

%Initialize the matrices for our orthogonally transformed data
TO = zeros(no,1);   XO = zeros(no,dim);     KO = zeros(no,1);

%Preallocate the size of the x array for storing interpolated points
x = zeros(Orth(3),dof);

%Intialize number of orthogonal projections, and number of elasped steps
transNum = 0;   elapseNum = 0;
%Initialize steps to be the history minus the elapse (since elapse time
%steps will occur prior to our first projection)
steps = Orth(2) - Orth(1);


%Iterate over all time steps in the original data
while (steps < n)
    %Increment the count of total time steps
    steps = steps + 1;
    %Increment the count of elapsed time steps
    elapseNum = elapseNum + 1;
    
    %Transform only if the number of elapsed steps equals the required
    if (elapseNum == Orth(1))
        
        %Increment the count of orthogonal transformations
        transNum = transNum + 1;
        
        %Calculate the range in time we will use to determine the spline
        minHist = steps - Orth(2) + 1; maxHist = steps;
        vHist = minHist:maxHist;
        
        %Calculate the times at which the interpolated points will occur
        t = splitInterval(T(minHist),T(maxHist),Orth(3))';
        
        %Now iterate over all degrees of freedom
        for i=1:dof
            %For each interp point
            for l=1:Orth(3)
                %Calculate the value of the degree of freedom at the interp
                %points, using a velocity spline
                x(l,i) = velocitySpline(T(vHist),X(vHist,i),t(l));
            end
        end
        
        %Perform a submotion transform on the interpolated data
        TO(transNum) = T(maxHist);
        XO(transNum,:) = subOrth(t,x,Orth(4));
        KO(transNum) = K(maxHist);
        
        %Reset the count variable for the number of elapsed time steps
        elapseNum = 0;
    end
    
end







%This function will perform a submotion history transform on an array of
%data using the most recent m data points by an orthogonal transformation

%Parameter T: The vector of times up until the current time
%Parameter X: The matrix of values for each degree of freedom at the
%corresponding times
%Parameter order: The order of transformation (up to 6th) to be used

%Return trans: The orthogonal transformations of the times series
function trans = subOrth(T,X,order)

%Determine the number of degrees of freedom and time steps from the size of
%the X matrix
[history dof] = size(X);

%Recall there is an order zero component also
trans = zeros(dof,(order+1));

%Do not normalize the data, this removes information
%Iterate over all degrees of freedom
for i=1:dof
    %Time is normalized appropriately for transformation within Legendre
    trans(i,:) = Legendre(T,X(:,i),order);
end

%Now reshape our matrix into one long vector
trans = reshape( trans, 1, numel(trans) );