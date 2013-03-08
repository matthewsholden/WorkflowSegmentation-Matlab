%Calculate the angle between the planned entry-target line and the actual
%entry-target line

%Parameter plannedEntry: The point at which we plan to insert the needle
%Parameter plannedTarget: The point at which we plan the needletip to end
%Parameter actualEntry: The point at which we actually insert the needle
%Parameter actualTarget: The ploint at which the needletip actually ends

%Return angleET: The angle between the planned and actual entry-target line
%Return entryDist: The distance between the actual and planned entrypoint
%Return targetDist: The distance between the actual and planned targetpoint
function [angleET entryDist targetDist] = EntryTarget(plannedEntry, plannedTarget, actualEntry, actualTarget)

%Find the vector specifying the planned entry-target line
plannedET = plannedTarget - plannedEntry;
%And normalize this
unitPlannedET = plannedET / norm (plannedET);

%Find the vector specifying the actual entry-target line
actualET = actualTarget - actualEntry;
%And normalize this
unitActualET = actualET / norm (actualET);

%Now, using the dot product, calculate the angle (in radians)
cosAngleET = dot(unitPlannedET, unitActualET);
angleET = acosd(cosAngleET);

%Also, calculate the distance between the entry points
entryDist = norm(plannedEntry-actualEntry);

%And the distance between the target points
targetDist = norm(plannedTarget-actualTarget);