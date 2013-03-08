%This function will create a vector of degrees of freedom from a tool axis
%angle and a reference axis angle

%Parameter w1: The vector about which the rotation occurs
%Parameter angle1: The angle of the rotation
%Parameter pos1: The position
%Parameter w2: The vector about which the rotation occurs
%Parameter angle2: The angle of the rotation
%Parameter pos2: The position

%Return X: A vector of DOFs using quaternion rotation
function X = axisAngleToDOF(w1,angle1,pos1,w2,angle2,pos2)

%Convert the tool to transformation matrix form
R1 = axisAngleToMatrix(w1,angle1);
M1 = eye(4);
M1(1:3,1:3) = R1;
M1(1:3,4) = pos1(:)';

%Convert the reference to transformation matrix form
R2 = axisAngleToMatrix(w2,angle2);
M2 = eye(4);
M2(1:3,1:3) = R2;
M2(1:3,4) = pos2(:)';

%Now, calculate the insertion position relative to the reference
%The reference position is already relative to the reference sensor
%Get the insertion reference matrix
o = Organizer();
M3 = o.read('Tool');

M = inv(M3) * inv(M2) * M1;

%Finally, convert the resulting matrix to DOF (quaternion)
X = matrixToDOF(M);
