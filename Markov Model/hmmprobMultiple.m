%This function will determine the probability that a Markov Model produced
%a sequence of observations

%Parameter seq: A cell array where each row is a sequence of symbols
%Parameter MM: The Markov Model in question

%Return prob: A vector of probabilities that each seqeunce of observations
%was produced by the Markov Model
function prob = hmmProbMultiple(seq,MM)


%If input sequence is not cell, then make it into a cell array
if ( ~iscell(seq) )
    seq = matrixToCEll(seq);
end


%Determine number of sequences from the seq cell array
numSeq = length(seq);


%Initialize the cell array of probabilities
prob = cell(1,numSeq);


%Iterate over all sequences in the seq cell array
for j=1:numSeq
    
    %Determine probability of data using built-in hmmdecode method
    [~, logProb] = hmmdecode( seq{j}, MM.getAP(), MM.getBP() );
    
    %Add the true probability to the cell array of probabilities
    prob{j} = exp(logProb);
    
end%for