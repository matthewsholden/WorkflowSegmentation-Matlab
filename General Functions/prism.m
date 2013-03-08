%Calculate the point at which a line pierces a rectangular prism

%Parameter R1: One corner of the rectangular prism
%Parameter R2: Point emerging from the corner
%Parameter R3: Point emerging from the corner
%Parameter R4: Point emerging from the corner
%Parameter P: The tip of the needle
%Parameter V: The vector defining the direction of the needle

%Return inPrism: A boolean value indicating whether the point P lies within
%the prism
%Return X: The point at which the needle intersects the box
function [inPrism X] = prism(R1,R2,R3,R4,P,V)

%Preallocate all variables for speed
v = zeros(3,3);
A = zeros(1,6); B = zeros(1,6); C = zeros(1,6); D = zeros(1,6);
t = zeros(1,6);

%First, calculate the six planes specifying the prism. Let n be the normal
%vector (we only need three, since opposite planes are parallel)
v(1,:) = cross(R1-R2,R1-R3);
v(2,:) = cross(R1-R2,R1-R4);
v(3,:) = cross(R1-R3,R1-R4);

%Now, normalize these
n = normr(v);

%Calculate the parameters individually for the planes
A(1) = n(1,1);  B(1) = n(1,2);  C(1) = n(1,3);
A(2) = n(2,1);  B(2) = n(2,2);  C(2) = n(2,3);
A(3) = n(3,1);  B(3) = n(3,2);  C(3) = n(3,3);
%These are parallel to above
A(4) = n(1,1);  B(4) = n(1,2);  C(4) = n(1,3);
A(5) = n(2,1);  B(5) = n(2,2);  C(5) = n(2,3);
A(6) = n(3,1);  B(6) = n(3,2);  C(6) = n(3,3);

%Now, calulate the d values for each plane
D(1) = A(1)*R1(1)+B(1)*R1(2)+C(1)*R1(3);
D(2) = A(2)*R1(1)+B(2)*R1(2)+C(2)*R1(3);
D(3) = A(3)*R1(1)+B(3)*R1(2)+C(3)*R1(3);
%Parallel to above, but we know a differnt point on the plane
D(4) = A(1)*R4(1)+B(1)*R4(2)+C(1)*R4(3);
D(5) = A(2)*R3(1)+B(2)*R3(2)+C(2)*R3(3);
D(6) = A(3)*R2(1)+B(3)*R2(2)+C(3)*R2(3);

%Now that we know everything about all planes, we must calculate the
%smallest value of t (that is positive) and greater than zero
for i=1:6
    t(i) = ( D(i) - A(i)*P(1) - B(i)*P(2) - C(i)*P(3) ) / ( A(i)*V(1) + B(i)*V(2) + C(i)*V(3) );
end

%For the tip of the needle being in the prism, this is equivalent to
%requiring t >= 0 for three planes and t<=0 for the corresponding parallel
%planes. There are other ways to do this...
if ( sign( t(1)*t(4) ) == -1 && sign( t(2)*t(5) ) == -1 && sign ( t(3) * t(6) ) == -1 )
    inPrism = true;
else
    inPrism = false;
end

%Find the smallest positive value of t
t = min(t(t>=0));

%Calculate the x,y,z point at which the skin is pierced
X = P + t * V;

