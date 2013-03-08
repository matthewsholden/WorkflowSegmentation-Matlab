%This function will implement a moving average filter, for an arbitrary
%distributions of weightings (need not integrate to one)

%Parameter D: The observed input data
%Parameter cut: The cut elapsed time of the moving average window
%Parameter filterName: The name of the filter to be used

%Return DA: The moving average filtered data
function DA = avgFilterLast(D,cut,filterName)

%Determine what the distribution is
if (strcmp(filterName,'Gaussian'))
    %Don't need any scaling, since we will scale it anyway
    %Use the standard deviation as the cut
    f = inline('exp(-(t./s).^2/2)','t','s');
elseif (strcmp(filterName,'HalfGauss'))
    %This will simulate real time gaussian filtering
    f = inline('exp(-(t./s).^2/2).*(t<=0)','t','s');
elseif (strcmp(filterName,'Butterworth'))
    %Again, no scaling, since we will scale it anyway
    %The cutoff frequency is half-power
    f = inline('1./sqrt( 1 + ( t / s ).^2 )','t','s');
else
    %Otherwise, use the hat filter
    f = inline('(t>=-s).*(t<=s)','t','s');
end%if

%Calculate the filter at all points
filt = f(D.T - D.T(D.count),cut);

%And normalize the filter
filt = filt / sum(filt);

%Now, apply the filter
XA = sum(bsxfun(@times,D.X,filt),1);

%Now, create a data object with the moving average filtered data
DA = Data(D.T(end,:),XA,D.K(end,:),D.S);
