%This function will, given a sequence of observations, and an initial state
%distribution, a transition matrix, and an observation matrix, determine
%what sequences of states is most likely to have produced the sequence of
%observations, and what the probability of this sequence of states
%reproducing this sequence of observations is.

%Parameter obs: A sequence of observations found
%Parameter Pi: An initial state distribution of the Markov Model
%Parameter A: A matrix of state transitions
%Parameter B: A matrix of observation probabilities for each state

%Return stateProb: The state optimized log probability that the sequence of
%observations occurred
%Return stateSeq: The most likely sequence of states to have produced the
%observed sequence of observations
function [stateProb stateSeq] = hmmstates2(obs,pi,A,B)

%Let n be the length of the observation sequence
n = length(obs);

%If there are no observations, then return [1 []]
if ( n == 0 )
   [stateProb stateSeq] = max(log(pi));
   return;
end

%Initialize our variables of note
delta = zeros(n,length(A));
psi = zeros(n,length(A));

%Calculate the log of everything such that we can use addition, rather than
%multiplication to calculate probabilities such that we do not get
%ridiculously small numbers. Avoid rounding errors.
logPi = log(pi);    logA = log(A);  logB = log(B);

%First, initialize delta using the initial conditions provided by the
%initial state distribution
delta(1,:) = logPi + logB(:,obs(1))';
psi(1,:) = zeros( size(logPi) );

%Now, recurse over all time
for t = 2:n
   %Calculate the best delta for the next step
   
   %First, calculate the best i for each j
   [maxProb maxIndex] = max( bsxfun(@plus,delta(t-1,:)',logA) );
   
   %Now, calculate delta and psi
   delta(t,:) = maxProb + logB(:,obs(t))';
   psi(t,:) = maxIndex;
    
end

%Finally, terminate the sequence, and determining the state-optimized
%probability and the best state path
[stateProb stateSeq(n)] = max( delta(n,:) );

%Now, we must backtrace the sequence
for t = (n-1):-1:1
    %Use the value of psi to determine the most likely state path
    stateSeq(t) = psi(t+1,stateSeq(t+1));
end