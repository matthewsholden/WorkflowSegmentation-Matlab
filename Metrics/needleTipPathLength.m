%This function will calculate the path length of the motion of the tool
%(based only on the translational motion)

%Parameter D: The data object with the dofs in time
%Parameter Q: The components of the data object which are quaternions

%Return pathLength: The path length travelled by the needletip
function pathLength = needleTipPathLength(D,Q)

%If Q is not specified, assume:
%8 components, 1-3 translation
if (nargin < 2)
    Q = [0 0 0 1 1 1 1 1];
end%if

%Grab the correct components from the data object
X_Trans = D.X(:,~Q);

%Calculate the differences between successive time steps (in the
%translational components)
X_Diff = diff(X_Trans);

%Find the path length from one time step to another
X_Step = sqrt( sum( X_Diff.^2, 2 ) );

%Sum over all time steps
pathLength = sum( X_Step );
