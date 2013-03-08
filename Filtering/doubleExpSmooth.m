%This function will use double exponential smoothing to to smooth the data
%in real time, and predict upcoming data points

function DS = doubleExpSmooth(D,a,b)

%The alpha and beta parameters are user specified
%alpha (a) - data smoothing factor
%beta (b) - trend smoothing factor

%Grab the degrees of freedom from the Data object
X = D.X;

%Pre-allocate all of our vector/matrix quantities
S = zeros(size(X));
B = zeros(size(X));
n = size(X,1);

%Initialize the S and B vectors
S(1,:) = X(1,:);
B(1,:) = X(1,:) - X(2,:);

%Iterate over all time and calculate
for i=2:n
    %Calculate the next s
    S(i,:) = a * X(i,:) + (1 - a) * (S(i-1,:) + B(i-1,:));
    %Calculate the next b
    B(i,:) = b * (S(i,:) - S(i-1,:)) + (1 - b) * B(i-1,:);
end%for

% %Pre-allocate all of our vector/matrix quantities
% S1 = zeros(size(X));
% S2 = zeros(size(X));
% S3 = zeros(size(X));
% A = zeros(size(X));
% B = zeros(size(X));
% n = size(X,1);
% 
% %Initialize the S vectors
% S1(1,:) = X(1,:);
% S2(1,:) = X(1,:);
% S3(1,:) = X(1,:);
% %Calculate the initial A,B vectors
% A(1,:) = 2 * S1(1,:) - S2(1,:);
% B(1,:) = a/(1-a) * ( S1(1,:) - S2(1,:) );
% 
% %Iterate over all time and calculate
% for i=2:n
%     %Calculate the next s
%     S1(i,:) = a * X(i,:) + (1 - a) * S1(i-1,:);
%     S2(i,:) = a * S1(i,:) + (1 - a) * S2(i-1,:);
%     S3(i,:) = a * S2(i,:) + (1 - a) * S3(i-1,:);
%     %Calculate the next A,B
%     A(i,:) = 2 * S1(i,:) - S2(i,:);
%     B(i,:) = a/(1-a) * ( S1(i,:) - S2(i,:) );
% end%for

%Create the smoothed data object
DS = Data(D.T,S,D.K,D.S);