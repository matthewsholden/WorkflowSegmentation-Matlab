%This function will perform a linear discriminant analysis on a set of
%data, finding a partition between the sets of data. It will return the
%transformation used, and the transformed data similar to the PCA function.

%Parameter X: A cell array of sets of data, each with the same number of
%dimensions, but perhaps with a different number of points
%Parameter numComp: The number of components we wish to keep
%Parameter Type: The type (class 'dependent' vs class 'independent') of
%principal component analysis we wish to do

%Return TD: The transformed data into a space where the class separation is
%maximized
%Return TV: The series of vectors over which we project our original data,
%the transformation vector
%Return MN: The mean of the data in each dimension
function [TD TV MN] = lda(X,numComp,Type)

%Turn off any warnings we might get due to poorly conditioned matrices
warning off all;

%Count the number of sets and dimensions and points
setNum = length(X);

%Now, create vectors to house the number of dimensions and points, noting
%that the dimension should be the same for all sets
dim = zeros(1,setNum);
n = zeros(1,setNum);

%Iterate over all sets and count
for i=1:setNum
    [n(i) dim(i)] = size(X{i});
end

%Find the mean for each set in each dimension
MN = cell(1,setNum);
%The overall mean for all data
mu = zeros(1,dim(1));

%First, find the mean for each set of data in each dimension
for i=1:setNum
    %Calculate the mean for each set
    MN{i} = mean(X{i},1);
    %Add to the overall mean
    mu = mu + ( MN{i} * n(i) ) / sum(n);
end


%The cell array of covariance matrices
cv = cell(1,setNum);
%The within class covariance
SW = zeros(dim(1),dim(1));
%The between class scatter
SB = 0;

%Calculate the covariance matrix for each set
for i=1:setNum
    %Calculate the covariance matrix
    cv{i} = cov(X{i});
    %Calculate the expected covariance of each class
    SW = SW + ( cv{i} * n(i) )/sum(n);
    %Calculate the between class scatter
    SB = SB + (MN{i} - mu)' * (MN{i} - mu);
end

%Initialize our cell array of transformed data
TD = cell(1,setNum);

%If we are doing the class-independent  transform
if (strcmp(type,'independent'))
    
    %Find the inverse of the sw matrix
    invsw = inv(SW);
    %Any NaNs or Infs must go to zero
    invsw(isnan(invsw) | isinf(invsw)) = 0;
    %Find the criterion matrix
    crit = invsw * SB;
    %Now, find the eigenvectors of the matrix crit
    [evector evalue] = eig(crit);
    
    %For the largest eigenvalues, transform all the data
    for i=1:setNum
        TD{i} = X{i} * evector(:,1:numComp);
    end
    
elseif (strcmp(type,'dependent'))
    
    %Initialize our cell arrays
    crit = cell(1,setNum);
    evector = cell(1,setNum);
    evalue = cell(1,setNum);
    
    for i=1:setNum
        %Find the inverse of the covariance matrix
        invcv = inv(cv{i});
        %Any NaNs or Infs must go to zero
        invsw(isnan(invsw) | isinf(invsw)) = 0;
        %Find the criterion matrix for each class
        crit{i} = invcv * SB;
        %Now, find the eigenvectors of the matrix crit
        [evector{i} evalue{i}] = eig(crit{i});
        %For the largest eigenvalues, transform all the data
        trans{i} = X{i} * evector{i}(:,1:k);
    end
    
end

%Initialize our vector of means for the transformed data
mnt = cell(1,setNum);
%Calculate the mean of the transformed data
for i=1:setNum
    %Calculate the mean for each set
    mnt{i} = mean(trans{i},1);
end

%Initialize our vector of indices for the test points
ix = zeros(1,size(test,1));

%If we are doing the class-independent  transform
if (strcmp(type,'independent'))
    
    %Transform the test vector
    testTrans = test * evector(:,1:k);
    
    %Calculate the distance between each set of mnt - testTrans
    for j=1:size(test,1)
        
        %The minimum distance
        minDist = Inf;
        %The minimum index
        ix(j) = 0;
        
        for i=1:setNum
            %Calculate if the current
            if (norm( testTrans(j,:) - mnt{i} ) < minDist)
                ix(j) = i;
                minDist = norm( testTrans(j,:) - mnt{i} );
            end
        end
        
    end
    
elseif (strcmp(type,'dependent'))
    
    %Initialize our cell array of transformed test data for each class
    %transformation
    testTrans = cell(1,setNum);
    
    for i=1:setNum
        %Transform the test vector
        testTrans{i} = test * evector{i}(:,1:k);
    end
    
    %Calculate the distance between each set of mnt - testTrans
    for j=1:size(test,1)
        %The minimum distance
        minDist = Inf;
        %The minimum index
        ix(j) = 0;
        for i=1:setNum
            if (norm(testTrans{i}(j,:)-mnt{i}) < minDist)
                ix(j) = i;
                minDist = norm( testTrans{i}(j,:) - mnt{i} );
            end
        end
    end
    
end


