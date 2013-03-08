%This procedure will test the outlier replacement algorithm. Note that we
%must replace outliers for all succeeding calculations.

%Parameter D: A data object with DOFs we wish to smooth
%Parameter seqLength: The sequence history time length
%Paramter threshold: The threshold value at which we will reject a point as
%an outlier
%Parameter order: The order to which we want to do the interpolation

%Return DS: a data object with the smoothed DOFs

function DS = testAccelOutlier(D,maxAccel,goodAccel)

%First, extract the x values
T = D.T;
X = D.X;
%Start the time at zero (to avoid rounding errors associated with larger
%times)
T = T - T(1,:);
n = size(T,1);

%This is just for testing purposes
T_Orig = T;
X_Orig = X;

%Start the smoothed data as nothing
TS = [];
XS = [];

%The sequence length we need is three (3 point 2nd-order centred diff)
seqLength = 3;

%Next, iterate over all times for smoothing
for i = 1:n
    %Calculate the minimum
    minHist = max(1,i-seqLength);
    maxHist = i-1;
    
    %Add the current point to the smoothed points
    TS_Current = cat(1,TS(minHist:maxHist,:),T(i,:));
    XS_Current = cat(1,XS(minHist:maxHist,:),X(i,:));
    
    %Replace the last entry in the sequence (if outlier)
    if (i <= seqLength)
        XS_New = X(i,:);
    else
        [XS_New accel] = accelOutlier(TS_Current,XS_Current,maxAccel,goodAccel);
        
        disp(['Time: ', num2str(T(i,:)), ', Acceleration: ' num2str(accel)]);
       
    end%if
    
    %Concatenate
    TS = cat(1,TS,T(i,:));
    XS = cat(1,XS,XS_New);

    
end%for

%Now, put our data together into a new Data object
DS = Data(TS,XS,D.K,D.S);
    
%Plot the results, so we can evaluate the replacement visually
figure;
hold on;
plot(T_Orig,X_Orig(:,1),'b');
plot(TS,XS(:,1),'r');

figure;
hold on;
plot(T_Orig,X_Orig(:,2),'b');
plot(TS,XS(:,2),'r');

figure;
hold on;
plot(T_Orig,X_Orig(:,3),'b');
plot(TS,XS(:,3),'r');