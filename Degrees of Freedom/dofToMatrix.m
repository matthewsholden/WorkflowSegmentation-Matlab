%This function will, given a vector of dofs, convert it into a 4x4 transformation matrix

%Parameter X: The vector of dofs
%Parameter Trans1: A pre-multiplication transformation
%Parameter Trans2: A post-multiplication transformation

%Return A: The transformation matrix resulting from the dofs
function A = dofToMatrix(X,Trans1,Trans2)

%And we create a 4x4 matrix
A = eye(4);

%Add the translations
A(1,4) = X(1);  %x
A(2,4) = X(2);  %y
A(3,4) = X(3);  %z

%Inser the rotation matrix
A(1:3,1:3) = quatToMatrix(X(4:7));

%Apply the post-multiplication transformation
if (nargin > 2)
   A = A / Trans2; 
end
%Apply the pre-multiplication transformation
if (nargin > 1)
   A = Trans1 \ A;
end