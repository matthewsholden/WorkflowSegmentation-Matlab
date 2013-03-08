%This function will, given a vector representing a rotation, yield a
%rotation quaternion corresponding to this rotation, as determined by the
%method proposed by Davenport, and described by Bruccoleri

%Parameter v: The vector describing the rotation
%Parameter r: The axis of rotation from which the rotation matrix shall
%rotate points

%Return q: The rotation quaternion which the vector describes
function q = vectorToQuat(v,r)

%First, ensure that v and r are normalized
v = v/norm(v);
r = r/norm(r);

%First, calculate the angle between the two vectors
phi = acos ( dot(v,r) );

%Now, calculate the axis of rotation
e = cross(v,r);
%And normalize, if the norm of e is non-zero
if ( norm(e) ~= 0 )
    e = e/norm(e);
end

%Now, we can calculate sigma
sig = e * tan ( phi / 4 );
%Calculate the squared norm of sigma
sig2 = norm(sig)^2;

%We can readily calculate the quaternion components from our vector sigma
q(1) = 2 * sig(1) / ( 1 + sig2 );
q(2) = 2 * sig(2) / ( 1 + sig2 );
q(3) = 2 * sig(3) / ( 1 + sig2 );
q(4) =  ( 1 - sig2 ) / ( 1 + sig2 );



