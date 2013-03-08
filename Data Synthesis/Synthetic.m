%This function will generate a trajectory of data synthetically
%We will not allow noise generation yet, just compute the trajectory based
%on a series of points

%Parameter Key: A key generator object specifying the key points for the
%procedure

%Return D: an object containing the data for our trial
function D = Synthetic(Key)

%So, presumably we would have:
%Translational: x,y,z
%Rotational: q1,q2,q3,q4

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%Read the task record from our example record file
Q = o.read('Q');
Play = o.read('Play');

%Read the noise matrices here from file
X_Bs = o.read('X_Bs');
X_Wt = o.read('X_Wt');
X_Mx = o.read('X_Mx');
%Read the human noise parameters from file
Human = o.read('Human');

%Clear the organizer now that we are done with it
clear o;

%The number of degrees of freedom is determined by the size of K.X
dof = size(Key.X,2);

%Calculate the number of time steps that will be required for the desired
%output accuracy
n = round( ( Key.T(Key.count) - Key.T(1) ) / Play(1) );

%Initialize the size of the time vector and the DOF matrix
T=zeros(n,1);
X=zeros(n,dof);
K=zeros(n,1);

%Let T be related to the time step by a scaling dt
for j=1:n
    T(j) = (j-1) * Play(1);
end

%We want to calculate a spline for the trajectory given by each degree of
%freedom...
%a) Calculate a regular cubic spline (natural spline)
%b) Calculate a velocity cubic spline (as described in Murphy)
%c) Calculate a linear spline (connect the dots with lines)

%This for loop implements all three different types of splines
%Iterate over all degrees of freedom of the motion
for i=1:n
    %Iterate over all n time steps
    for j=1:dof
        %Now, calculate the point using a spline (pick one)
        %X(i,j) = spline(Key.T,Key.X(:,j),T(i));
        %X(i,j) = velocitySpline(Key.T,Key.X(:,j),T(i));
        X(i,j) = linearSpline(Key.T,Key.X(:,j),T(i));
        %And calculate the task at the current time step, adding one since the
        %data point indicates the end of the previous task
        K(i) = Key.K( getInterval3(Key.T,T(i)) + 1 );
    end
    
end

%Now that we have a spline for the motion, calculate a mean and standard
%deviation in each degree of freedom of the motion of the needle. We can
%use this to determine the amplitude of noise added to the motion in the
%task

%Create a new data object
D = Data(T,X,K,0);

%Add noise to our data
D = D.addHumanNoise(X_Bs,X_Wt,X_Mx,Human);

%Normalize the quaternions as required
D = D.normalizeQuaternion(Q);


