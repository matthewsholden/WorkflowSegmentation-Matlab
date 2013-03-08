%This function will convert an (x,y,z) point in space for the needle-tip
%along with a needle length and a rotation matrix into a two points, each
%representing the ends of the needle

%Parameter M: The needle transformation matrix
%Parameter needleVector: The vector indicating the base of the needle

%Return needleTip: The point of the needle tip in xyz-space
%Return needleBase: The point of the needle end in xyz-space
function [needleTip needleBase] = matrixToPoints(M,needleVector)

%The needle tip is simply the position specified in the matrix
needleTip = M * [0 0 0 1]';
%Multiply the needle orientation with matrix to get base point
needleBase = M * cat( 1, needleVector, 1 );
%Positive is in direction needle points (base in -ve direction)

%Get the xyz components of the needle vector
needleTip = needleTip(1:3);
needleBase = needleBase(1:3);
