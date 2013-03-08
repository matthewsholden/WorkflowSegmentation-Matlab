%This method will implement a Kalman filter, using an observation z (the
%observed position of the tool) to detemine the state of the system x (the
%position of the tool without noise)

%Use the adaptive method overviewed in Moghaddamjoo 1989

%Parameter Z: The matrix of previous observations
%Parameter X: The matrix of previous states
%Parameter Z_New: The newest observation
%Parameter P0: The estimation error covariance from the last step
%Parameter NS: The number of time steps used to calculate forcing function
%Parameter NZ: The number of time steps used to calculate covariance
%matrices

%Return X_New: The predicted state based on the newest observation
function [X_New P] = kalmanFilter2(X,Z,Z_New,P0,NS,NZ)

%Transpose everything
X = X';
Z = Z';
Z_New = Z_New';

%We require that rows(X)==rows(z) > 2*NS, NZ

%The equations for the Kalman filter are...

%Linear System:
%x(k+1) = A(k)*x(k) + B(k)*u(k) + w(k)
%z(k) = C(k)*x(k) + v(k)

%Kalman Filter equations:
%K(k) = ( A(k-1)*P(k-1)*A(k-1)' + Q(k-1) )*C(k)'*[ C(k)*( A(k-1)*P(k-1)*A(k-1)' + Q(k-1) )*C(k)' + R(k) ]-1
%P(k) = (I - K(k)*H(k))*( A(k-1)*P(k-1)*A(k-1)' + Q(k-1) )
%x(k) = A(k-1)*x(k-1) + B(k-1)*u(k-1) + K(k)*[ z(k) - C(k)*( A(k-1)*x(k-1) +
%B(k-1)*u(k-1) ) ]

%Forcing Function Estimation:
%B(k-1)*u(k-1) = 1/NS * sum( x(k) - A(k-1)*x(k-1) )

%Covariance estimation:
%Q(k) = NS /(NS-1) * cov( x(k-j+1) - A(k-j)*x(k-j) - B(k-j)*u(k-1) - B(k)uu(k) )
%- 1/NS * sum( A(k-j)*P(k-j)*A(k-j)' - P(k-j+1) )
%R(k) = NZ/(NZ-1) * cov( y(k-j+1) ) - (NZ-1)/NZ * sum( C(k-j+1) * (
%A(k-j)*P(k-j)*A(k-j)' + Q(k-j) ) ) + sum ( C(k-j+1)' )

%Simplified covariance estimation:
%Q(k) = NS /(NS-1) * cov( x(k-j+1) - A(k-j)*x(k-j) - B(k-j)*u(k-1) - B(k)uu(k)
%R(k) = NZ/(NZ-1) * cov( y(k-j+1) )

%Other intermediate results:
%B(k-1)uu(k-1) = 1/NS * sum ( x(k-j+1) - A(k-j)*x(k-j) - B(k-j)*u(k-1) )
%y(k) = z(k) - C(k) * ( A(k-1)*x(k-1) + B(k-1)*u(k-1) )

%It seems that NZ = NS = 200, with fudge = 1.5 does a good job

%For our purposes here, assume A and C to be identity matrices
A = eye(size(X,1));
C = eye(size(X,1));

fudge = 1.6;

%Let n be the number of time steps in the matrices X and Z
n = size(X,2);

%1. Calculate an estimate of the forcing function f
%This difference should be the forcing function
f = zeros(size(X));
for k=2:n
    f(:,k) = X(:,k) - A * X(:,k-1);
end%for

%2. Calculate the estmate of the forcing function Bu(k)
%Calculate the average forcing function using the above estimates
Bu = zeros(size(X));
for k=NS:n
    Bu(:,k) = mean( f(:,k-NS+1:k) , 2 );
end%for

%3. Calculate the error between the actual state and the predicted state
%Use the previously estimated forcing functions
e = zeros(size(X));
for k=NS+1:n
    e(:,k) = X(:,k) - A * X(:,k-1) - Bu(:,k-1);
end%for

%4. This error gives an estimate of a "secondary" forcing function
%This accounts for the error from the original forcing function
Bup = mean( e(:,k-NS+1:k) , 2 );

%5. Calculate the observation error y
%This is the difference between the actual observation and the predicted
%observation
y = zeros(size(X));
for k=NS+1:n
    y(:,k) = Z(:,k) - C * ( A * X(:,k-1) + Bu(:,k-1) ); %Also called v
end%for

%6. Calculate the bias
%This is the mean observation error (ideally zero)
r = mean( y(:,n-NS:n-1) , 2 );

%7. Calculate the covariance Q(n-1). We only need it for the last time step
Q = zeros(size(X,1));
for j = 1:NS
    Q = Q + ( e(:,n-j) - Bup ) * ( e(:,n-j) - Bup )';
end%for
Q = Q / (NS - 1);
Q = fudge * diag(diag(Q)); %Ensure only the diagonal entries survive (no coupling)

%8. Calculate the covariance R(n). Again, only for the last time step
R = zeros(size(X,1));
for j = 1:NZ
    R = R + ( y(:,n-j+1) - r ) * ( y(:,n-j+1) - r )';
end%for
R = R / (NZ - 1);
R = diag(diag(R)) / fudge; %Ensure only the diagonal entries survive (no coupling)


%8. Calculate the Kalman gain
K = ( A * P0 * A' + Q ) * C' * pinv( C * ( A * P0 * A' + Q ) * C' + R );

%9. Calculate the State estimate
X_New = A * X(:,n) + Bu(:,n) + K * ( Z_New - C * ( A * X(:,n) + Bu(:,n) ) );
%Not including the so-called "bias" in this calculation appears to work

%10. Calculate the Estimation Error Covariance for the next time step
P = ( eye(size(X,1)) - K * C ) * ( A * P0 * A' + Q );

%Transpose back the estimated state
X_New = X_New';
smooth
