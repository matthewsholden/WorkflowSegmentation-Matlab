%This function will convert a rotation in axis angles to a rotation matrix

%Parameter w: The vector about which the rotation occurs
%Parameter angle: The angle of the rotation in degrees

%Return R: The rotation matrix
function R = axisAngleToMatrix(w,angle)

%First, ensure that w is normalized
w = w/norm(w);

%Now, use the formula
sint = sind(angle);
cost = cosd(angle);
cost1 = 1 - cost;

%Set the rotation matrix
R = zeros(3,3);

%Set the particular elements of the matrix
R(1,1) = cost1 * w(1) * w(1) + cost;
R(1,2) = cost1 * w(1) * w(2) - sint * w(3);
R(1,3) = cost1 * w(1) * w(3) + sint * w(2);

R(2,1) = cost1 * w(1) * w(2) + sint * w(3);
R(2,2) = cost1 * w(2) * w(2) + cost;
R(2,3) = cost1 * w(2) * w(3) - sint * w(1);

R(3,1) = cost1 * w(1) * w(3) - sint * w(2);
R(3,2) = cost1 * w(2) * w(3) + sint * w(1);
R(3,3) = cost1 * w(3) * w(3) + cost;