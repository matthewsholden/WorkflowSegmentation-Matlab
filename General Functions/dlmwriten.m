%This function will write an n-dimensional tensor to file such that it can
%be read into an n-dimensional matrix (use the typical dlmwrite function,
%with some logic)

%Parameters fileName: The name of the file which we wish to write to
%Parameters M: The matrix which we want to write to file
%Parameters D: The delimiter character used in file

%Return status: Whether or not the function was successful
function status = dlmwriten(fileName,M,D)

%Indicate that the procedure is not complete yet
status=0;

%First, determine the size of the matrix M
sz = size(M);

%For the write procedure, all we want to do is to write the size of the
%matrix to file and then the tensor
dlmwrite(fileName,sz,D);

%To write the tensor to file, we will break it down into matrices using the
%recursive method defined below
dlmwriteappend(fileName,M,D);

%The procedure has successfully been completed
status=1;



%This function will help out in our dlmwriten method, which will work
%recursively to write each dimension of the matrix to file

%Parameters fileName: The name of the file which we wish to write to
%Parameters M: The matrix which we want to write to file
%Parameters D: The delimiter character used in file

%Return status: Whether or not the function was successful
function status = dlmwriteappend(fileName,M,D)

%Indicate the procedure is not complete
status=0;

%Determine the size of the tensor we wish to write to file
sz=size(M);
%Also, determine how many dimensions the tensor has left
dims=size(sz);

%If we only have a matrix left, then we can just append it to the file
if (dims(2) <= 2)
    dlmwrite(fileName,M,'-append','delimiter',D,'precision',10);
    %Otherwise, call this method separately on each slice of the first
    %dimension of the tensor
else
    for i=1:sz(1)
        dlmwriteappend(fileName,M(i,:),D);
    end
end

%The procedure is successfully completed
status=1;