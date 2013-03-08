%This function will calculate the area of a triangle using Hero's formula

%Parameter p1: One point of the triangle
%Parameter p2: One point of the triangle
%Parameter p3: One point of the triangle

%Return area: The area of the triangle
function area = areaTriangle(p1, p2, p3)

%Determine the side lengths
a = norm( p1 - p2 );
b = norm( p2 - p3 );
c = norm( p1 - p3 );

%Determine the semiperiemeter
s = ( a + b + c ) / 2;

%Calulate the area using Hero's formula
area = sqrt( s * ( s - a ) * ( s - b ) * ( s - c ) );