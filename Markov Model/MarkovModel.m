%This class represents a Markov Model, including both the parameters and
%the three major algorithms (these are all that we are interseted in for
%now, but we might be interested in other algorithms later...)

classdef MarkovModel
    
    %Declare the parameters governing the Markov Model...
    properties (SetAccess = private)
        %The name of the Markov Model
        name;
        %The initial state distribution
        pi;
        %The matrix governing the transition probabilities
        A;
        %The matrix governing the emission probabilities
        B;
    end
    
    %The methods required for the Markov Model are: (getPi, getA, getB, getParam)
    methods
        
        %The constructor simply takes all of the Markov Model parameters
        function M = MarkovModel(name,pi,A,B)
            M.name = name;
            M.pi = pi;
            M.A = A;
            M.B = B;
        end
        
        %Allow the user to create initial parameters which are uniform such
        %that a training method may follow (must input the required number
        %of symbols and states to specify how large to make these parameter
        %matrices)
        function M = uniform(M,symbols,states)
            %The pi vector must have equal probabilites in all entries
            M.pi = ones(1,states) ./ states;
            %Similarly the A and B matrices will have all equal entries
            %where each row is required to add to unity
            M.A = ones(states,states) ./ states;
            M.B = ones(states,symbols) ./ symbols;
        end
        
        %We will allow a method to read the parameters of the Markov Model
        %from a file
        function M = read(M)
            %Use the readMarkov function we have written
            [M.pi M.A M.B] = readMarkov(M.name);
        end
        
        %We will allow a method to write the parameters of the Markov Model
        %to file such that we can save the parameters
        function M = write(M)
            %Use the writeMarkov function which we have written
            writeMarkov(M.name,M.pi,M.A,M.B);
        end
        
        %This method returns the name of the Markov Model
        function res = getName(M)
            res = M.name;
        end
        
        %This method returns the initial state distribution
        function res = getPi(M)
            res = M.pi;
        end
        
        %This method returns the transition probability matrix
        function res = getA(M)
            res = M.A;
        end
        
        %This method returns the emission probability matrix
        function res = getB(M)
            res = M.B;
        end
        
        %Finally, this method returns the transition and emission matrices
        %concatenated with the initial state distribution (because this is
        %how Matlab deals with markov models)
        function [res1 res2] = getParam(M)
            %First, determine the number of states and symbols from the
            %emission probability matrix
            [states symbols] = size(M.B);
            %Now, we must concatenate the original matrices with the initial
            %probability distribution such that Matlab has the appropriate
            %parameters for its Markov Models
            
            %First, make the results the right sizes
            res1 = zeros(states+1,states+1);
            res2 = zeros(states+1,symbols);
            %Now assign the values
            res1(2:end,2:end) = M.A;
            res1(1,2:end) = M.pi;
            
            res2(2:end,:) = M.B;
        end
        
        %Return the transition probability matrix with the concatenated
        %initial state distribution vector
        function res = getAP(M)
            %Just use the previous function, but only return one of the
            %values
            [AP BP] = M.getParam();
            res = AP;
        end
        
        %Return the emission probability matrix with the concatenated
        %initial state distribution vector
        function res = getBP(M)
            %Just use the previous function, but only return one of the
            %values
            [AP BP] = M.getParam();
            res = BP;
        end
        
        %Given the parameters, generate a random sequence of observations
        %and output them
        function res = seqGen(M,length)
            %Use the hmmgenerate algorithm
            res = hmmgenerate(length, M.getAP(), M.getBP());
        end
        
        %Now, we want to be able to do all three important algorithms given
        %a sequence which has been inputted and the parameters stored in
        %this object. Use the concatenated matrices for all functions in
        %the class
        
        %This will use the forward-backward algorithm to determine the
        %probability that the model indeed produced the sequence of
        %observations
        function res = seqProb(M,seq)
            %Use the hmmprobMulitple algorithm we have implemented
            res = hmmprobMultiple(seq,M.getPi(),M.getA(),M.getB());
        end
        
        %This method will use the viterbi algorithm to determine the most
        %likely state path to have produced the observations
        function [prob path] = statePath(M,seq)
            %Use the hmmviterbi algorithm
            [prob path] = hmmstates2(seq,M.getPi(),M.getA(),M.getB());
        end
        
        %This method will be used to train the algorithm via the Baum-Welch
        %method...
        function M = train(M,seq,pseudoPi,pseudoA,pseudoB)
            %Use the Baum-Welch algorithm
            
                        
            %If we have a predefined size, keep it
            if (nargin < 3)
                pseudoPi = zeros(size(M.getPi()));
            end
            if (nargin < 4)
                pseudoA = zeros(size(M.getA()));
            end
            if (nargin < 5)
                pseudoB = zeros(size(M.getB()));
            end
            
            %Train the Markov Model
            [trainPi trainA trainB] = hmmtrainMultiple(seq,M.getPi(),M.getA(),M.getB(),pseudoPi,pseudoA,pseudoB);

            %Now, we have the unconcatenated matrices
            M.A = trainA;
            M.pi = trainPi;
            M.B = trainB;
        end
        
        %This method will be used to estimate the parameters of the Markov
        %Model using the viterbi training method (where we know the state
        %sequence in addition to knowing the observation sequence)
        function M = estimate(M,seq,states,pseudoPi,pseudoA,pseudoB)
            %Use the algorithm for estimation (counting
            %transitions/observations)
            
            %If we have a predefined size, keep it
            if (nargin < 4)
                pseudoPi = zeros(size(M.getPi()));
            end
            if (nargin < 5)
                pseudoA = zeros(size(M.getA()));
            end
            if (nargin < 6)
                pseudoB = zeros(size(M.getB()));
            end
            
            %Estimate the Markov Model parameters
            [estPi estA estB] = hmmestimateMultiple(seq,states,pseudoPi,pseudoA,pseudoB);
            
            %Now, we have the unconcatenated matrices
            M.pi = estPi;
            M.A = estA;
            M.B = estB;
        end
        
    end
    
end