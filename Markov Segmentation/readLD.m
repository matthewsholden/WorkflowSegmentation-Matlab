%This function will be responsible for reading the parameters for the
%projectio ninto lower dimensional space from file

%Parameter fileName: The name of th file in which the procedure keypoint
%record is stored

%Return elapse: The number of time steps to let pass between successive
%transformations
%Return history: The number of time steps used to calculate each
%interpolation
%Return interp: The number of interpolated points used to calculate each
%transformation
%Return order: The order of the trasnformation
%Return retain: The number of data points to keep in our current sequence
function [elapse history interp order retain] = readLD()

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, use a dlmread on the file to get a matrix with all of the values in
%the file
rawData = o.read('LD');

%We know that the data must be a 1x3 matrix
[one five] = size(rawData);


%The elapse is the first entry of the rawData matrix
elapse=rawData(1,1);

%The history is the second entry of the rawData matrix
history=rawData(1,2);

%The interp is the third entry of the rawData matrix
interp=rawData(1,3);

%The order is the thrid entry of the rawData matrix
order=rawData(1,4);

%The retain is the frouth entry of the rawData matrix
retain = rawData(1,5);
