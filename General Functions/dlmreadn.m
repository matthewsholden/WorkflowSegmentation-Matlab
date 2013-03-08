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
rsz=size(rawData);

%Now, determine the size of the tensor M
%The dlmread will automatically pad the vector with zeros if the vector of
%size is shorter than the number of columns in the matrix
%Go through the first row of the column vector and determine size vectors
for i=1:rsz(2)
   if (rawData(1,i) ~= 0)
      sz(i) = rawData(1,i); 
   end
end

%Now, create our tensor M which has the specified size we just determined
M=zeros(sz);

%Now, read the data in from the file using the recursive method
M=dlmreadappend(rawData(2:end,:),M);




        
        
%This function will help out in our dlmreadn method, which will work
%recursively to write each dimension of the matrix to file

%Parameters rawData: The matrix of data we wish to convert to tensor
%Parameters M: The tensor which we want to write data to

%Return M: The updated tensor
function M = dlmreadappend(rawData,M)

%Determine the size of the tensor we wish to write to file
sz=size(M);
%Also, determine how many dimensions the tensor has left
dims=size(sz);

%If we only have a matrix left, then we can just append it to the file
if (dims(2) <= 2)
    %rawData isnt necessarily the correct size, it might be too big if the
    %number of dimensions is larger than the number of rows of rawData
    M=rawData(1:sz(1),1:sz(2));
    %Otherwise, call this method separately on each slice of the first
    %dimension of the tensor
else
    for i=1:sz(1)
        %Now, apply this recursive procedure to the block
        M(i,:)=dlmreadappend(rawData(i,:),M(i,:));
    end
end

%The procedure is successfully completed