%Given the Legendre coefficients, this function will calculate the original
%functions which produced the Legendre coefficients

%Parameter T: A vector of time stamps
%Parameter A: A vector of Legendre coefficients

%Return X: The function whic produced the Legendre coefficients
function X = deLegendre(T,A)

%Recall the Legendre Polynomials:
%P0(x) = 1
%P1(x) = x
%P2(x) = 3/2*x^2 - 1/2
%P3(x) = 5/2*x^3 - 3/2*x
%P4(x) = 35/8*x^4 - 15/4*x^2 + 3/8
%P5(x) = 63/8*x^5 - 35/4*x^3 + 15/8*x
%P6(x) = 231/16*x^6 - 315/16*x^4 + 105/16*x^2 - 5/16


%Calculate the degrees of freedom of the input data
[order, dof] = size(A);
order = order - 1;
%Initialize the vector of Legendre seris coefficients
X = zeros( size(T,1), dof);


%Normalize time so that it spans the interval (-1,1)
rn = range(T);
%If the range of times is zero, then all coefficients must be zero
if (rn == 0)
   return; 
end%if


%Shift the data such that it starts at the origin
T = T - T(1);
%Decrease the range in data to be from (0,2)
T = 2 * T / rn;
%Shift the range such that it spans (-1,1)
T = T - 1;


%Determine the Legendre coefficient of each order
P = [];

if (order >= 0)
   %Evaluate the Legendre polynomial at the correct points
   P0 = 1 + 0.*T;
   P = cat(2,P,P0);
end%if

if (order >= 1)
   %Evaluate the Legendre polynomial at the correct points
   P1 = T;
   P = cat(2,P,P1);
end%if

if (order >= 2)
   %Evaluate the Legendre polynomial at the correct points
   P2 = 3/2*T.^2 - 1/2;
   P = cat(2,P,P2);
end%if

if (order >= 3)
   %Evaluate the Legendre polynomial at the correct points
   P3 = 5/2*T.^3 - 3/2*T;
   P = cat(2,P,P3);
end%if

if (order >= 4)
   %Evaluate the Legendre polynomial at the correct points
   P4 = 35/8*T.^4 - 15/4*T.^2 + 3/8;
   P = cat(2,P,P4);
end%if

if (order >= 5)
   %Evaluate the Legendre polynomial at the correct points
   P5 = 63/8*T.^5 - 35/4*T.^3 + 15/8*T;
   P = cat(2,P,P5);
end%if

if (order >= 6)
   %Evaluate the Legendre polynomial at the correct points
   P6 = 231/16*T.^6 - 315/16*T.^4 + 105/16*T.^2 - 5/16;
   P = cat(2,P,P6);
end%if


%Normalize A
A = bsxfun(@times, A, (2*(0:order)' + 1) / 2 );

%Multiply A by P to get the original function back
X = P * A;