%This function will be responsible for reading a threshold distance
%iteration step from file and returning it to the calling function

%Parameter fileName: The name of th file in which the procedure keypoint
%record is stored

%Return minTD: A matrix containing the minimum threshold distance for each
%degree of freedom for each task
%Return stepTD: A matrix containing the step in threshold distance for each
%degree of freedom for each task
%Return maxTD: A matrix containing the maximum threshold distance for each
%degree of freedom for each task
function [minTO stepTO maxTO] = readTO()

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, use a dlmread on the file to get a matrix with all of the values in
%the file, then we can appropriately assign the values to the kt and kp
%vector/matrix
rawData = o.read('TO');

%The number of keypoints and degrees of freedom
[dof kinv three] = size(rawData);

%Now, initialize the size of the kt and kp vectors for time considerations
minTO=rawData(:,:,1);
stepTO=rawData(:,:,2);
maxTO=rawData(:,:,3);