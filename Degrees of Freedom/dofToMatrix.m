%This function will, given a vector of dofs, convert it into a 4x4 transformation matrix

%Parameter X: The vector of dofs
%Parameter Reg: A registration matrix
%Parameter Rot: A rotation matrix

%Return A: The transformation matrix resulting from the dofs
function A = dofToMatrix(X,Reg,Rot)

%Ok, so first, we know that we have eight degrees of freedom:
%x,y,z,q1,q2,q3,q4,status
dof=8;

%And we create a 4x4 matrix
A = eye(4);

%Add the translations
A(1,4) = X(1);  %x
A(2,4) = X(2);  %y
A(3,4) = X(3);  %z

%Inser the rotation matrix
A(1:3,1:3) = quatToMatrix(X(4:7));

%If a rotation transform is provided, then apply it. Note that no rotation
%corresponds to the needle in the [-1 0 0] direction.
if (nargin > 2)
   A = A / Rot; 
end
%If a registration transform is provided, then apply it
if (nargin > 1)
   A = Reg \ A;
end