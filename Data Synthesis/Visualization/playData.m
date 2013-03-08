%This function will automatically play a needle trajectory in plot

%Parameter D: The data object with the needle trajectory and tasks
%Parameter viewPoint: The angle from which the trajectory is viewed

%Return status: Whether or not the playback was completed successfully
function status = playData(D,speed,viewPoint)

%We are not completed playing
status=0;

%If view point is unspecified, then assume (0,0)
if (nargin < 2)
    speed = 1;
end%if
if (nargin < 3)
    viewPoint = [0 0];
end%if

%Use an organizer to read the parameters from file
o = Organizer();

%Read all of the other relevant parameters from file
ET = o.read('EntryTarget');
Play = o.read('Playback');
needleOr = o.read('NeedleOrientation');

%Create a point that will be used for visualizing the target
Entry = ET(1,:);
Target = ET(2,:);

%Determine how many time frames there are
[n dof] = size(D.X);

%Calculate the range of the plot; leave a needle's length on each side
xmin = min( D.X(:,1) ) - Play(2);  xmax = max( D.X(:,1) ) + Play(2);
ymin = min( D.X(:,2) ) - Play(2);  ymax = max( D.X(:,2) ) + Play(2);
zmin = min( D.X(:,3) ) - Play(2);  zmax = max( D.X(:,3) ) + Play(2);

%Create a vector of colours associated with each task
taskClr = ['k' 'r' 'g' 'b' 'y' 'm'];

%Set the initial time step of the procedure
j = 1;
exiter = false;

%Maximize the figure window
figure('Position',get(0,'ScreenSize'))

%Iterate over all time steps and draw the needle to screen
for j=1:n
    
    %Calculate the matrix produced by the current dofs
    M = dofToMatrix( D.X(j,:) );
    
    %Calculate the two points defining the needle ends
    [x1 x2] = matrixToPoints( M, Play(2) * needleOr );
        
    %Convert x1, x2 vectors to xyz vectors for plotting
    x(1)=x1(1);     x(2)=x2(1);
    y(1)=x1(2);     y(2)=x2(2);
    z(1)=x1(3);     z(2)=x2(3);

    %Plot the skin, needle, entry and target
    clf; hold on;
    %Plot a plane representing the surface of the skin
    plane( Entry - Target, 0 , [xmin xmax], [1 1 0] );
    %Plot points for the insertion point and the target
    plot3( Entry(1), Entry(2), Entry(3), 'og', 'MarkerSize', 25);
    plot3( Target(1), Target(2), Target(3), 'or', 'MarkerSize', 5);
    %Plot the needle in space with a ball at its tip
    plot3( x, y, z, 'LineWidth', 4, 'Color', taskClr(D.K(j,:) + 1) );
    plot3( x(1), y(1), z(1), '.k', 'MarkerSize', 25);
    
    %Set the axis of the plot (constant for all points)
    axis([xmin xmax ymin ymax zmin zmax]);
    xlabel('x'); ylabel('y'); zlabel('z');
    title( ['Time: ' num2str(D.T(j)) '/', num2str(D.T(n))] );
    view(viewPoint)
    
    %Wait for the next time step
    if (j~=n)
        pause((D.T(j+1)-D.T(j))/speed);
    end%if

end%for

%Close all the windows
close all;

%Indicate that we have completed playing
status=1;
