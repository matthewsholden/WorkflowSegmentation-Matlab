%This function will, given a 4x4 transformation matrix, convert it into an
%array of the different degrees of freedom (with rotation expressed as
%quaternions)

%Parameter A: A transformation matrix describing the position of the object
%Parameter Trans1: A pre-multiplication matrix
%Parameter Trans2: A post-multiplication matrix

%Return X: An array of the degrees of freedom (with rotation in quaternion)
%representing that same position
function X = matrixToDOF(A,Trans1,Trans2)

%Ok, so first, we know that this will produce eight degrees of freedom:
% x, y, z, q1, q2, q3, q4, status
dof=7;
X=zeros(1,dof);

%Post-multiply the transformation matrix
if (nargin > 2)
   A = A * Trans2; 
end

%Pre-multiply the transformation matrix
if (nargin > 1)
   A = Trans1 * A;
end

%Read the translations from the transformation matrix
X(1,1) = A(1,4);  %x
X(1,2) = A(2,4);  %y
X(1,3) = A(3,4);  %z

%Now, we can use the function for converting rotation matrices to
%quaternions on the rotation part of this transformation matrix
q=matrixToQuat(A(1:3,1:3));

%Now, read quaternions into the array of DOFS
X(1,4)=q(1);    %q1
X(1,5)=q(2);    %q2
X(1,6)=q(3);    %q3
X(1,7)=q(4);    %q4

%Finally, the status should be set to zero (as always)
X(1,8)=0;
