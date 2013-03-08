%This function will perform a linear discriminant analysis on a set of
%data, finding a partition between the sets of data. It will return the
%transformation used, and the transformed data similar to the PCA function.

%Parameter X: A cell array of sets of data, each with the same number of
%dimensions, but perhaps with a different number of points
%Parameter userComp: The number of components we wish to keep
%Parameter Type: The type (class 'dependent' vs class 'independent') of
%principal component analysis we wish to do

%Return TD: The transformed data into a space where the class separation is
%maximized
%Return TV: The series of vectors over which we project our original data,
%the transformation vector
%Return MN: The mean of the data in each dimension
function [TD TV MN] = lda2(X,userComp,Type)

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

%Initialize our cell array of transformed data, and transformation vector
TD = cell(1,setNum);
TV = cell(1,setNum);

%If we are doing the class-independent  transform

%Initialize our cell arrays
crit = cell(1,setNum);
evector = cell(1,setNum);
evalue = cell(1,setNum);
jordan = cell(1,setNum);

for i=1:setNum
    
    if (strcmp(Type,'independent'))
        
        %Find the inverse of the sw matrix
        invsw = pinv(SW);
        %Any NaNs or Infs must go to zero
        invsw(isnan(invsw) | isinf(invsw)) = 0;
        %Find the criterion matrix
        crit{i} = invsw * SB;
        
    elseif (strcmp(Type,'dependent'))
        
        %Find the inverse of the covariance matrix
        invcv = pinv(cv{i});
        %Any NaNs or Infs must go to zero
        invcv(isnan(invcv) | isinf(invcv)) = 0;
        %Find the criterion matrix for each class
        crit{i} = invcv * SB;
        
    end
    
    %Now, find the eigenvectors of the matrix crit
    [evector{i} jordan{i}] = eig(crit{i});
    %Convert the Jordan canonical form into a vector of eigenvalues, since I
    %believe the eigenvalues will always be real (and exist).
    evalue{i} = diag(jordan{i});
    %Flip the eigenvector and eigenvalue vector since we want the eigenvalues
    %in order from largest to smallest
    [evalue{i} eix] = sort(evalue{i},'descend');
    evector{i} = evector{i}(:,eix);
    
    %Determine the number of components we should use
    numComp = calcComp(evalue{i},userComp);
    %The transformation vector is the first numComp components of evector
    TV{i} = evector{i}(:,1:numComp);
    
end

%Ensure all of the transformations are of the same dimensionality
TV = dimTransformation(TV,2);

for i = 1:setNum
    %For the largest eigenvalues, transform all the data
    TD{i} = X{i} * TV{i};
end


%Ensure that we output zero mean, because in lda we do not care about the
%mean
MN = zeros(1,size(TV,2));
vr = zeros(1,size(TV,2));

%Find the within class variance
for i = 1:setNum
    %Calculate the variance for each variable
    vr(i) = mean(var(X{i}));
end