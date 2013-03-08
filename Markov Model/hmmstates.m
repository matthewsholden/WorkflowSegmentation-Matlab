%This function will calculate what sequence of states was most likely to
%have produced the sequence of observations and the probability

%Parameter seq: The sequence of observations
%Parameter MM: The Markov Model being tested

%Return stateProb: State optimized log probability of observation sequence
%Return stateSeq: State sequence most likely to yield observation sequence
function [stateProb stateSeq] = hmmStates(seq,MM)


%Calculate the observation sequence length
n = length(seq);


%If there are no observations, then return [1 []]
if ( n == 0 )
   stateProb = 1;
   stateSeq = [];
   return;
end%if


%Calculate the number of states and symboles from the matrix B
[numState numSymbol] = size(MM.getB());


%Initialize the delta and psi probability variables
delta = zeros( n, numState );
psi = zeros( n, numState );


%Use logs to avoid rounding errors (replace addition with mulitplication)
logPi = log(MM.getPi());    logA = log(MM.getA());  logB = log(MM.getB());


%Initialize delta using initial state distribution
delta(1,:) = logPi + logB(:,seq(1))';
psi(1,:) = zeros( size(logPi) );


%Iterate over all times
for t = 2:n
  
   %Calculate the most likely state for each observation
   [maxProb maxIndex] = max( bsxfun( @plus, delta(t-1,:)', logA ) );
   
   %Calculate delta and psi
   delta(t,:) = maxProb + logB(:,seq(t))';
   psi(t,:) = maxIndex;
    
end%for


%Terminate the sequence; determinine state-optimized probability and path
[stateProb stateSeq(n)] = max( delta(n,:) );

%Backtrace the sequence to find the most likely state at each step
for t = (n-1):-1:1
    
    %Use the value of psi to determine the most likely state path
    stateSeq(t) = psi( t+1, stateSeq(t+1) );
    
end%for