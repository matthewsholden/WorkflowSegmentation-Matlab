%This function will determine the probability that a Markov Model produced
%a sequence of observations

%Parameter seq: A cell array where each row is a sequence of symbols
%Parameter pi: The initial state distribution
%Parameter A: The transition matrix
%Parameter B: The observation probability matrix

%Return prob: A vector of probabilities that each seqeunce of observations
%was produced by the Markov Model
function prob = hmmprobMultiple(seq,pi,A,B)

%Determine the number of sequences and the length of the sequences from the
%seq matrix
numSeq = length(seq);

%Initialize our probability cell array
prob = cell(1,numSeq);

%Now, concatenate our initial distibution vector into our transition and
%observation matrices using a Markov Model
M = MarkovModel('Prob',pi,A,B);

%Iterate over all rows of sequences in the seq matrix
for j=1:numSeq
   %Allow the current sequence we are considering to be one row of the
   %sequence matrix, and only the non-zero columns
   currSeq = seq{j};
    
   %Determine the probability of this Markov Model producing the data using
   %the hmmdecode method previously implemented in Matlab
   [pstates logProb] = hmmdecode(currSeq,M.getAP(),M.getBP());

   %Now, take an exponential of the probability and add it to the
   %probability return vector
   prob{j} = exp(logProb);
end