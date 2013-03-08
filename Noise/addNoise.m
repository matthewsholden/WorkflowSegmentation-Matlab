%This function will be used to add noise to a given point in the trajectory
%of the needle. For now, we can try a normal distribution with mean zero
%(so that the motion is not completely different) and varying standard
%deviation in each degree of freedom for each task/motion

%Parameter di: Degree of freedom noise will be added to
%Parameter task: Task number, Matrix of Standard Deviations
%Parameter std: Standard deviation in motion in degree of freedom for
%particular task
%Parameter S: Baseline amplitude in noise
%Parameter W: Weighting of standard deviation of motion for task in noise

%Return x: Perturbation to be added to our point
function x = addNoise(di, task, sd, X_Bs, X_Wt, X_Mx)

%So, given the standard deviation matrix, the required peturbation is found
%from a Guassian Mixture distribution with the appropriate standard deviation
%from the matrices

%The number of distributions we are adding to the mixture is k
[dof kinv k]=size(X_Bs);

%Create a Gaussian mixture object with gaussians each of dimension 1
%We require k = number of components, d = 1
mu=zeros(k,1);
%The standard deviation sigma is given by the matrices SX, WX
sigma=X_Bs(di,task,:)+X_Wt(di,task,:)*sd(di,task);
%The mixture components for each gaussian distribution
%We must turn this into a row vector
weight=zeros(k,1);
for i=1:k
    weight(i,1)=X_Mx(di,task,i);
end

%Now, we create a gmdistribution object which will yield the appropriate
%mixture of Gaussian distributions
gmd=gmdistribution(mu,sigma,weight);

%Now, pick a random value given the mixed Gaussian distribution
x = random(gmd);