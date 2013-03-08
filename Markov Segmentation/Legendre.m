%This function will, given a vector of points and a vector of times,
%perform a Legendre trasnform on the data up to a specified order

%Recall the Legendre Polynomials:
%P0(x) = 1
%P1(x) = x
%P2(x) = 3/2*x^2 - 1/2
%P3(x) = 5/2*x^3 - 3/2*x
%P4(x) = 35/8*x^4 - 15/4*x^2 + 3/8
%P5(x) = 63/8*x^5 - 35/4*x^3 + 15/8*x
%P6(x) = 231/16*x^6 - 315/16*x^4 + 105/16*x^2 - 5/16

%Parameter T: A vector of time stamps
%Parameter X: A vector of values at the given time steps
%Parameter order: The order of Legendre transform we wish to perform

%Return a: A vector of Legendre coefficients in order
function a = Legendre(T,X,order)

%First, create inline functions for each of the Legendre polynomials up to
%order 6 (hopefully this will be enough)
% P0 = inline('1','x');
% P1 = inline('x','x');
% P2 = inline('3/2*x.^2 - 1/2','x');
% P3 = inline('5/2*x.^3 - 3/2*x','x');
% P4 = inline('35/8*x.^4 - 15/4*x.^2 + 3/8','x');
% P5 = inline('63/8*x.^5 - 35/4*x.^3 + 15/8*x','x');
% P6 = inline('231/16*x.^6 - 315/16*x.^4 + 105/16*x.^2 - 5/16','x');

%So now that we have our legendre polynomials, we must evaluate them at all
%of the same normalization
%So the vector we return will be of length (order+1)
a = zeros(1,order+1);

%First, we must normalize our function such that it spans the interval
%(-1,1)
%Find the range in time of the data
range = T(end) - T(1);
%Note that if the range in the data is zero then we have no area when we
%integrate, so just return zero since we know that this will be the result
if (range == 0)
   return; 
end

%Shift the data such that it starts at the origin
T = T - T(1);
%Decrease the range in data to be from (0,2)
T = 2*T/range;
%Shift the range such that it spans (-1,1)
T = T - 1;




%Now go through each Legendre polynomial and determine the coefficient upto
%the orderth order polynomial

if (order >= 0)
   %Evaluate the Legendre polynomial at the correct points
   P0 = 1;
   %Now integrate
   a(1) = vectorIntegrate(T,X.*P0);
end

if (order >= 1)
   %Evaluate the Legendre polynomial at the correct points
   P1 = T;
   %Now integrate
   a(2) = vectorIntegrate(T,X.*P1);
end

if (order >= 2)
   %Evaluate the Legendre polynomial at the correct points
   P2 = 3/2*T.^2 - 1/2;
   %Now integrate
   a(3) = vectorIntegrate(T,X.*P2);
end

if (order >= 3)
   %Evaluate the Legendre polynomial at the correct points
   P3 = 5/2*T.^3 - 3/2*T;
   %Now integrate
   a(4) = vectorIntegrate(T,X.*P3);
end

if (order >= 4)
       %Evaluate the Legendre polynomial at the correct points
   P4 = 35/8*T.^4 - 15/4*T.^2 + 3/8;
   %Now integrate
   a(5) = vectorIntegrate(T,X.*P4);
end

if (order >= 5)
   %Evaluate the Legendre polynomial at the correct points
   P5 = 63/8*T.^5 - 35/4*T.^3 + 15/8*T;
   %Now integrate
   a(6) = vectorIntegrate(T,X.*P5);
end

if (order >= 6)
   %Evaluate the Legendre polynomial at the correct points
   P6 = 231/16*T.^6 - 315/16*T.^4 + 105/16*T.^2 - 5/16;
   %Now integrate
   a(7) = vectorIntegrate(T,X.*P6);
end