%This function will read data from procdure and feed it into the MarkovData
%object. This will give a task segmentation of the procedure

%Parameter num: The procedure number which we wish to segment

%Return M: The MarkovData object with task segmentation of procedure
function M = markovSegment(num)

%Read the procedure from file
D = readRecord();

%Just consider the num-th procedure for now
T = D{num}.T;
X = D{num}.X;

%Create a new MarkovData object
M = MarkovDataLDA();

%Determine the number of time steps...
n = length(T);

%Now, go through all time steps and determine the task being executed
for j=1:n
   
   %Get the time step from file
   t = T(j);
   x = X(j,:)';
   
   %Add the data point to the MarkovData Model
   M = M.addPoint(t,x);
   
   %str = ['Time: ', num2str(t), ', Current: ', num2str(M.currTask), ', Next: ', num2str(M.nextTask)];
   %disp(str);
   
end

%Plot the needle trajectory
plot(M.D.X)
