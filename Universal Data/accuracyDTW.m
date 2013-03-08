%This function computes the DTW distance between the true task segmentation
%and the test segmentation

%Parameter trueTask: The true task segmentation
%Parameter segTask: The test task segmentation

%Return d: The dynamic time warping distance between the two segmentations
%Return offset: The offset in transition time identification
function [d ssod numOff] = accuracyDTW( trueTask, segTask )

%Calculate the segmentation lengths
n = length(trueTask);
m = length(segTask);

%Initialize our matrix for a dynamic programming approach
DTW = zeros( n, m );

for i = 1:m
    DTW(1,i) = Inf;
end

for j = 1:n
    DTW(j,1) = Inf;
end

DTW(1,1) = 0;

% Calculate the distances using the dynamic programming approach
for i = 2:n
    for j = 2:m
        
        if ( trueTask(i) == segTask(j) )
            cost = 0;
        else
            cost = 1;
        end
        
        costArray = [ DTW(i-1,j), DTW(i,j-1), DTW(i-1,j-1) ];
        
        DTW(i,j) = cost + min(costArray);
        
    end
    
end

%DTW

%Traverse matrics backwards, jumping on diagonals only when necessary
i = n;
j = m;
offset = zeros(0,2);
while ( i > 1 && j > 1 && ~(i==2 && j==2) )

    if ( DTW(i-1,j) <= DTW(i,j) )
        i = i - 1;
        continue;
    end
        
    if ( DTW(i,j-1) <= DTW(i,j) )
        j = j - 1;
        continue;
    end
        
    if ( DTW(i-1,j-1) <= DTW(i,j) )
       offset = cat( 1, offset, [i j] );
       i = i - 1;
       j = j - 1;
       continue;
    end
       
        
end

% Take the average distance
d = DTW(n,m) / n;

%Find sum of squared transtion distances
ssod = sum( ( offset(:,1) - offset(:,2) ) .^ 2 );

numOff = size(offset,1);