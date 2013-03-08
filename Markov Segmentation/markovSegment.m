%This function will read data from procdure and feed it into the MarkovData
%object. This will give a task segmentation of the procedure

%Parameter D_Test: The test procedure we wish to automatically segment

%Return M: The MarkovData object with task segmentation of procedure
function M = markovSegment(D_Test)


%Create a new MarkovData object
M = MarkovData();


%Now, go through all time steps and determine the task being executed
for j = 1:D_Test.count
   
   %Add the data point to the MarkovData Model
   M = M.addPoint( D_Test.T(j) , D_Test.X(j,:));  
   
end
