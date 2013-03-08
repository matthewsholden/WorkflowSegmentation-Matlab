%This function will write an n-dimensional tensor to file such that it can
%be read into an n-dimensional matrix (use the typical dlmwrite function,
%with some logic)

%Parameters fileName: The name of the file which we wish to write to

%Return M: An n-dimensional tensor of the data written to file
function M = dlmreadn(fileName)

%First, get a matrix consisting of all of the data written to file (as a
%matrix)
rawData=dlmread(fileName);

%First, get the size of the rawData matrix
rawSz=size(rawData);

%Now, determine the size of the tensor M
sz = rawData(1,:);
%The dlmread will automatically pad the vector with zeros if the vector of
%size is shorter than the number of columns in the matrix
%Go through the first row of the column vector and determine size vectors
sz = sz(sz~=0);

%Now, read the data in from the file, assuring that the data has not be
%accidentally extended by zeros due to the size
M = rawData(2:end,1:prod(sz(2:end)));

%And reshape this matrix of data to the correct dimensions
M = reshape(M,sz);
