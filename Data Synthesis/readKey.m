%This function will be responsible for reading a threshold distance
%iteration step from file and returning it to the calling function

%Return T: A vector of the time steps at each keypoint
%Return X: A vector of each degree of freedom at each keypoint
%Return K: A vector indicating which task starts at each keypoint
function [T X K] = readKey()

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, use a dlmread on the file to get a matrix with all of the values in
%the file, then we can appropriately assign the values to the kt and kp
%vector/matrix
rawData = o.readAll('Key');

%Clear the organizer object now that we are done with it
clear o;

%The number of keypoints and degrees of freedom
keys = length(rawData);

%Now, initialize the size of T, X, K for time considerations
T=cell(1,keys);
X=cell(1,keys);
K=cell(1,keys);

%Deconcatenate the data into its components
for k=1:keys
    %Time is the first column
    T{k} = rawData{k}(:,1);
    %The task is the second column
    K{k} = rawData{k}(:,2);
    %The X data is the rest of the data
    X{k} = rawData{k}(:,3:end);
    
end

