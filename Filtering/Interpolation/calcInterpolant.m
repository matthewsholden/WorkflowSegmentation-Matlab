%This function will interpolate the value of a point, given the
%coefficients of interpolation (order n)

%Parameter T: The independent variable of interpolation
%Parameter C: The coefficients of the interpolation

%Return X: The value of the interpolation at T
function X = calcInterpolant(T,C)

%Calculate order
order = (length(C{1}) - 1)/size(T,2);
%Calculate the dimensionality of X
DX = length(C);
%Calculate the dimensionality of T
DT = size(T,2);
%Calculate the number of points to interpolate
n = size(T,1);

%Let X be a vector of zeros
X = zeros(n,DX);

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
    X(:,i) = sumTC;
    
end%for