%This function will perform a class dependent linear discriminant analysis 
%on a set of data, maximizing the separation between classes of data.

%Parameter X: Cell array of classes of data (all with same dimension)

%Return X_Trans: Transformed data where the class separation is maximized
%Return Trans: Cell array of eigenvectors yielding transformation
%Return Mn_Trans: Mean of each class of data
function [X_Trans Trans Mn_Trans] = lda(X)


%Count the number of classes
numClass = length(X);


%Calculate the mean of each class of data
Mn = cell(size(X));
%Iterate over all classes and find the mean of each one
for j=1:numClass
    Mn{j} = mean( X{j}, 1 );
end%for


%Create a set of all data points, by concatenating all classes
XT = [];
for j=1:numClass
    XT = cat( 1, XT, X{j} );
end%for


%Calculate the mean of the total set of data
Mnt = mean( XT, 1 );


%Calculate the class mean covariance (between-class scatter)
SB = 0;
for j=1:numClass
    SB = SB + ( Mn{j} - Mnt )' * ( Mn{j} - Mnt );
end%for


%Calculate the average within class scatter matrix
SW = 0;
for j=1:numClass
    SW = SW + cov( X{j} ) / numClass;
end%for


%Calculate the optimization criterion R
R = pinv( SW ) * SB;


%Calculate the eigenvalues of the crierion matrix
for j=1:numClass
    [evector jordan] = eig( R );
    evalue = diag( jordan );
end%for


%Select only the largest numClass-1 eigenvectors
[evalue eix] = sort( evalue, 'descend' );
Trans = evector( :, eix(1:numClass-1) );


%Transform the inputted data by multiplying it by the non-zero eigenvectors
X_Trans = cell(size(X));
for j=1:numClass
    X_Trans{j} = X{j} * Trans; 
end%for


%Calculate the mean of each transformed class
Mn_Trans = cell(size(X));
for j=1:numClass
    Mn_Trans{j} = mean( X_Trans{j}, 1 );
end%for
