%This function will take a cell array of transformation (possibly produced
%by a class dependent linear discriminant analysis) and pad lower
%dimensional transformations with zero such that they are all of the same
%dimension

%Parameter TV: A cell array of transformation vectors
%Parameter dim: The dimension along which we care

%Return TVD: A cell array of transformation vectors with the same
%dimensionality
function TVD = dimTransformation(TV,dim)

%The maximum number of components shall initially be zero
maxComp = 0;

%Ensure that all of the transformations are of the same dimension, by
%padding any lower dimensional ones with zeros
for i = 1:length(TV)
    if (size(TV{i},dim) > maxComp)
       maxComp = size(TV{i},dim); 
    end
end

%Initialize our cell array of dimensionalized transformation vectors
TVD = cell(size(TV));

%Now pad all of the lower dimensional transformations
for i = 1:length(TV)
    %Determine the supposed padding
    padding = zeros(1,ndims(TV{i}));
    %Add the supposed number of components to the padding
    padding(dim) = maxComp - size(TV{i},dim);
    
    %Now actually pad the array
    TVD{i} = padarray(TV{i},padding,0,'post');
end