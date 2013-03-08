%This function will produce the results for the trials we have not yet
%accomplished...

%Parameter K: The key generator object from which we want procdeures to be
%generated
%Parameter noise: The powers of noise over which we want to try
%Parameter itr: The number of iterations over which we want to average the
%segmentation

%Return status: Whether or not we have completed the function
function data = segmentTrial(K,noise,itr)

%If no parameter is provided, then go through the standard powers of noise
%as we have done in the past
if (nargin < 2)
    noise = -5:0.5:1;
end
%Assume that if no parameter is provided the user wishes to do only one
%iteration per value
if (nargin < 3)
    itr = [1 1];
end

%Use a count of how many points of data we have calculated segmentation for
count = 0;
%A matrix of the data [type amplitude accuracy]
data = zeros(4*length(noise),2+itr(1));

%First, the baseline translational
disp('Baseline Translational Noise Trained');
%Noise
for p=noise
    %Increment count
    count = count + 2;
    
    %Calculate the noise in the procedure
    disp([ ' Noise (power): ', num2str(p), ', Noise: ', num2str(10^p) ]);
    
    %Return the accuracy of the segmentation
    acc = segmentSubtrial('X_Bs_Tr',p,K,itr);
    
    %Display the parameters
    disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
    disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
    acc
    
    %Write to matrix
    data(count,1) = 1;
    data(count,2) = p;
    data(count:count+1,3:end) = acc;
    
    %Now repeat for differnt noise amplitude
end

%Second, the baseline rotational
disp('Baseline Rotational Noise Trained');
%Noise
for p=noise
    %Increment count
    count = count + 2;
    
    %Calculate the noise in the procedure
    disp([ ' Noise (power): ', num2str(p), ', Noise: ', num2str(10^p) ]);
    
    %Return the accuracy of the segmentation
    acc = segmentSubtrial('X_Bs_Ro',p,K,itr);
    
    %Display the parameters
    disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
    disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
    acc
    
    %Write to matrix
    data(count,1) = 3;
    data(count,2) = p;
    data(count:count+1,3:end) = acc;
    
    %Now repeat for differnt noise amplitude
end

%Third, the weighted translational
disp('Weighted Translational Noise Trained');
%Noise
for p=noise
    %Increment count
    count = count + 2;
    
    %Calculate the noise in the procedure
    disp([ ' Noise (power): ', num2str(p), ', Noise: ', num2str(10^p) ]);
    
    %Return the accuracy of the segmentation
    acc = segmentSubtrial('X_Wt_Tr',p,K,itr);
    
    %Display the parameters
    disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
    disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
    acc
    
    %Write to matrix
    data(count,1) = 2;
    data(count,2) = p;
    data(count:count+1,3:end) = acc;
    
    %Now repeat for differnt noise amplitude
end


%Fourth, the weighted rotational
disp('Weighted Rotational Noise Trained');
%Noise
for p=noise
    %Increment count
    count = count + 2;
    
    %Calculate the noise in the procedure
    disp([ ' Noise (power): ', num2str(p), ', Noise: ', num2str(10^p) ]);
    
    %Return the accuracy of the segmentation
    acc = segmentSubtrial('X_Wt_Ro',p,K,itr);
    
    %Display the parameters
    disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
    disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
    acc
    
    %Write to matrix
    data(count,1) = 4;
    data(count,2) = p;
    data(count:count+1,3:end) = acc;
    
    %Now repeat for differnt noise amplitude
end

%Finally, write our matrix of data to file
dlmwriten('TrialData',data,'\t');
