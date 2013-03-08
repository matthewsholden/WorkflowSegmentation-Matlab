%This function will add human-like noise using a leader-following type model
%to represent the corrective motions of the human, but random noise will be
%added to the motion

%The model is as follows: du(t + RT)/dt = -alpha * au^m * (au-iu) * (ix -
%ax)^l + beta*(iu - au)

%Parameter D: A data object representing the noise-free motion
%Parameter X_Bs: The baseline noise associated with the motion
%Parameter X_Wt: The weighted noise associated with the motion
%Parameter X_Mx: The mixing proportion associated with each mixture of the
%mixed Gaussian distribution
%Parameter Human: The parameters associated with the human noise

%Return DN: A data object with human noise added
function DN = humanNoise(D,sd,X_Bs,X_Wt,X_Mx,Human)

%Let's rename the human parameters to have meaningful names
reaction = Human(1);
maxAccel = Human(2);
speedSense = Human(3);
distSense = Human(4);



%Calculate the number of time steps and degrees of freedom
[n dof] = size(D.X);

%Initialize all of our variables
t = zeros(n,1);     dudt=zeros(n,dof);    dudtn=zeros(n,dof);
ix = zeros(n,dof);    iu = zeros(n,dof);
ax = zeros(n,dof);    au = zeros(n,dof);

%The initial time
t(1) = D.T(1);
%We need an initial position and velocity of motion. Assume this is the same
%as the intended initial position and velocity.
ix(1,:) = D.X(1,:);
ax(1,:) = D.X(1,:);
iu(1,:) = ( D.X(2,:) - D.X(1,:) ) / ( D.T(2) - D.T(1) );
au(1,:) = ( D.X(2,:) - D.X(1,:) ) / ( D.T(2) - D.T(1) );

%Now, iterate over all time
for j=2:n
    %Calculate the current time
    t(j) = D.T(j);
    %Calculate the intended position of the needle
    ix(j,:) = D.X(j,:);
    %Calculate the intended velocity of the needle
    iu(j,:) = ( ix(j,:) - ix(j-1,:) ) / ( t(j) - t(j-1) );
    
    %Calculate the time at which reaction will kick in
    rj = find(D.T>=( t(j) + reaction ),1,'first');
    if (~isempty(rj))
        %Now, determine what the acceleration should be in reaction time number
        %of seconds
        dudt(rj,:) = -speedSense * ( au(j-1,:) - iu(j-1,:) );
        dudt(rj,:) = dudt(rj,:) + distSense * ( ix(j-1,:) - ax(j-1,:) );
        %Add some noise to the acceleration, iterating over all degrees of
        %freedom
        for i=1:dof
            %We need an array of zero means for our Gaussian mixture object 
            mu=zeros(size(X_Bs,3),1);
            %The standard deviation sigma is given by the noise parameters
            sigma=X_Bs(i,D.K(j),:)+X_Wt(i,D.K(j),:)*sd(i,D.K(j));
            %The mixture components for each gaussian distribution
            weight=zeros(size(X_Bs,3),1);
            weight(:)=X_Mx(i,D.K(j),:);
            
            %Now, we create a gmdistribution object which will yield the appropriate
            %mixture of Gaussian distributions
            gmd=gmdistribution(mu,sigma,weight);
            
            %Add noise to the acceleration
            dudtn(j,i) = dudt(j,i) + random(gmd);
        end
        
        %Now, the acceleration may not exceed the threshold acclerations
        for i=1:dof
            dudt(rj,i) = min(dudt(rj,i),maxAccel);
            dudt(rj,i) = max(dudt(rj,i),-maxAccel);
        end
    end
    
    
    %Good one, we have dudt for the future, but calculate the velocity now,
    %given we now know the change velocity
    au(j,:) = au(j-1,:) + ( dudt(j,:) + dudtn(j,:) ) / 2 * ( t(j) - t(j-1) );
    
    %Finally, calculate the curren position
    ax(j,:) = ax(j-1,:) + au(j,:) * ( t(j) - t(j-1) );
    
end

%Now, write the data object
DN = Data(t,ax,D.K,D.S);