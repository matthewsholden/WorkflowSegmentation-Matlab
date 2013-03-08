%This function will perform temporal calibration by minimizing the squared
%difference between two signals

%Parameter D1: A data object with the first signal
%Parameter D2: A data object with the second signal
%Parameter freq: The desired sampling frequency
%Parameter minWindow: The minimum window length for calibration

%Return delay: The delay after the first signal the second signal begins
function [minDelay minMSE D_Shift1 D_Shift2] = temporalCalMSE(D1, D2, freq, minWindow)

%First, ensure that both data objects start at time zero
D1 = Data( D1.T - D1.T(1), D1.X, D1.K, D1.S);
D2 = Data( D2.T - D2.T(1), D2.X, D2.K, D2.S);

%Calculate the step the delay is at
stepDelay = D1.T(end) - minWindow;
minDelay = 0;
minMSE = Inf;

%Calculate the period of sampling
period = 1 / freq;

%Calculate a spline of each of the signals, using the same sampling rate

%The desired times
TS1 = ( D1.T(1) : period : D1.T(end) )';
TS2 = ( D2.T(1) : period : D2.T(end) )';
%Calculate the observations using a velocity spline
XS1 = velocitySpline( D1.T, D1.X, derivCalc(D1.T,D1.X,1), TS1 );
XS2 = velocitySpline( D2.T, D2.X, derivCalc(D2.T,D2.X,1), TS2 );
%Now, create the new data objects
DS1 = Data(TS1, XS1, 0, 0);
DS2 = Data(TS2, XS2, 0, 0);


%Iterate over all times and calculate the mean-sqaured error
while (stepDelay > minWindow - D2.T(end) );
    
    %Grab the time vectors for each set of observations
    T1 = DS1.T - stepDelay;
    T2 = DS2.T;
    
    %Choose the endpoints of the window
    windowStart = max( min(T1), min(T2) );
    windowEnd = min( max(T1), max(T2) );
    windowLength = floor( (windowEnd - windowStart) * freq );
    
    
    %Find the start of each interval
    Inv1 = find( T1 >= windowStart, 1) : find( T1 >= windowStart, 1) + windowLength;
    Inv2 = find( T2 >= windowStart, 1) : find( T2 >= windowStart, 1) + windowLength;
    
    %Choose the observations within the window
    XW1 = DS1.X( Inv1, :);
    XW2 = DS2.X( Inv2, :);
    
    %Ensure that the window lengths are the same size
    if ( size(XW1) == size(XW2) )
        
        %Now we have the resampled points, we can calculate the SSE
        MSE = sum( sum( (XW1 - XW2).^2 ) ) / windowLength;
        
        %Finally, if this SSE is less than the min, replace the min
        if (MSE < minMSE)
            minMSE = MSE;
            minDelay = stepDelay;
        end%if
        
    else
        warning(['Invalid time shift: ', num2str(stepDelay)]);
    end
    
    %Increment the start of the sampling window by the tolerance
    stepDelay = stepDelay - period;
    
end%while

%Output the time shifted data objects
D_Shift1 = Data(D1.T - D1.T(1) - minDelay, D1.X, D1.K, D1.S);
D_Shift2 = Data(D2.T - D2.T(1), D2.X, D2.K, D2.S);
