%This function will be used to convert a quaternion to a rotation matrix
%such that plotting the needle will be easier (since rotation matrices are
%more favourable for plotting the needle)

%Parameter q: A vector representation of the quaternion

%Return R: The rotation matrix associated with the quaternion
function R = quatToMatrix(q)

%This algorithm is outlined fairly explicitly in [LandisMarkely 2008]

%First, set the size of R
R=zeros(3,3);

%Now, we can use the algorithm...

%The first row of the matrix
R(1,1)=q(1)^2-q(2)^2-q(3)^2+q(4)^2;
R(1,2)=2*q(1)*q(2)+2*q(3)*q(4);
R(1,3)=2*q(1)*q(3)-2*q(2)*q(4);

%The second row of the matrix
R(2,1)=2*q(1)*q(2)-2*q(3)*q(4);
R(2,2)=-q(1)^2+q(2)^2-q(3)^2+q(4)^2;
R(2,3)=2*q(2)*q(3)+2*q(1)*q(4);

%The third row of the matrix
R(3,1)=2*q(1)*q(3)+2*q(2)*q(4);
R(3,2)=2*q(2)*q(3)-2*q(1)*q(4);
R(3,3)=-q(1)^2-q(2)^2+q(3)^2+q(4)^2;