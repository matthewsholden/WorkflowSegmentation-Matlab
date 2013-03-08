%This function will be used to test the effectiveness of the Kalman
%filtering algorithm that we have implemented here

%Parameter Z: The input observation data
%Parameter NS0: The number of observations used to calculate the forcing
%function and process noise covariance
%Parameter NZ0: The number of observation used to calculate the measurement
%noise covariance

%Return X: The output filtered state data
function X = kalmanTest(Z,NS0,NZ0)

%Determine the number of observations in total
n = size(Z,1);

%An initial estimate of the state error covariance
P0 = eye(size(Z,2));

X = zeros(0,size(Z,2));

%Iterate over all time
for k = 1:n
    
    %As the number of time steps we have available increases, we can used more
    %to calculate the covariance matrices (up to a point)
    NS = min(NS0,floor((k-2)/2));
    NZ = min(NZ0,floor((k-2)/2));
    
    %Apply the Kalman filter to the most recent point
    if (NS > 1 && NZ > 1)
        [X_New P0] = kalmanFilterT(X,Z(1:k-1,:),Z(k,:),P0,NS,NZ);
    else
        X_New = Z(k,:);
        disp('<1');
    end
    
    %Update the X matrix
    X = cat(1,X,X_New);
    
end%for