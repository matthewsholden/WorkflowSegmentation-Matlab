%This function will write an n-dimensional tensor to file such that it can
%be read into an n-dimensional matrix (use the typical dlmwrite function,
%with some logic)

%Parameters fileName: The name of the file which we wish to write to
%Parameters M: The matrix which we want to write to file
%Parameters D: The delimiter character used in file

%Return status: Whether or not the function was successful
function rawData = dlmwriten(fileName,rawData,D)

%First, determine the size of the matrix M
sz = size(rawData);

%If no input delimiter is provided, assume that the desired delimiter is a
%tab
if (nargin < 3)
    D = '\t';
end

%For the write procedure, all we want to do is to write the size of the
%matrix to file and then the tensor
dlmwrite(fileName,sz,D);

%To write the tensor to file, we will break it down into matrices using the
%recursive method defined below
dlmwrite(fileName,rawData,'-append','delimiter',D,'precision','%.6f');