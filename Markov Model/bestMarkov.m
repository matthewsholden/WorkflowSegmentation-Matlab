%This function will determine which Markov Model, given a cell array of
%Markov Models, most likely produced an observation sequence

%Parameter seq: A single sequence of symbols (observations)
%Parameter M: A cell array of candidate Markov Models
%Parameter scale: A vector to which the probailities will be scaled

%Return ix: Index of Markov Model most likely to produce observed sequence
%Return prob: Probabilities of best Markov Model producing sequence
function [ix prob] = bestMarkov(seq,M,scale)


%Iterate over all Markov Models and determine individual probabilities
prob = zeros(length(M),1);
for m=1:length(M)
    
    %Determine the probability of the current Markov Model
    logProb = M{m}.statePath(seq);
    %Now read this value into the probability vector
    prob(m) = exp(logProb);
    
end%for


%Scale probabilities by the provided scaling
if (nargin > 2)
    prob = prob .* scale;
end


%Return the index of the most likely Markov Model
if ( isinf(prob) || ~prob )
    ix = 0;
    prob = 0;
else
    %Calculate index and probability of best Markov Model for data
    ix = maxIndex(prob);
    prob = prob(ix);
end%if

