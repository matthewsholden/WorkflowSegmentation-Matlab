%This function will add human-like noise to a trajectory in any number of
%degrees of freedom, as determined by the model for human motion given by
%Tu in 2007

%Parameter D: A Data object containing the intended trajectory of motion
%Parameter vr: The variance for each normal distribution
%Parameter phi: The parameters associated with the input sequence to the
%curvature function, where 0 < phi < pi

%Return DN: The Data object of trajectory with noise due to human error
function DN = humanNoise(D,vr,phi)

%Determine the number of degrees of freedom and time steps for the
%trajectory
[n dof] = size(D.X);

%From the variance, calculate the standard deviation desired for each
%normal distribution
sd = sqrt(vr);
%sd(1) = L, sd(2) = nu, sd(3) = v, sd(4) = Y;

%We have several initial conditions

%The initial velocity of the trajectory
v(1,:) = ( D.X(2,:) - D.X(1,:) ) / ( D.T(2) - D.T(1) );
%And from the initial velocity, the initial speed
s(1) = norm( v(1,:) );
%The initial (normalized) direction of the trajectory
nx(1,:) = ( D.X(2,:) - D.X(1,:) );
nx(1,:) = nx(1,:) / norm( nx(1,:) );
%The initial curvature
w(1) = random('norm',0, sd(2) / sqrt( s(1) ) );
%The initial position
x(1,:) = D.X(1,:);

%We also need to calculate the parameters for the curvature function
pL = ( 1 - sin (phi(1)) ) / cos(phi(1));
pH = ( 1 - sin (phi(2)) ) / cos(phi(2));

%Let's create an inline function to calculate delta
H = inline('(1-pL)*(1-pH)*(1-z^-2) / (4*(1-pL*z^-1)*(1-pH*z^-1))','z','pL','pH');
Hw = inline('(1-pL)*(1+pH)*(1+z^-1) / 4*v0*(1-pL*z^-1)*(1-pH*z^-1)','z','pL','pH','v0');

%Iterate over all succeeding steps in time
for j=2:n
    %First, determine the current velocity from the previous velocity,
    %iterating over all degrees of freedom
    v(j,:) = ( D.X(j,:) - D.X(j-1,:) ) / ( D.T(j) - D.T(j-1) );
    for i=1:dof
        %v(j,i) = exp( random('norm', log( v(j-1,i) ), sd(3) ) );
    end
    %And calulate the associated speed
    %s(j) = exp( random('norm', log( s(j-1) ), sd(3) ) );
    s(j) = norm ( v(j,:) );
    
    %For calculating the curvature, find a z from a normal distribution
    z = random('norm',0,sd(2));
    %Now calculate the value delta
    %delta = H(z,pL,pH);
    %delta
    %Finally, calculate the curvature
    %w(j) = w(j-1) + delta / s(j);
    w(j) = Hw(z,pL,pH,s(j));
    
    %Now we can calculate the directional vector associated with the motion
    nx(j,:) = nx(j-1,:) + s(j) * w(j);
    nx(j,:) = nx(j,:) / norm( nx(j,:) );
    
    w
    
    %Finally, calculate the new position from the old position, using this
    %directional vector
    %Iterate over all degrees of freedom
    for i=1:dof
       x(j,i) = random('norm',x(j-1,i) + s(j) * nx(j,i), s(j)*sd(1)); 
    end
    
    
end

DN = Data(D.T,x,D.K,D.S);