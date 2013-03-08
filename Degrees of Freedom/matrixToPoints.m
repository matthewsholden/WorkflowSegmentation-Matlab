%This function will convert an (x,y,z) point in space for the needle-tip
%along with a needle length and a rotation matrix into a two points, each
%representing the ends of the needle

%Parameter xt: The point in xyz-space of the needle tip
%Parameter M: The needle transformation matrix
%Parameter needleLength: The length of the needle

%Return x1: The point of the needle tip in xyz-space
%Return x2: The point of the needle end in xyz-space
function [x1 x2] = matrixToPoints(M,needleLength)

%Suppose we have a coordinate system such all rotations are defined in
%relation to the reference vector ref (which is a unit vector in xyz-space)

%First, scale our reference vector such that the length of the resulting
%vector is equal to the needle length
x1 = M * [0 0 0 1]';
x2 = M * [0 0 -needleLength 1]';
%Positive is in direction needle points (base in -ve direction)

%Only get the first three points (xyz coordinates)
x1 = x1(1:3);
x2 = x2(1:3);
