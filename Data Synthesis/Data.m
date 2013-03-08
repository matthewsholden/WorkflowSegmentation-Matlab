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
        
        %This function will add human noise to all degrees of freedom, as
        %specified by the parameters
        function DN = addHumanNoise(D,X_Bs,X_Wt,X_Mx,Human)
            %Calculate the stats for each task
            [mn sd] = D.taskStats();
            %Add noise to the entire procedure, since for human
            %Determine what noise to add given the current task
            DN = humanNoise2(D,sd',X_Bs,X_Wt,X_Mx,Human);
        end
        
        %This function will normalize a particular subset of the dimensions
        %for every time step. This will be useful for adding noise to
        %quaternions
        function DQ = normalizeQuaternion(D,Q)
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
        
        %This function will normalize all degrees of freedom for the data
        %such that degree of freedom has mean zero and standard deviation
        %one
        function DM = normalize(D)
            %Initialize the normalize data matrix
            XM = D.X;
            %Grab the stats for this data object
            [mn sd] = D.taskStats();
            %For each time step
            for i=1:D.n
                XM(i,:) = ( XM(i,:) - mn(D.K(i),:) ) ./ sd(D.K(i),:);
            end
            %Ensure that any XM that is NaN or Inf is assigned zero
            XM(isnan(XM) | isinf(XM)) = 0;
            %Now, create a new Data object with the required normalized
            %parts
            DM = Data(D.T,XM,D.K,D.S);
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
        function [DP Trans Mn] = principal(D,userComp)
            %Perform the principal component analysis
            [XP Trans Mn] = pca(D.X,userComp);
            %Now, create the new data object with the pca transformed data
            DP = Data(D.T,XP,D.K,D.S);
        end
        
        %Perform a linear discriminant analysis on our data
        function [DP Trans W] = linear(D,userComp)
            %Create a cell array of X's such that we can store each task to
            %a cell array
            X_Task = cell(1,D.maxTask);
            %Break the data down by procedure, iterating over all tasks
            for t = 1:D.maxTask
                X_Task{t} = D.X(D.K==t,:);
            end

            %Perform the lda analysis
            [XL_Task Trans] = lda2(X_Task,userComp,'dependent');
            %Create a matrix to store the transformed data in
            XL = zeros(size(D.X,1),size(Trans{1},2));
            
            %Now, recombine the cell array we have received back into a
            %single matrix of dofs in time
            for t = 1:D.maxTask
                XL(D.K==t,1:size(XL_Task{t},2)) = XL_Task{t};
            end
            
            %Determine the class weightings
            W = classWeight(XL_Task);
            
            %Now, create the new data object with the lda transformed data
            DP = Data(D.T,XL,D.K,D.S);
        end
        
        %Perform a pca transformation, via an addition, followed by a
        %multiplication. This will be useful for a pca recovery.
        function DT = pcaTransform(D,Trans,Mn)
            %First, for each dimension, subtract off the mean
            XT = bsxfun(@plus,D.X,Mn);
            
            %Now apply the transformation vector to the data
            XT = (XT * Trans);
            
            %Now, create a data object with the resulting transformed data
            DT = Data(D.T,XT,D.K,D.S);
        end
        
        %Perform a lda transformation, by breaking the data down into
        function DT = ldaTransform(D,Trans)
            %Create a cell array of data objects, each with the transformed
            %data by the lda transform for each task
            DT = cell(1,length(Trans));
            XT = cell(1,length(Trans));
            %Iterating over all tasks...
            for t = 1:length(Trans)
                %Now, for each task, perform the multiplication
                XT{t} = (D.X * Trans{t});
                
                %Now, create a data object with the resulting transformed data
                DT{t} = Data(D.T,XT{t},D.K,D.S);
            end
            
        end
        
        %Perform a lda transformation, by breaking the data down into
        function DT = ldaTransformTask(D,Trans)
            %Create a cell array of data objects, each with the transformed
            %data by the lda transform for each task
            XT = [];
            %Iterating over all tasks...
            for t = 1:D.maxTask
                %Break the procedure down into its tasks
                X_Task = D.X(D.K==t,:);
                
                %Now, for each task, perform the multiplication
                X_Task = (X_Task * Trans{t});
                
                %We must pad the transformed data with zeros, noting that
                %the transformed data will not have greater dimension than
                %the untransformed data
                XT = padcat(1,XT,X_Task);

            end
            
            %Now, create a data object with the resulting transformed data
            DT = Data(D.T,XT,D.K,D.S);
            
        end
        
        %Perform a kmeans clustering using the appropriate weighting
        %calculated using the z3 weighting method
        function [DC C] = wmeans(D,k,W)
            %Perform the clustering using the weighted wmeans method
            [XC C] = kmeansWeight(D.X,W,k);
            %Create a new object using the clusters as data now
            DC = Data(D.T,XC,D.K,D.S);
        end
        
        %Given we already know the centroids for the clustering, find the
        %clusters that a set of points belong to, also, return the distance
        %from our point to this closest centroid
        function [DC dis] = findCluster(D,Cent,W)
            %Calculate the distance from each point to each centroid using
            %the appropriate norm
            d = interDistances(D.X,Cent,W);
            
            %Initialize out vector of clustered data
            XC = zeros(size(D.X,1),1);
            %And our vector of distances
            dis = zeros(size(D.X,1),1);
            
            %Return the index yielding the minimum distance to a centroid
            %for each point
            for i=1:size(D.X,1)
                [dis(i) XC(i)] = min(d(i,:));
            end
            
            %Create a new data object with the cluster index as observation
            DC = Data(D.T,XC,D.K,D.S);

        end
        
        
        %Concatenate two data objects, by just sticking the records end to
        %end
        function D_Cat = concatenate(D1,D2)
            %Concatenate the time
            T_Cat = cat(1,D1.T,D2.T);
            %Concatenate the dofs
            X_Cat = cat(1,D1.X,D2.X);
            %Concatenate the tasks
            K_Cat = cat(1,D1.K,D2.K);
            %Concatenate the skill
            S_Cat = cat(1,D1.S,D2.S);
            %Create a new data object with the concatenated data
            D_Cat = Data(T_Cat,X_Cat,K_Cat,S_Cat);
        end
        
    end
    
    
end