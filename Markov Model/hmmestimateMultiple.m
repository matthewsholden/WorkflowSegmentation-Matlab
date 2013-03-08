%Estimate the parameters of a Markov Model by counting the transitions
%between different states and the productions of observations

%Parameter symSeq: Cell array symbol sequences observed
%Parameter stateSeq: Cell array state sequences observed

%Return estM: A Markov Model with the estimated parameters
function estM = hmmEstimateMultiple(symbolSeq,stateSeq,pseudoPi,pseudoA,pseudoB)


%Determine the number of sequences of observations
numSeq = length(symbolSeq);


%Determine the number of states and the number of symbols for the model
numState = max( max( cellToMatrix(stateSeq) ) );
numSymbol = max( max( cellToMatrix(symbolSeq) ) );


%Initialize the matrices and vectors representing the Markov Model
%Use the pseudo matrices if provided
if (nargin > 2)
    pi = pseudoPi;
else
    pi = zeros(1,numState);
end%if
if (nargin > 3)
    A = pseudoA;
else
    A = zeros(numState,numState);
end%if
if (nargin > 4)
    B = pseudoB;
else
    B = zeros(numState,numSymbol);
end%if


%Iterate over all sequences
for j=1:numSeq
    
    %Collect the current state and symbol sequences
    currStateSeq = stateSeq{j};
    currSymbolSeq = symbolSeq{j};

    %Iterate over all elements in the sequence
    for k=1:length(currStateSeq)

        if (k == 1)
            %For first element of the sequence, add to initial pi vector
            pi(currStateSeq(k)) = pi(currStateSeq(k)) + 1;
        else
            %Otherwise, add to transition matrix A
            A(currStateSeq(k-1),currStateSeq(k)) = A(currStateSeq(k-1),currStateSeq(k)) + 1;
        end%if
        
        %For each state, add to observation matrix based on symbol
        B(currStateSeq(k),currSymbolSeq(k)) = B(currStateSeq(k),currSymbolSeq(k)) + 1;
        
    end%for
    
end%for


%Normalize all rows of the matrices
pi = bsxfun( @rdivide, pi, sum(pi,2) );
A = bsxfun( @rdivide, A, sum(A,2) );
B = bsxfun( @rdivide, B, sum(B,2) );


%If any entries of pi, A, B are NaNs, replace these entries with zeros
pi(isnan(pi)) = 0;
A(isnan(A)) = 0;
B(isnan(B)) = 0;


%Create a Markov Model with the estimated parameters
estM = MarkovModel('Est',pi,A,B);
