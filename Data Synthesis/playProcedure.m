%This function will play an animation type visualization of the procedure
%record using a the data read from file


%Parameter num: The procedure number that we want to play
%Parameter speed: The fraction of realtime speed at which we want to play
%the procedure
%Parameter eye: The location of the eye from which we want to view the
%procedure playback. If we get two parameters, it sets the azimuth and
%elevation angles, if we get three parameters, it sets the xyz position.


%Return status: Whether or not the playback was successful
function status = playProcedure(num,speed,eye)

%We are not completed playing
status=0;

%If the eye is unspecified, assume 45,45
if (nargin < 3)
    eye = [45 45];
end

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%The first thing we shall do is get the procedure record from the file
D = readRecord();
%Now, only consider the specified procedure number
D = D{num};

%Read all of the other relevant parameters from file
Q = o.read('Q');
ET = o.read('ET');
Play = o.read('Play');

%Create a point that will be used for visualizing the target
Entry = ET(1,:);
Target = ET(2,:);

%First, determine the size of our time vector (how many points in time we
%have overall)
[n dof] = size(D.X);

%Now, let's calculate the range of the plot, leaving some extra room on the
%axes just in case
xmin = min(D.X(:,1))-Play(2);  xmax = max(D.X(:,1))+Play(2);
ymin = min(D.X(:,2))-Play(2);  ymax = max(D.X(:,2))+Play(2);
zmin = min(D.X(:,3))-Play(2);  zmax = max(D.X(:,3))+Play(2);

%Now, iterate through each element in our time vector and display the
%position of the needle to screen
for j=1:n
    
    %First, calculate the rotation matrix associated with the quaternion at
    %the given point in time (but first assmble the quaternion q)
    q = D.X(j,Q==1);
    R = quatToMatrix(q);
    
    %Now that we have the rotation matrix, calculate the two points
    %defining the end of the needle (given the needle length)
    [x1 x2] = matrixToPoints([D.X(j,1) D.X(j,2) D.X(j,3)]',R,Play(2));
    
    
    %Given the points as vectors, we must convert to a series where each
    %coordinate is a vector in the following way:
    x(1)=x1(1);     x(2)=x2(1);
    y(1)=x1(2);     y(2)=x2(2);
    z(1)=x1(3);     z(2)=x2(3);
    
    
    
    clf
    hold on
    %Plot a plane representing the surface of the skin
    %plane(Entry,norm(Entry)^2,[xmin xmax ymin ymax zmin zmax],[1 1 0]);
    %Finally, plot the points in 3d space
    plot3(x,y,z,'LineWidth',2);
    %Plot a point at the location of the tip of the needle
    plot3(x(1),y(1),z(1),'.');
    %Also, plot points for the insertion point and the target
    plot3(Entry(1),Entry(2),Entry(3),'.g');
    plot3(Target(1),Target(2),Target(3),'.r');
    
    %First, set the axis of the plot such that the scale is not changing each
    %time we plot a point
    axis([xmin xmax ymin ymax zmin zmax]);
    
    %Label the axes
    xlabel('x');
    ylabel('y');
    zlabel('z');
    
    %Set the view to as specified
    view(eye)
    
    %If we have already plotted the last point, then there is no time delay
    %afterwards (mainly because T(j+1) does not exist
    if (j~=n)
        pause((D.T(j+1)-D.T(j))/speed);
    end
    
end

%Indicate that we have completed playing
status=1;
