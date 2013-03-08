%This function will be used to filter all data points using the Kalman
%filtering algorithm that we have implemented

%Parameter DZ: The input observation data
%Parameter NS0: The number of observations used to calculate the forcing
%function and process noise covariance
%Parameter NZ0: The number of observation used to calculate the measurement
%noise covariance

%Return DX: The output filtered state data
function DX = kalmanFilterAll(DZ,NS0,NZ0)

%Extract the observation data from the data object
Z = DZ.X;

%Determine the number of observations in total
n = size(Z,1);

%An initial estimate of the state error covariance
P0 = eye(size(Z,2));

%Create an empty matrix to which we will add the state estimates
X = zeros(0,size(Z,2));

%Iterate over all time steps
for k = 1:n
    
    %As the number of time steps we have available increases, we can used more
    %to calculate the covariance matrices (up to a point)
    NS = min(NS0,floor((k-2)/2));
    NZ = min(NZ0,floor((k-2)/2));
    
    %Apply the Kalman filter to the most recent point
    if (NS > 1 && NZ > 1)
        [X_New P0] = kalmanFilter2(X,Z(1:k-1,:),Z(k,:),P0,NS,NZ);
    else
        X_New = Z(k,:);
    end
    
    %Update the X matrix
    X = cat(1,X,X_New);
    
end%for


%Create a data object using the state estimates
DX = Data(DZ.T,X,DZ.K,DZ.S);