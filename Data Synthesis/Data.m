%In this class we will define a concept called Data. Data will be like our
%vector X, except in won't only apply to our degrees of freedom, but, will
%also apply to our transformed degrees of freedom

classdef Data
    
    properties (SetAccess = private)
        %Time stamp of each data point
        T;
        %Observation at each time stamp
        X;
        %Ground truth task segmentation
        K;
        %Skill of performer
        S;
        %Count of data points; dimensionality of observations
        count;  dim;
        %Maximum task number
        maxTask;
    end %Properties
    
    methods
        
        %Constructor creates data object as defined by parameters
        function D = Data(t,x,k,s)
            
            D.T = t;
            D.X = x;
            D.K = k;
            D.S = s;
            
            %Calculate the dimensionality and number of data points
            [D.count D.dim] = size(x);
            
            %Calculate the total number of tasks
            D.maxTask = max(k);
            
        end%function
        
        
        %Calculate the task-wise mean value for each dimension
        function [mn sd] = taskStats(D)
            
            %Initialize the mean and standard deviation to zero
            mn = zeros(D.maxTask,D.dim);
            sd = zeros(D.maxTask,D.dim);
            taskCount = zeros(D.maxTask,1);
            
            %Calculate mean and standard deviation
            for i=1:D.count
                mn(D.K(i),:) = mn(D.K(i),:) + D.X(i,:);
                sd(D.K(i),:) = sd(D.K(i),:) + D.X(i,:).^2;
                taskCount(D.K(i)) = taskCount(D.K(i)) + 1;
            end
            
            %Calculate mean and standard deviation for each task
            for k=1:D.maxTask
                %Calculate mean for each task in each dimension
                mn(k,:) = mn(k,:) / taskCount(k);
                %Absolute value avoids roundoff errors yielding imaginary values
                sd(k,:) = abs( sqrt ( sd(k,:) / taskCount(k) - mn(k,:).^2 ) );
            end
            
        end%function
        
        %This function will add noise to all degrees of freedom
        function DN = addNoise(D,X_Bs,X_Wt,X_Mx)
            
            %Initialize our matrix of noisy data
            XN = size(D.X);
            
            %Calculate stats for each task
            [~, sd] = D.taskStats();
            
            %Add noise to each dimension independently
            for i=1:D.count
                for j=1:D.dim
                    %Determine what noise to add given the current task
                    XN(i,j) = D.X(i,j) + addNoise(j,D.K(i),sd',X_Bs,X_Wt,X_Mx);
                end
            end
            
            %Create a new Data object with added noise
            DN = Data(D.T,XN,D.K,D.S);
            
        end%function
        
        %This function will add human noise to all degrees of freedom
        function DN = addHumanNoise(D,X_Bs,X_Wt,X_Mx,Human)
            
            %Calculate the stats for each task
            [~, sd] = D.taskStats();
            
            %Add noise to the entire procedure
            DN = humanNoise(D,sd',X_Bs,X_Wt,X_Mx,Human);
            
        end%function
        
        %Normalize a particular subest of dimensions for all time steps
        %In particular, use this to normalize noisy quaternions
        function DQ = normalizeQuaternion(D,Q)
            
            %Initialize the normalized data matrix
            XQ = D.X;
            
            %For each time step
            for i=1:D.count
                XQ(i,Q==1) = normr(D.X(i,Q==1));
            end
            
            %Create a new Data object with the required normalized parts
            DQ = Data(D.T,XQ,D.K,D.S);
            
        end%function
        
        
        %Standardize all dofs of the data (mean = 0, var = 1)
        %This will standardize by task (mean = 0, var = 1 for each task)
        function DM = standardize(D)
            
            %Initialize the standardized data matrix
            XM = D.X;
            
            %Grab the stats for this data object
            [mn sd] = D.taskStats();
            
            %For each time step
            for i=1:D.count
                XM(i,:) = ( XM(i,:) - mn(D.K(i),:) ) ./ sd(D.K(i),:);
            end
            
            %Ensure that any XM that is NaN or Inf is assigned zero
            XM(isnan(XM) | isinf(XM)) = 0;
            
            %Create a new Data object with the required standardized parts
            DM = Data(D.T,XM,D.K,D.S);
            
        end%function
        
        
        %Calculate the derivative of the data at every point
        function DV = derivative(D,order)
            
            %Use derivCalc function to calculate derivative to any order
            V = derivCalc(D.T,D.X,order);
            %Create a new Data object with velocities
            DV = Data(D.T,V,D.K,D.S);
            
        end%function
        
        
        %Filter the entire data set using moving average filtering
        function DS = movingAverage(D,cut,filterName)
            %Apply the moving average filtering algorithm
            DS = avgFilter(D,cut,filterName);
        end%function
        
        
        %Perform moving average filtering for the most recent point
        function DS = movingAverageLast(D,cut,filterName)
            %Apply the moving average filtering to only the last point
            DS = avgFilterLast(D,cut,filterName);
        end%function
        
        
        %Filter the entire data set using Fourier low-pass filtering
        function DS = fourier(D,cut,filterName)
            %Apply the Fourier low-pass filtering algorithm
            DS = fourierFilter(D,cut,filterName);
        end%function
        
        
        %Filter the entire data set using a smoothing spline
        function DS = sspline(D,alpha)
            %Calculate the smoothing spline
            DS = smoothingSpline(D,alpha);
        end%function
        
        
        %Filter the entire data set using double exponential smoothing
        function DS = dexp(D,ab)
            %Calculate the double exponential smoothing
            DS = doubleExpSmooth(D,ab(1),ab(2));
        end%function
        
        
        %Perform Kalman filtering for all points in the data matrix
        function DS = kalman(D,N)
            %Apply the Kalman filtering algorithm
            DS = kalmanFilter(D,N(1),N(2));
        end%function
        
        
        %Perform Kalman filtering for the most recent point
        function [DS P] = kalmanLast(D,DX,P,N)
            %The length of the data
            k = size(D.T,1);
            %Calculate the number of steps to use in calculations
            NS = min(N(1),floor((k-2)/2));
            NZ = min(N(2),floor((k-2)/2));
            %Only if the time steps are large enough
            if (NS > 1 && NZ > 1)
                %Apply the Kalman filtering algorithm to only the last point
                [XS P] = kalmanFilterLast(DX.X,D.X(1:end-1,:),D.X(end),P,NS,NZ);
                %Return the sequence with the last point replaced
                DS = Data(D.T,cat(1,D.X(1:end-1,:),XS),D.K,D.S);
            else
                DS = Data(D.T,D.X,D.K,D.S);
            end%if
            
        end%function
        
        
        %Perform an orthogonal transformation on our data
        function DO = orthogonal(D,orthParam)
            %Perform the transform
            DO = orthogonalTransform(D,orthParam);
        end%function
        
        
        %Perform an orthogonal transformation on our data
        function DO = orthogonalLast(D,orthParam)
            %Perform the transform
            DO = orthogonalTransformLast(D,orthParam);
        end%function
        
        
        %Perform a principal component analysis on our data
        function [DP Trans Mn] = pca(D,pcaParam)
            
            %Perform the principal component analysis
            [XP Trans Mn] = pca(D.X,pcaParam);
            %Create the new data object with the pca transformed data
            DP = Data(D.T,XP,D.K,D.S);
            
        end%function
        
        
        %Transform data via the calculated prinicipal component analysis
        function DT = pcaTransform(D,Eigen,Mean)
            
            %Make the mean zero in each dimension
            XT = bsxfun(@minus,D.X,Mean);
            
            %Apply the covariance eigenvector multiplication transform
            XT = (XT * Eigen);
            
            %Create a data object with the resulting transformed data
            DT = Data(D.T,XT,D.K,D.S);
            
        end%function
        
        
        %Perform a class dependent linear discriminant analysis on data
        function [DL Trans Mn] = lda(D,D_Cell)
            
            %Assume that the data objects are in cells by task
            %Convert into cell arrays of positions
            [~, XL] = DataCell(D_Cell);
            
            %Perform the lda on the cell array of dofs
            [X_Trans Trans Mn] = lda(XL);
            
            %Reconstruct the date objects of lda transformed data
            DL = cell(size(D_Cell));
            for i=1:numel(D_Cell)
                DL{i} = Data(D_Cell{i}.T, X_Trans{i}, D_Cell{i}.K, D_Cell{i}.S);
            end%for
            
        end%function
        
        
        %Transform data by calculated lda transformation for specific class
        function DT = ldaTransform(D,Trans)
            
            %Apply the covariance eigenvector multiplication transform
            XT = D.X * Trans;
            %Create the object of lda transformed data
            DT = Data(D.T, XT, D.K, D.S);
            
        end%function
        
        
        %Weighted kmeans clustering over specified number of centroids
        function [DC Centroids centDis SSD clout] = fwdkmeans(D,k,W)
            
            %Perform the clustering using the weighted wmeans method
            [XC Centroids centDis SSD clout] = fwdkmeans(D.X,k,W);
            
            %Create a new object using the clusters as data now
            DC = Data(D.T,XC,D.K,D.S);
            
        end%function
        
        
        %Calculate the closest cluster centroid to each point
        function [DC dis] = findCluster(D,Centroids,W,clout)
            
            %Calculate distance from each point to each centroid
            d = interDistances(D.X,Centroids,W);
            
            %Scale the distances by the centroud clouts
            %d = bsxfun(@times, d, clout');
            
            %Calculate the nearest cluster and the distance to it
            [dis XC] = min(d,[],2);
            
            %Create a new data object with the cluster index as observation
            DC = Data(D.T,XC,D.K,D.S);
            
        end%function
        
        
        %Calculate the closest LDA cluster
        function [DC Trans_Comp dis] = findLDACluster(D,Trans,Centroids,W)
            
            %Preallocate the cell arrays of data
            DL = cell(size(Trans));
            DCC = cell(size(Trans));
            dis = cell(size(Trans));
            
            %Iterate over all classes
            for j = 1:length(Trans)
                %Perform an LDA transform for all classes
                DL{j} = D.ldaTransform(Trans,j);
                %And find the closest cluster
                [DCC{j} dis{j}] = DL{j}.findCluster(Centroids,W);
            end%for
            
            %Put together the cell array of distances to find the smallest
            dis = cellToMatrix(dis);
            %Ensure that dis is a row vector
            if (iscolumn(dis))
                dis = dis';
            end%if
            %Calculate the smallest distances
            [dis Trans_Comp] = min(dis,[],2);
            %Put together the cell array of clusters
            [~, XCC] = DataCell(DCC);
            XCC = cellToMatrix(XCC);
            %Ensure that XCC is a row vector
            if (iscolumn(XCC))
                XCC = XCC';
            end%if
            %Determine the chosen cluster, and its index
            XC = diag(XCC(:,Trans_Comp));
            
            %Output the data object of cluster numbers
            DC = Data(D.T,XC,D.K,D.S);
            
        end%function
        
        
        %Remove all entries of data object corresponding to false on second
        function D_Rem = remove(D,DTF)
            
            %If the objects have difference lengths, then do nothing
            if (D.count ~= DTF.count)
                D_Rem = D;
                return;
            end%if
            
            %Create an empty vector of observations with removals
            T_Rem = [];
            X_Rem = [];
            K_Rem = [];
            
            %If they have the same length, iterate over all observations
            for i = 1:D.count
                
                %Test if the true/false data object is true
                if ( DTF.X(i,:) )
                    %Add the current observation to the matrix of observations
                    T_Rem = cat(1, T_Rem, D.T(i,:) );
                    X_Rem = cat(1, X_Rem, D.X(i,:) );
                    K_Rem = cat(1, K_Rem, D.K(i,:) );
                end%if
                
            end%for
            
            %Output the data object with removed observations
            D_Rem = Data(T_Rem, X_Rem, K_Rem, D.S);
            
        end%function
        
        
        %Given two Data objects, get one transform relative to the other
        function D_Rel = relative(D1,D2,inv1,inv2)
            
            %If the objects have difference lengths, then do nothing
            if (D1.count ~= D2.count)
                D_Rel = D1;
                return;
            end%if
            
            %Create an empty vector of relative observations
            X_Rel = [];
            
            %If they have the same length, iterate over all observations
            for i = 1:D1.count
                %Calculate the transformation matrix for each Data object
                M1 = dofToMatrix( D1.X(i,:) );
                M2 = dofToMatrix( D2.X(i,:) );
                
                %Invert, depending on the type
                if (inv1)
                    M1 = inv(M1);
                end%if
                if (inv2)
                    M2 = inv(M2);
                end%if
                
                %Now, calculate the relative dofs
                X_Curr = matrixToDOF( M1 * M2 );
                %Add the current observation to the matrix of observations
                X_Rel = cat(1, X_Rel, X_Curr);
            end%for
            
            %Output the data object with relative observations
            D_Rel = Data(D1.T, X_Rel, D1.K, D1.S);
            
        end%function
        
        
        %Apply calibration matrices to a Data object
        function D_Cal = calibration(D,C1,C2)
            
            %Create an empty vector of relative observations
            X_Cal = [];
            
            %Iterate over all observations
            for i = 1:D.count
                %Calculate the transformation matrix for each Data object
                M = dofToMatrix( D.X(i,:) );                
                %Now, calculate the relative dofs
                X_Curr = matrixToDOF( C1 * M * C2 );
                %Add the current observation to the matrix of observations
                X_Cal = cat(1, X_Cal, X_Curr);
            end%for
            
            %Output the data object with relative observations
            D_Cal = Data(D.T, X_Cal, D.K, D.S);
            
        end%function
        
        
        %Convert a Data object of dofs to a Data object of needle endpoints
        function D_Points = dofToPoints(D,needleOr)
            
            %Create an empty matrix of points
            X_Points = [];
            
            %Iterate over all observations
            for i = 1:D.count
                %Calculate the transformation matrix for each Data object
                M = dofToMatrix( D.X(i,:) );                
                %Now, calculate the points
                [X_Curr1 X_Curr2] = matrixToPoints( M, needleOr);
                X_Curr = cat(2, X_Curr1', X_Curr2');
                %Add the current observation to the matrix of observations
                X_Points = cat(1, X_Points, X_Curr);
            end%for
            
            %Output the data object with relative observations
            D_Points = Data(D.T, X_Points, D.K, D.S);
            
        end%function
        
        
        %Concatenate two data objects, by sticking the records end to end
        function D_Cat = concatenate(D1,D2)
            
            %Concatenate everthing in the data object
            T_Cat = cat(1,D1.T,D2.T);
            X_Cat = cat(1,D1.X,D2.X);
            K_Cat = cat(1,D1.K,D2.K);
            S_Cat = cat(1,D1.S,D2.S);
            
            %Create a new data object with the concatenated data
            D_Cat = Data(T_Cat,X_Cat,K_Cat,S_Cat);
            
        end%function
        
        
        %Concatenate two data objects' degrees of freedom
        function D_Cat = concatenateDOF(D1,D2)
            
            %If the objects have difference lengths, then do nothing
            if (D1.count ~= D2.count)
                D_Cat = D1;
                return;
            end%if
            
            %Concatenate the degrees of freedom
            X_Cat = cat(2,D1.X,D2.X);
            
            %Create a new data object with the concatenated data
            D_Cat = Data(D1.T,X_Cat,D1.K,D1.S);
            
        end%function
        
        
    end %Methods
    
    
end %Classdef