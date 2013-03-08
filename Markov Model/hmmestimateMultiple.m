%This function will outperform the previously implemented method for
%estimating the parameter of a Markov Model with a known state path and
%observation sequence. The basic idea is to count the number of transitions
%and the number of observations then normalize each row of A and B.
%Additionally, use an initial distribution vector

%Parameter symSeq: A cell array of sequences of symbols observed by the Markov Model
%Parameter stateSeq: A cell array of sequences of states produced by the Markov Model

%Return pi: An initial state distribution vector
%Return A: An estimate of the transition matrix for this Markov Model
%Return B: An estimate of the observation matrix for this Markov Model
function [pi A B] = hmmestimateMultiple(symSeq,stateSeq,pseudoPi,pseudoA,pseudoB)

%Now, find the number of sequences and the length of the maximum sequence
numSeq = length(symSeq);

%Initialize the stateMax and symbolMax to be one each, since all Markov
%Models must have at least one state and one symbol
stateMax = 1;
symbolMax = 1;
%Go through each cell array and find the maximum state and maximum symbol
for j=1:numSeq
    %Determine the maximum of each sequence and compare to the overall
    %maximum for both symbols and states, picking the largest
    if (max(symSeq{j}) > symbolMax)
        symbolMax = max(symSeq{j});
    end
    
    if (max(stateSeq{j}) > stateMax)
        stateMax = max(stateSeq{j});
    end
end


%Now we must initialize the results such that we can adjust them according
%to our observations
pi = zeros(1,stateMax);
A = zeros(stateMax,stateMax);
B = zeros(stateMax,symbolMax);
%Construct a cell array of sequence lengths
seqLength = cell(1,numSeq);

%Iterate over all sequences
for j=1:numSeq
    %Determine the length of each sequence
    seqLength{j} = length(symSeq{j});
    %Go through the sequence
    for k=1:seqLength{j}
        %First, consider the transitions
        %If we have the first element of the sequence then consider this in the
        %initial state distribution vector
        if (k == 1)
            %Add one to the initial distribution vector
            pi(stateSeq{j}(k)) = pi(stateSeq{j}(k)) + 1;
            %Otherwise, we can add to the transition matrix
        else
            %Add one to the transition matrix
            A(stateSeq{j}(k-1),stateSeq{j}(k)) = A(stateSeq{j}(k-1),stateSeq{j}(k)) + 1;
        end
        
        %Second, consider the observations
        %Add one to the observation matrix
        B(stateSeq{j}(k),symSeq{j}(k)) = B(stateSeq{j}(k),symSeq{j}(k)) + 1;
        
    end
end

%Now, add all of the pseudo emissions and pseudotransitions
if (nargin == 5)
    pi = padAdd(pi,pseudoPi);
    A = padAdd(A,pseudoA);
    B = padAdd(B,pseudoB);
end

%Now we must normalize these matrices. Summing a matrix yields a vector
%with the sum of each column, but we want the rows to sum to one, so we
%must find the sum of the transpose
sumPi = sum(pi,2);
sumA = sum(A,2);
sumB = sum(B,2);

%Now, pi is easily normalized...
pi = pi ./ sumPi;

%Determine the final number of symbols from the B matrix
[states symbols] = size(B);

%Normalize each row (corresponding to a state) by iterating over each row
for i=1:states
    %Now if sumA or sumB is zero then do not divide, but rather just leave
    %zeros for that row
    if (sumA(i,1) > 0)
        A(i,:) = A(i,:) ./ sumA(i,1);
    end
    if (sumB(i,1) > 0)
        B(i,:) = B(i,:) ./ sumB(i,1);
    end
end

%This is all
