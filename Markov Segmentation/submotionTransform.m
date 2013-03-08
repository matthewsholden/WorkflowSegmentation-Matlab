%This function will perform a submotion history transform on an array of
%data using the most recent m data points by an orthogonal transformation

%Parameter T: The vector of times up until the current time
%Parameter X: The matrix of values for each degree of freedom at the
%corresponding times
%Parameter order: The order of transformation (up to 6th) to be used

%Return proj: The projection of the times series into a lower dimensional
%space
function proj = submotionTransform(T,X,order)

%Determine the number of degrees of freedom and time steps from the size of
%the X matrix
[dof history] = size(X);

%We will only feed in the previous m time steps

%The projection vector will have size (order+1)*dof
%Recall that the vector returned from the transform will have (order+1)
%components since there is an order zero component
proj = zeros(dof,(order+1));

%This is good, now we need to normalize the data such that comparing
%positions to rotations is fair...
for i=1:dof
    
    %Note that the time is normalized appropriately for the transformation 
    %within the orthogonal transformation function.
   
    proj(i,:) = Legendre(T,X(i,:),order);
    
end

%Now reshape our matrix into one long vector
proj = reshape(proj,1,numel(proj));
