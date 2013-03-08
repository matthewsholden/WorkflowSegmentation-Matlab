%This function will perform a submotion history transform on an array of
%data using the most recent m data points by an orthogonal transformation

%Parameter T: The vector of times up until the current time
%Parameter X: The matrix of values for each degree of freedom at the
%corresponding times
%Parameter order: The order of transformation (up to 6th) to be used

%Return trans: The orthogonal transformations of the times series
function trans = submotionTransform(T,X,order)

%Determine the number of degrees of freedom and time steps from the size of
%the X matrix
[history dof] = size(X);

%Recall there is an order zero component also
trans = zeros(dof,(order+1));

%Do not normalize the data, this removes information
%Iterate over all degrees of freedom
for i=1:dof
    %Time is normalized appropriately for transformation within Legendre
    trans(i,:) = Legendre(T,X(i,:),order);
end

%Now reshape our matrix into one long vector
trans = trans( trans, 1, numel(trans) );
