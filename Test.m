%Test function

function X = Test()

memory

Dee = Data(zeros(1,1000000),zeros(1,1000000),zeros(1,1000000),1);

memory;

Dee = Data(Dee.T,Dee.X,Dee.K,Dee.S);

memory;

X = Dee.T(1);

A = zeros(1000,1000);

memory;

X = A + X;

% memory;
% clear X
% memory
% clear Dee

memory;