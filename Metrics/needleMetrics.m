%This function will calculate the tissue damage metric. The surface area of
%tissue swept out by the needle

%Parameter D: A data object containing the needle trajectory
%Parameter corner: The corners of the phantom tissue prism
%Parameter Q: The quaternion (nonrelevant) components of the trajectory

%Return timeTotal: The total time of procedure
%Return timeInside: The time the needle tip was inside the phantom
%Return pathTotal: The total needle tip path length of the procedure
%Return pathInside: The needle tip path length inside the phantom
%Return tissueDamage: The surface area of tissue swept out by the needle
function [timeTotal timeInside pathTotal pathInside tissueDamage] = needleMetrics(D,corner,Q)

%If Q is not specified, assume:
%8 components, 1-3 translation
if (nargin < 3)
    Q = [0 0 0 1 1 1 1 1];
end%if

%Initialize the metrics to zero
timeTotal = 0;
timeInside = 0;
pathTotal = 0;
pathInside = 0;
tissueDamage = 0;

%The total time is trivially the last time step minus the first
timeTotal = max( D.T ) - min( D.T );
%The total path length is calculated by our function
pathTotal = needleTipPathLength( D, Q );

%Whether the previous point was in the prism, and its intersection location
prevInPrism = false;
prevEntry = [0 0 0];
prevTip = [0 0 0];

%Iterate over all time steps
for i = 1:D.count
    
    %Calculate whether the current point is in the prism
    [currInPrism currEntry] = prism( corner, dofToMatrix( D.X(i,:) ) );
    currEntry = currEntry';
    currTip = D.X(i,~Q);

    %If both the current and previous are in prism
    if (currInPrism)
        
        %Add the time stamp difference to the total time inside
        timeInside = timeInside + ( D.T(i) - D.T(i-1) );
        
        %Add path length difference to total path length inside
        pathInside = pathInside + norm( D.X(i,~Q) - D.X(i-1,~Q) );
        
        %Add the triangles area to the tissue damage
        tissueDamage = tissueDamage + areaTriangle( prevEntry, prevTip, currEntry );
        tissueDamage = tissueDamage + areaTriangle( prevTip, currEntry, currTip );
        
    end%if
        
    %Assign what was the current to be the previous
    prevInPrism = currInPrism;
    prevEntry = currEntry;
    prevTip = currTip;    
    
end%for