%This function will train a Markov model via the Baum-Welch algorithm

%Parameter seq: A cell array where each row is a sequence of symbols
%Parameter initPi: An initial guess at the initial state distribution
%Parameter initA: An initial guess at the transition matrix
%Parameter initB: An initial guess at the observation probability matrix

%Return trainM: A trained Markover Model using initial and psuedo data
function trainM = hmmTrainMultiple(seq,initPi,initA,initB,pseudoPi,pseudoA,pseudoB)


%Initialize the matrices and vectors representing the Markov Model
%Use the pseudo matrices if provided
if (nargin < 3)
    pseudoPi = zeros( size(initPi) );
end%if
if (nargin < 4)
    pseudoA = zeros( size(initA) );
end%if
if (nargin < 5)
    pseudoB = zeros( size(initB) );
end%if


%Use a Markov Model to append the initial pi, A, B vectors together
initM = MarkovModel('Initial',initPi,initA,initB);


%Use a Markov Model to append the pseudo pi, A, B vectors together
pseudoM = MarkovModel('Pseudo',pseudoPi,pseudoA,pseudoB);


%Use the built-in training function to calulate trained Markov Model
[trainAP trainBP] = hmmtrain(seq,initM.getAP(),initM.getBP(),'Pseudotransitions',pseudoM.getAP(),'Pseudoemissions',pseudoM.getBP());


%Now, decompose the appended matrices into unappended matrices
trainA = trainAP(2:end,2:end);
trainPi = trainAP(1,2:end);
trainB = trainBP(2:end,:);

%Put together a trained Markov Model
trainM = MarkovModel('Train',trainPi,trainA,trainB);