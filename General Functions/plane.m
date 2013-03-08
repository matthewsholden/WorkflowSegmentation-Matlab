%This function will plot a plane given its normal vector and the initial
%condition D. Note that we cannot assume that all of A,B,C are non zero.

%Parameter N: The surface normal vector
%Parameter D: The initial condition
%Parameter range: The maximum range in each of the x,y,z directions
function status = plane(N,D,range,clr,varargin)

%Indicate that the procedure is not done yet
status = 0;

%First, determine which component of the normal is the largest component
mix = maxIndex(N);

%Now, let's breakdown our vector into more sensible symbols
A=N(1); B=N(2); C=N(3);
xmin=range(1);  xmax=range(2);
ymin=range(1);  ymax=range(2);
zmin=range(1);  zmax=range(2);

%If mix is 1 then
if (mix==1)
    y = [ymin ymin; ymax ymax];
    z = [zmin zmax; zmin zmax];
    
    for i=1:2
        for j=1:2
            x(i,j) = ( D - B*y(i,j) - C*z(i,j) )/A;
        end
    end
    
end

%If mix is 2 then
if (mix==2)
    x = [xmin xmin; xmax xmax];
    z = [zmin zmax; zmin zmax];
    
    for i=1:2
        for j=1:2
            y(i,j) = ( D - A*x(i,j) - C*z(i,j) )/B;
        end
    end
    
end

%If mix is 3 then
if (mix==3)
    x = [xmin xmin; xmax xmax];
    y = [ymin ymax; ymin ymax];
    
    for i=1:2
        for j=1:2
            z(i,j) = ( D - A*x(i,j) - B*y(i,j) )/C;
        end
    end
    
end



%Now, use the surf to plot
if (nargin > 3)
    %Set the colormap
    colormap(clr);
    %Plot the surface
    status = surf(x,y,z,[1 1; 1 1],varargin{:});
else
    status = surf(x,y,z);
end