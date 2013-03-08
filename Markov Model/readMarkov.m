%This function is responsible for reading a Markov Model from file, and
%returning its parameters

%Parameter fileName: The name of th file in which the procedure keypoint
%record is stored

%Return pi: A vector with the initial distribution of states
%Return A: A matrix of probabilities of state transitions
%Return B: A matrix of probabilities of each observation for each state
function [pi A B] = readMarkov(name)

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, use a dlmread on the file to get a matrix with all of the values in
%the file
rawData = o.read(name);

%We know that the data must be a (states)x(1+states+symbols) matrix
[states symbols] = size(rawData);

%For our purposes define the number of rows in the pi matrix
one = 1;

%The file will be of the form:
%0 pi 0
%0 A  B
%So it will have (numbers of column == states + symbols), (number of rows
%== states + one)
states = states - one;
symbols = symbols - states - one;

%The pi vector is the first row of the rawData matrix
pi=rawData(one,(one+1):(one+states));

%The A transition matrix is the next states rows in the rawData matrix
A=rawData((one+1):(states+one),(one+1):(one+states));

%The B observation matrix is the following symbols rows in the rawData
%matrix
B=rawData((one+1):(states+one),(one+states+1):(one+states+symbols));
