%This function will implement a moving average filter, for an arbitrary
%distributions of weightings (need not integrate to one)

function DA = avgFilter(D,cut,filterName)

%Determine what the distribution is
if (strcmp(filterName,'Gaussian'))
    %Don't need any scaling, since we will scale it anyway
    %Use the standard deviation as the cut
    f = inline('exp(-(t./s).^2/2)','t','s');
else
    %Otherwise, use the hat filter
    f = inline('(t>=-s).*(t<=s)','t','s');
end%if

XA = zeros(size(D.X));

%Iterate over all time steps
for k = 1:D.n
    
    %Calculate the filter at all points
    filt = f(D.T - D.T(k),cut);
    %And normalize the filter
    filt = filt / sum(filt);
    
    %Now, apply the filter
    XA(k,:) = sum(bsxfun(@times,D.X,filt'),1);    
    
end%for

%Now, create a data object with the moving average filtered data
DA = Data(D.T,XA,D.K,D.S);
