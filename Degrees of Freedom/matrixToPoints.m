%This function will convert an (x,y,z) point in space for the needle-tip
%along with a needle length and a rotation matrix into a two points, each
%representing the ends of the needle

%Parameter xt: The point in xyz-space of the needle tip
%Parameter R: A rotation matrix representing the rotation of the needle
%Parameter needleLength: The length of the needle

%Return x1: The point of the needle tip in xyz-space
%Return x2: The point of the needle end in xyz-space
function [x1 x2] = matrixToPoints(xt,R,needleLength)

%Suppose we have a coordinate system such all rotations are defined in
%relation to the reference vector ref (which is a unit vector in xyz-space)

%First, scale our reference vector such that the length of the resulting
%vector is equal to the needle length
x2 = needleLength * [0 0 -1]';

%Next, apply the rotation matrix to the reference vector to get a point in
%xyz-space rotated relative to the reference vector by applying the
%rotation matrix to our reference point
x2 = R * x2;

%Finally, translate the point such that its position is correct relative to
%the needle tip position
x1 = xt;
x2 = xt + x2;

