%This function will be used to add noise to a given point in the trajectory
%of the needle. For now, we can try a normal distribution with mean zero
%(so that the motion is not completely different) and varying length of
%time of each task

%Parameter task: Task number
%Parameter std: Standard deviation in motion in degree of freedom for
%particular task

%Return: Noise which should be added to the point
function t = addTimeNoise(task, sd)

%So, given the standard deviation matrix, the required peturbation is found
%from a Guassian Mixture distribution with the appropriate standard deviation
%from the matrices

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%read the matrices here from file
T_Bs = o.read('T_Bs');
T_Wt = o.read('T_Wt');
T_Mx = o.read('T_Mx');

%The number of distributions we are adding to the mixture is k
[one kinv k]=size(T_Bs);

%Create a Gaussian mixture object with gaussians each of dimension 1
%We require k = number of components, d = 1
mu=zeros(k,1);
%The standard deviation sigma is given by the matrices SX, WX
sigma=T_Bs(one,task,:)+T_Wt(one,task,:)*sd;
%The mixture components for each gaussian distribution
%We must turn this into a row vector
weight=zeros(k,1);
for i=1:k
    weight(i,1)=T_Mx(one,task,i);
end

%Now, we create a gmdistribution object which will yield the appropriate
%mixture of Gaussian distributions
gmd=gmdistribution(mu,sigma,weight);

%Now, pick a random value given the mixed Gaussian distribution
t = random(gmd);