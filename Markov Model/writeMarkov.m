%This function will be responsible for writing a Markov Model (defined only
%by its parameters to file)

%Parameter fileName: The name of the file in which the Markov Model
%parameters shall be stored
%Parameter pi: A vector specifying the initial distribution of states in
%the Markov Model
%Parameter A: A matrix specifying the probability of transition between any
%two states in the Markov Model
%Parameter B: A matrix specifiying the probability of observing each
%outcome given the state we are in

%Return status: Whether or not the function was a success
function status = writeMarkov(name,pi,A,B)

%Initialize the status to zero to indicate we are not done yet
status=0;

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, determine the sizes of all of our matrices
[one states] = size(pi);
[states states] = size(A);
[states symbols] = size(B);

%We will write our parameters to file in the following way since this way
%the size work out and it is in the format of the initial distribution
%appended Markov Model
% 0 pi 0
% 0 A  B

%Now, we must construct our matrix rawData such that we can write it to
%file all as one matrix fairly readily
rawData=zeros(one+states,one+states+symbols);

%Now, add each of the above parameters to the rawData matrix appropriately
%such that we can write it to file
rawData(one,(one+1):(one+states)) = pi;
rawData((one+1):(states+one),(one+1):(one+states)) = A;
rawData((one+1):(one+states),(one+states+1):(one+states+symbols)) = B;
    
%Now that we have composed our rawData matrix, write it to file
status = o.write(name,rawData); 