%This will perform an orderth order interpolation of a vector function (one
%on variable) for each dof independently

%Parameter T: The independent variable of interpolation
%Parameter X: The matrix of observations we with to interpolate
%Parameter W: The weighting associated with each observation
%Parameter order: The order up to which we wish to perform the
%interpolation

%Return C: A cell of coefficients for the interpolation in each DOF
function C = vectorInterpolate(T,X,W,order)

%1. Create the matrix A for each DOF, where T is possibly multi-variable
%Note that A will be the same for all
%2. Calculate the weighting for each observation
%3. Calculate the matrix inv(A'A)*A'Y for each DOF
%4. Create the vector Y for each DOF
%5. Assign C for each dof

%Calculate the dimensionality of X
DX = size(X,2);
%Calculate the dimensionality of T
DT = size(T,2);
%Calculate the number of points to interpolate
n = size(T,1);

%The size of A is n x (order+1)
A = zeros(n,1+DT*order);
%Initialize the column of A
Acol = 1;
%Now, assign the parts of A
A(:,1) = ones(n,1);
%increment the column of A
Acol = Acol + 1;
for j=1:order
    %Iterate over all dimensions
    for d=1:DT;
        %Iterate over all possible T
        A(:,Acol) = T(:,d).^j;
        %increment the column of A
        Acol = Acol + 1;
    end%for
end%for

%Calculate everything we need from A
APAA = (A'*diag(W)*A)\A'*diag(W);

%Now, our vector Y for each degree of freedom is
Y = cell(1,DX);
%Assign the values of Y
for i=1:length(Y)
    Y{i} = X(:,i);
end%for

%Calculate the number of cells of coefficients we require
C = cell(1,DX);
%Calculate the matrix inv(A'A)*A'Y for each DOF
for i=1:length(C)
    C{i} = APAA*Y{i};
end%for