%This function will be responsible for determine which Markov Model, given
%an array of Markov Models, was most likely to have produced the sequence

%Parameter seq: A single sequence of symbols (observations)
%Parameter M: An array of candidate Markov Models
%Parameter scale: A vector to which the probailities will be scaled

%Return ix: The index of the Markov Model in the array to most likely have
%prodcued the observed sequence
function [ix prob] = bestMarkov(seq,M,scale)

%Determine with what probability each Markov Model produced the sequence
prob = zeros(length(M),1);

%Create a cell array of sequences
cellSeq = cell(1,1);
%And assign the input sequence to the first cell of the cell array
cellSeq{1} = seq;

%Now, iterate over all Markov Models and determine the probabilities
%individually
for m=1:length(M)
    %Determine the probability of the current Markov Model
    cellProb = M{m}.seqProb(cellSeq);
    %Now read this value into the probability vector
    prob(m) = cellProb{1};
end

%Now, scale the probabilities appropriately if a scaling is provided
if (nargin == 3)
    prob = prob.*scale;
end

%Return the index of the most likely Markov Model
%If there exist no entries in prob that are zero or greater then they are
%all nonsensical, so we will return ix=0
if ( isempty( find(prob>=0) ) ) %#ok<EFIND>
    ix = 0;
    %Return a probability of zero
    prob = 0;
else
    ix = maxIndex(prob);
    %Also return the probability of this Markov Model reproducing the data
    prob = prob(ix);
end

