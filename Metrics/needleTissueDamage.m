%This function will calculate the tissue damage metric. The surface area of
%tissue swept out by the needle

%Parameter D: A data object containing the needle trajectory
%Parameter Q: The quaternion (nonrelevant) components of the trajectory
%Parameter corner: The corners of the phantom tissue prism

%Return damage: The surface area of tissue swept out by the needle
function damage = needleTissueDamage(D,Q,corner)

%Initialize the tissue damage to zero
damage = 0;

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
    
    %If both the current and previous are in prism, then calculate sweep
    if (prevInPrism && currInPrism)
        %Add the triangles area to the tissue damage
        damage = damage + areaTriangle( prevEntry, prevTip, currTip );
        damage = damage + areaTriangle( prevEntry, currEntry, currTip );
    end%if
    
    %Assign what was the current to be the previous
    prevInPrism = currInPrism;
    prevEntry = currEntry;
    prevTip = currTip;    
    
end%for