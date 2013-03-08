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
%P7(x) = 429/16*x^7 - 693/16*x^5 + 315/16*x^3 - 35/16*x
%P8(x) = 6435/128*x^8 - 12012/128*x^6 + 6930/128*x^4 - 1260/128*x^2 +
%35/128
%P9(x) = 12155/128*x^9 - 25740/128*x^7 + 18018/128*x^5 - 4620/128*x^3 +
%315/128*x
%P10(x) = 46189/256*x^10 - 109395/256*x^8 + 90090/256*x^6 - 30030/256*x^4 +
%3465/256*x^2 - 63/256


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
   P0 = P0 / sqrt( 2 / ( 2*0 + 1 ) );
   P = cat(2,P,P0);
end%if

if (order >= 1)
   %Evaluate the Legendre polynomial at the correct points
   P1 = T;
   P1 = P1 / sqrt( 2 / ( 2*1 + 1 ) );
   P = cat(2,P,P1);
end%if

if (order >= 2)
   %Evaluate the Legendre polynomial at the correct points
   P2 = 3/2*T.^2 - 1/2;
   P2 = P2 / sqrt( 2 / ( 2*2 + 1 ) );
   P = cat(2,P,P2);
end%if

if (order >= 3)
   %Evaluate the Legendre polynomial at the correct points
   P3 = 5/2*T.^3 - 3/2*T;
   P3 = P3 / sqrt( 2 / ( 2*3 + 1 ) );
   P = cat(2,P,P3);
end%if

if (order >= 4)
   %Evaluate the Legendre polynomial at the correct points
   P4 = 35/8*T.^4 - 15/4*T.^2 + 3/8;
   P4 = P4 / sqrt( 2 / ( 2*4 + 1 ) );
   P = cat(2,P,P4);
end%if

if (order >= 5)
   %Evaluate the Legendre polynomial at the correct points
   P5 = 63/8*T.^5 - 35/4*T.^3 + 15/8*T;
   P5 = P5 / sqrt( 2 / ( 2*5 + 1 ) );
   P = cat(2,P,P5);
end%if

if (order >= 6)
   %Evaluate the Legendre polynomial at the correct points
   P6 = 231/16*T.^6 - 315/16*T.^4 + 105/16*T.^2 - 5/16;
   P6 = P6 / sqrt( 2 / ( 2*6 + 1 ) );
   P = cat(2,P,P6);
end%if

if (order >= 7)
   %Evaluate the Legendre polynomial at the correct points
   P7 = 429/16*T.^7 - 693/16*T.^5 + 315/16*T.^3 - 35/16*T;
   P7 = P7 / sqrt( 2 / ( 2*7 + 1 ) );
   P = cat(2,P,P7);
end%if

if (order >= 8)
   %Evaluate the Legendre polynomial at the correct points
   P8 = 6435/128*T.^8 - 12012/128*T.^6 + 6930/128*T.^4 - 1260/128*T.^2 + 35/128;
   P8 = P8 / sqrt( 2 / ( 2*8 + 1 ) );
   P = cat(2,P,P8);
end%if

if (order >= 9)
   %Evaluate the Legendre polynomial at the correct points
   P9 = 12155/128*T.^9 - 25740/128*T.^7 + 18018/128*T.^5 - 4620/128*T.^3 + 315/128*T;
   P9 = P9 / sqrt( 2 / ( 2*9 + 1 ) );
   P = cat(2,P,P9);
end%if

if (order >= 10)
   %Evaluate the Legendre polynomial at the correct points
   P10 = 46189/256*T.^10 - 109395/256*T.^8 + 90090/256*T.^6 - 30030/256*T.^4 + 3465/256*T.^2 - 63/256;
   P10 = P10 / sqrt( 2 / ( 2*10 + 1 ) );
   P = cat(2,P,P10);
end%if

%Already normalized
%Multiply A by P to get the original function back
X = P * A;