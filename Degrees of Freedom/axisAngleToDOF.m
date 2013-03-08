%This function will create a vector of degrees of freedom from a tool axis
%angle and a reference axis angle

%Parameter w1: The vector about which the rotation occurs
%Parameter angle1: The angle of the rotation
%Parameter pos1: The position

%Return X: A vector of DOFs using quaternion rotation
function X = axisAngleToDOF(w1,angle1,pos1)

%Convert the tool to transformation matrix form
R = axisAngleToMatrix(w1,angle1);
M = eye(4);
M(1:3,1:3) = R;
M(1:3,4) = pos1(:)';

%Convert the resulting matrix to DOF (quaternion)
X = matrixToDOF(M);
