%This function will, given a 4x4 transformation matrix, convert it into an
%array of the different degrees of freedom (with rotation expressed as
%quaternions)

%Parameter A: A transformation matrix describing the position of the object

%Return X: An array of the degrees of freedom (with rotation in quaternion)
%representing that same position
function X = matrixToDOF(A)

%Ok, so first, we know that this will produce eight degrees of freedom:
%x,y,z,q1,q2,q3,q4,status
dof=8;
X=zeros(8,1);

%We can easily read of the translations from the transformation matrix
X(1,1)=A(1,4);  %x
X(2,1)=A(2,4);  %y
X(3,1)=A(3,4);  %z

%Now, we can use the function for converting rotation matrices to
%quaternions on the rotation part of this transformation matrix
q=matrixToQuat(A(1:3,1:3));

%Now, we read the quaternions into the array of DOFS
X(4,1)=q(1);    %q1
X(5,1)=q(2);    %q2
X(6,1)=q(3);    %q3
X(7,1)=q(4);    %q4

%Finally, the status should be set to zero (as always)
X(8,1)=0;
