%This function will, given an axis angle representation of rotation, yield a
%rotation quaternion corresponding to this rotation

%Parameter w: The vector about which the rotation occurs
%Parameter angle: The angle of the rotation

%Return q: The rotation quaternion which the vector describes
function q = axisAngleToQuat(w,angle)

%First, ensure that w is normalized
w = w/norm(w);

%Now that we have this angle, calculate the quaternion
q(1) = w(1) * sind(angle);
q(2) = w(2) * sind(angle);
q(3) = w(3) * sind(angle);
q(4) = cosd(angle);
