%This function will be used to convert a rotation matrix to quaternions
%such that the data can be received as a rotation matrix, but the algorithm
%can work with quaternions

%Parameter R: The rotation matrix associated with the state of system

%Return R: The quaternion associated with the rotation matrix
function q = matrixToQuat(R)

%We will use the modified Shepperd' algorithm, as outlined fairly
%explicitly in [LandisMarkley 2008]

%First, set the size of q
q42=zeros(4,1);
x=zeros(4,1);

%Now, we can use the Landis-Markley algorithm

%First, find the largest member of the quaternions
%To do this, we will first find the trace of R
trR = trace(R);

%For q1...
q42(1)=1-trR+2*R(1,1);
%For q2...
q42(2)=1-trR+2*R(2,2);
%For q3...
q42(3)=1-trR+2*R(3,3);
%For q4...
q42(4)=1-trR+2*trR;

%Now, we find the largest of these in magnitude
[~, i] = max(q42);

%So, depending on our maximum index, we have
if (i == 1)
    x(1)=1+R(1,1)-R(2,2)-R(3,3);
    x(2)=R(1,2)+R(2,1);
    x(3)=R(1,3)+R(3,1);
    x(4)=R(2,3)-R(3,2);
end

if (i == 2)
    x(1)=R(2,1)+R(1,2);
    x(2)=1+R(2,2)-R(3,3)-R(1,1);
    x(3)=R(2,3)+R(3,2);
    x(4)=R(3,1)-R(1,3);
end

if (i == 3)
    x(1)=R(3,1)+R(1,3);
    x(2)=R(3,2)+R(2,3);
    x(3)=1+R(3,3)-R(1,1)-R(2,2);
    x(4)=R(1,2)-R(2,1);
end

if (i == 4)
    x(1)=R(2,3)-R(3,2);
    x(2)=R(3,1)-R(1,3);
    x(3)=R(1,2)-R(2,1);
    x(4)=1+R(1,1)+R(2,2)+R(3,3);
end

%Now that we have computed the x vector, we obtain the quaternions from a
%simpe scaling of this x vector
q=x/norm(x);

