%In this class we will define a concept called Data. Data will be like our
%vector X, except in won't only apply to our degrees of freedom, but, will
%also apply to our transformed degrees of freedom

classdef Data
    
    properties (SetAccess = private)
        %Store the time associated with each data point
        T;
        %This will store the actual data
        X;
        %Store the ground-truth task associated with each data point
        K;
        %Store the skill associated with each data point
        S;
        %Keep a count of how many data points we have
        n;
        %And a count of how many dimensions the data has
        dim;
        %The maximum task number
        maxTask;
        %Note that this object is specific to a particular procedure, so
        %the S value will be the only skill-level, do not keep a value for
        %the maximum skill-level
    end
    
    methods
        
        %This constructor creates an object with X defined in the
        %parameters
        function D = Data(t,x,k,s)
            %Assign T to t
            D.T = t;
            %Assign X to x
            D.X = x;
            %K to k
            D.K = k;
            %S to s
            D.S = s;
            %Calculate the dimensionality and number of data points
            [D.n D.dim] = size(x);
            %Calculate the total number of tasks
            D.maxTask = max(k);
        end
        
        
        %Calculate the task-wise mean value for each dimension
        function [mn sd] = taskStats(D)
            
            %Initialize the mean and standard deviation to zero
            mn = zeros(D.maxTask,D.dim);
            sd = zeros(D.maxTask,D.dim);
            count = zeros(D.maxTask,1);
            
            %Calculate the mean and standard deviation at the same time
            for i=1:D.n
               %Use the task as the index 
               mn(D.K(i),:) = mn(D.K(i),:) + D.X(i,:);
               sd(D.K(i),:) = sd(D.K(i),:) + D.X(i,:).^2;
               count(D.K(i)) = count(D.K(i)) + 1;
            end
            
            %Now, calculate the mean and standard deviation, iterating over
            %each task
            for k=1:D.maxTask
                %Calculate the mean for each task in each dimension
                mn(k,:) = mn(k,:) / count(k);
                %Take absolute value in case of roundoff errors causing an
                %imaginary value here
                sd(k,:) = abs( sqrt ( sd(k,:) / count(k) - mn(k,:).^2 ) );
            end
            
        end
        
        %This function will add noise to all degrees of freedom, as
        %specified by the parameters
        function DN = addNoise(D,X_Bs,X_Wt,X_Mx)
            %Calculate the stats for each task
            [mn sd] = D.taskStats();
            %Initialize our matrix X
            XN = size(D.X);
            %Add noise to each dimension
            for i=1:D.n
                for j=1:D.dim
                    %Determine what noise to add given the current task
                    XN(i,j) = D.X(i,j) + addNoise(j,D.K(i),sd',X_Bs,X_Wt,X_Mx);
                end
            end
            %Create a new Data object with added noise
            DN = Data(D.T,XN,D.K,D.S);
        end
        
        %This function will normalize a particular subset of the dimensions
        %for every time step. This will be useful for adding noise to
        %quaternions
        function DQ = normalize(D,Q)
            %Initialize the normalize data matrix
            XQ = D.X;
            %For each time step
            for i=1:D.n
                XQ(i,Q==1) = normr(D.X(i,Q==1));
            end
            %Now, create a new Data object with the required normalized
            %parts
            DQ = Data(D.T,XQ,D.K,D.S);
        end
        
        
        %Perform an orthogonal transformation on our data
        function DO = orthogonal(D,Param)
            %Perform the transform
            [TO XO KO] = orth(D.T,D.X,D.K,Param);
            %Create the new object storing the orthogonally transformed
            %data
            DO = Data(TO,XO,KO,D.S);
        end
        
        %Perform a principal component analysis on our data
        function [DP evector mn] = principal(D)
            %Perform the principal component analysis
            [XP evector mn] = pca(D.X);
            %Now, create the new data object with the pca transformed data
            DP = Data(D.T,XP,D.K,D.S);
        end
        
        %Perform a kmeans clustering using the appropriate weighting
        %calculated using the z3 weighting method
        function [DC C W] = wmeans(D,j)
            %Determine the weightings, using the z3 scheme
            W = z3weight(D.X);
            %Perform the clustering using the weighted wmeans method
            [XC C] = kmeansWeight(D.X,W,j);
            %Create a new object using the clusters as data now
            DC = Data(D.T,XC,D.K,D.S);
        end
        
        
    end
    
    
end