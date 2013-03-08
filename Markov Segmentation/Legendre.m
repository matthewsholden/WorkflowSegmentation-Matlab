%This function will, given a vector of points and a vector of times,
%perform a Legendre trasnform on the data up to specified order

%Parameter T: A vector of time stamps
%Parameter X: A vector of values at the given time steps
%Parameter order: The order of Legendre transform we wish to perform

%Return a: A vector of Legendre coefficients in order
function a = Legendre(T,X,order)

%Recall the Legendre Polynomials:
%P0(x) = 1
%P1(x) = x
%P2(x) = 3/2*x^2 - 1/2
%P3(x) = 5/2*x^3 - 3/2*x
%P4(x) = 35/8*x^4 - 15/4*x^2 + 3/8
%P5(x) = 63/8*x^5 - 35/4*x^3 + 15/8*x
%P6(x) = 231/16*x^6 - 315/16*x^4 + 105/16*x^2 - 5/16


%Calculate the degrees of freedom of the input data
[~, dof] = size(X);
%Initialize the vector of Legendre seris coefficients
a = zeros( order + 1, dof);


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

if (order >= 0)
   %Evaluate the Legendre polynomial at the correct points
   P0 = 1;
   %Now integrate
   a(1,:) = vectorIntegrate(T,bsxfun(@times,X,P0));
end%if

if (order >= 1)
   %Evaluate the Legendre polynomial at the correct points
   P1 = T;
   %Now integrate
   a(2,:) = vectorIntegrate(T,bsxfun(@times,X,P1));
end%if

if (order >= 2)
   %Evaluate the Legendre polynomial at the correct points
   P2 = 3/2*T.^2 - 1/2;
   %Now integrate
   a(3,:) = vectorIntegrate(T,bsxfun(@times,X,P2));
end%if

if (order >= 3)
   %Evaluate the Legendre polynomial at the correct points
   P3 = 5/2*T.^3 - 3/2*T;
   %Now integrate
   a(4,:) = vectorIntegrate(T,bsxfun(@times,X,P3));
end%if

if (order >= 4)
   %Evaluate the Legendre polynomial at the correct points
   P4 = 35/8*T.^4 - 15/4*T.^2 + 3/8;
   %Now integrate
   a(5,:) = vectorIntegrate(T,bsxfun(@times,X,P4));
end%if

if (order >= 5)
   %Evaluate the Legendre polynomial at the correct points
   P5 = 63/8*T.^5 - 35/4*T.^3 + 15/8*T;
   %Now integrate
   a(6,:) = vectorIntegrate(T,bsxfun(@times,X,P5));
end%if

if (order >= 6)
   %Evaluate the Legendre polynomial at the correct points
   P6 = 231/16*T.^6 - 315/16*T.^4 + 105/16*T.^2 - 5/16;
   %Now integrate
   a(7,:) = vectorIntegrate(T,bsxfun(@times,X,P6));
end%if