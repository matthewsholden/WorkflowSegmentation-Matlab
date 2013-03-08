%This function will filter data, using a fourier transform low-pass filter,
%removing high frequency oscillations

%Parameter D: The observed input data
%Parameter cut: The cutoff frequency of the low pass filter
%Parameter filterName: The name of the filter to be used

%Return DF: The fourier filtered data
function DF = fourierFilter(D,cut,filterName)

%First, calculate the fourier transform of the data
X_Fourier = fft(D.X);

%Calculate the unfiltered norm of the fourier transform
origNorm = sqrt(sum(X_Fourier.*conj(X_Fourier),1));

%Calculate the norm of an identity filter
fourL = size(X_Fourier,1);
fourX = (1:fourL)';

%Determine the desired filter
if (strcmp(filterName,'Butterworth'))
    H = 1 ./ (1 + ( fourX ./ ( cut .* fourL ) ) );
else %hat filter
    H = fourX <= cut * fourL;
end%if

%Apply the filter
X_Fourier = bsxfun(@times, X_Fourier, H);

%Calculate the norm after filtering
postNorm = sqrt(sum(X_Fourier.*conj(X_Fourier),1));

%Normalize the filtering
X_Fourier = bsxfun(@times, X_Fourier, origNorm ./ postNorm);

%Revert back to the time-domain
X_Low = real(ifft(X_Fourier));

%Remove the offsets
DX_Norm = bsxfun(@minus, D.X, mean(D.X,1));
X_Low = bsxfun(@minus, X_Low, mean(X_Low,1));

%Calculate the ratios of norms for the original and filtered data
normRatio = sqrt( sum(DX_Norm.^2,1) ./ sum(X_Low.^2,1) );

%Multiply the filtered data so its norm is the same as unfiltered data
X_Low = bsxfun(@times, X_Low, normRatio );

%Add the offset from the unfiltered data back
X_Low = bsxfun(@plus, X_Low, mean(D.X,1));

%Create a data object using the inverse fourier transform
DF = Data(D.T,X_Low,D.K,D.S);
