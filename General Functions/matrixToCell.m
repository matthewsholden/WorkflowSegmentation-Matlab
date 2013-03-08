%This function will turn a multidimensional array into a cell array of
%matrices

%Parameter M: A multidimensional matrix (array)

%Return C: A cell array of matrices
function C = matrixToCell(M)

%Get the size of the array
szM = size(M);
ndim = length(szM);

%Create a cell array of appropriate size
if (ndim > 3)
    C = cell(szM(3:end));
elseif (ndim == 3)
    C = cell(1,szM(end));
else
    C = cell(1,1);
end%if

%Iterate over the final dimensions of the array
for i=1:prod(szM(3:end))
    %Assign the last dimensions of the matrix to the cell array
    C{i} = M(:,:,i);
end%for

%Repeat this process so we only have matrices of cell arrays
if (length(size(C)) > 2)
    C = matrixToCell(C);
end%if