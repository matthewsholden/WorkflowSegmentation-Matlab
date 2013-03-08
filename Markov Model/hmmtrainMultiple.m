%This function will train a Markov model via the Baum-Welch algorithm using
%sequences of different lengths. Any sequence shorter than the longest
%sequence must be padded with zeros

%Parameter seq: An cell array where each row is a sequence of symbols
%Parameter initPi: An initial guess at the initial state distribution
%Parameter initA: An initial guess at the transition matrix
%Parameter initB: An initial guess at the observation probability matrix

%Return trainPi: A trained initial state distributino
%Return trainA: A trained transition matrix
%Return trainB: A trained observation matrix
function [trainPi trainA trainB] = hmmtrainMultiple(seq,initPi,initA,initB,pseudoPi,pseudoA,pseudoB)

%Now, append the A and B matrices with the pi vector for initial state
%distribution using a Markov Model
initM = MarkovModel('Initial',initPi,initA,initB);


%Train the Markov Model as usual with the unpadded parameters, using cells
%instead
if (nargin == 5)
    pseudoM = MarkovModel('Pseudo',pseudoPi,pseudoA,pseudoB);
    [trainAP trainBP] = hmmtrain(seq,initM.getAP(),initM.getBP(),'Pseudotransitions',pseudoM.getAP(),'Pseudoemissions',pseudoM.getBP());
else
    [trainAP trainBP] = hmmtrain(seq,initM.getAP(),initM.getBP());
end


%Now, decompose the appended matrices into unappended matrices
trainA = trainAP(2:end,2:end);
trainPi = trainAP(1,2:end);
trainB = trainBP(2:end,:);