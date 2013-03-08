%This function will take a sequence of LD points grouped by procedure, and
%compute the centroid of the LD points ending each task. This will give an
%estimate on the end states for all tasks

%Parameter D: Cell array of data objects

%Return endCentroid: Matrix of centroids of end of each task
%Return endMAD: Vector of max abs deviation for each end centroid
function [endCentroid  endDev] = calcEndCentroids(D)

%the number of tasks
numTask = calcMax( D, 'Task' );

%Create a cell array of with a matrix of end tasks for each task
endCentroidCell = cell( numTask, 1 );
endCentroid = zeros( numTask, D{1}.dim );
endDev = zeros( numTask, D{1}.dim );

%Iterate over all procedures
for p = 1:length(D)
    
    %Calculate the task transition points
    endLoc = find( ~~[diff( D{p}.K ); 1] );
    endTask = D{p}.K( endLoc );
    
    %Add to all the endCentroids
    for i = 1:length(endLoc)
        endCentroidCell{ endTask(i) } = cat( 1, endCentroidCell{ endTask(i) }, D{p}.X( endLoc(i) ) );
    end%for
   
end%for

%Iterate over all tasks, and find the average
for t = 1:numTask
    endCentroid( t, : ) = mean( endCentroidCell{t}, 1 );
end%for

%Iterate over all tasks, and find the maximum absolute difference
for t = 1:numTask
    endDev( t, : ) = max( abs( bsxfun( @minus, endCentroid( t, : ), endCentroidCell{t} ) ) );
end%for