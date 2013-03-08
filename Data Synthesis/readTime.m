%This function will be responsible for reading the parameters for playing
%the procedure from file

%Return dt: The length of a time step
%Return length: The length of the needle to be shown when playing procedure
function [dt length] = readTime()

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, use a dlmread on the file to get a matrix with all of the values in
%the file
rawData = o.read('Time');

%We know that the data must be a 1x3 matrix
[one two] = size(rawData);


%The dt is the first entry of the rawData matrix
dt=rawData(1,1);

%The length is the second entry of the rawData matrix
length=rawData(1,2);
