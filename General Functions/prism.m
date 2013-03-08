%Calculate the point at which the needle pierces a rectangular prism

%Parameter corner: A cell array of 4 corners of prism (1 is centre corner)
%Parameter M: The transform representing the needle position

%Return inPrism: Boolean value indicating whether needle tip is in prism
%Return X: The point at which the needle intersects the box
function [inPrism X] = prism(corner,M)

%Determine the needle orientation from file
o = Organizer();

%Calulate the needle-tip position
[needleTip needleBase] = matrixToPoints( M, o.read('NeedleOrientation') );

%Calculate vector indicating where needle base emerges from tip
needleOr = needleBase - needleTip;

%Preallocate the equation of plane coefficients for each plane
A = zeros(6,3);
D = zeros(6,1);

%Calculate normals for six planes specifying prism (opposites parallel)
v = zeros(3,3);
v(1,:) = cross( corner{1} - corner{2}, corner{1} - corner{3} );
v(2,:) = cross( corner{1} - corner{2}, corner{1} - corner{4} );
v(3,:) = cross( corner{1} - corner{3}, corner{1} - corner{4} );
v = normr(v);

%Calculate the plane coefficients individually each plane
A(1,:) = v(1,:);    A(4,:) = v(1,:);
A(2,:) = v(2,:);    A(5,:) = v(2,:);
A(3,:) = v(3,:);    A(6,:) = v(3,:);

%Calculate the constant coefficient D for each plane
D(1) = dot( A(1,:), corner{1} );    D(4) = dot( A(4,:), corner{4} );
D(2) = dot( A(2,:), corner{1} );    D(5) = dot( A(5,:), corner{3} );
D(3) = dot( A(3,:), corner{1} );    D(6) = dot( A(6,:), corner{2} );

%Calculate the number of needle-base vectors to reach plane from needletip
t = zeros(6,1);
for i=1:6
    %The minimum distance from point -> plane
    minDis = D(i) - dot( A(i,:), needleTip );
    %The component of the needle base in the normal direction
    baseComp = dot( A(i,:), needleOr );
    %The number of needle base vectors required to reach the plane
    t(i) = minDis / baseComp;
end%for

%Require positive and negative direction to parallel planes to be in prism
if ( sign( t(1)*t(4) ) == -1 && sign( t(2)*t(5) ) == -1 && sign ( t(3)*t(6) ) == -1 )
    inPrism = true;
else
    inPrism = false;
end%if

%The needle pierces the skin at the smallest positive t value
t = min(t(t>=0));

X = needleTip;
%If the needle does not extend into the gel, then just return the needletip
if ( ~isempty(t) )
    X = X + t * needleOr;
end%if

