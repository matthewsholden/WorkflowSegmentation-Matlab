%This function will mirror data

%Parameter T: The mirrored times
%Parameter X: The matrix to mirror
%Parameter A: The matrix to add in the middle of mirrored halves
%Parameter skip: Whether or not to skip the middle matrix

%Return T: The times of the mirrored matrix
%Return X: The mirrored matrix
function [TM XM] = matrixMirror(T,X,A,skip)

%The number of time steps and dimension
[n dof] = size(X);
[na dof] = size(A);

%The new nm for our mirrored matrix
nm = n + na;

%The mirrored time keeps counting (assuming average spacing)
avgTimeStep = (T(end)-T(1))/(n-1);

if (skip == false)
    T_Flip = ( T(end) + avgTimeStep*(1:nm) )';
    X_Flip = cat(1,A,flipud(X));
else
    T_Flip = ( T(end) + avgTimeStep*((1:n)+na) )';
    X_Flip = flipud(X);
end%if

%Now, concatenate T
TM = cat(1,T,T_Flip);

%And concatenate X
XM = cat(1,X,X_Flip);
