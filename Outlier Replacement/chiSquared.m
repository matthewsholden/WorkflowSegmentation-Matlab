%The will calculate the chi-squared value of an interpolation,to determine
%how well it is interpolated.

%Parameter T: The independent variable of interpolation
%Parameter X: The matrix of observations we with to interpolate
%Parameter W: The weighting associated with each observation
%Parameter C: The coefficients of the interpolation

%Return chi: The chi-squared values for each DOF
%Return sumChi : The sum of the chi-squared values over all DOFs
function [chi sumChi] = chiSquared(T,X,W,C)

%1. Calculate the expected value using the interpolation
%2. Calculate the chi-squared value for each DOF
%3. Sum the chi-squared values over all DOFs


%Calculate order
order = (length(C{1}) - 1)/size(T,2);
%Calculate the dimensionality of X
DX = length(C);
%Calculate the dimensionality of T
DT = size(T,2);
%Calculate the number of points to interpolate
n = size(T,1);

%Let X be a vector of zeros
E = zeros(n,DX);

%Iterate of all DOFs of E
for i=1:DX
    %Initialize the column of A
    Ccount = 1;
    %Now, assign the parts of A
    sumTC = C{i}(1);
    %increment the column of A
    Ccount = Ccount + 1;
    for j=1:order
        %Iterate over all dimensions
        for d=1:DT;
            %Iterate over all possible T
            sumTC = sumTC + C{i}(Ccount) * T(:,d).^j;
            %increment the column of A
            Ccount = Ccount + 1;
        end%for
    end%for
    
    %The expected value is this sum
    E(:,i) = sumTC;
    
end%for

%Next, calculate the stdev of X
S = var(X,1);
%If anything has zero variance, assign its variance one
S(S==0) = 1;

%Calculate the squared sum of differences between E and X
SDS = bsxfun(@rdivide,(E-X).^2,S);
%Apply the weighting to the differences
SDSW = bsxfun(@times,SDS,W);


%Sum the columns to get a row vector
chi = sum(SDSW,1);
sumChi = sum(chi);