%This function will take an output file from the NDI tracking software, and
%produce a procedure, task, and skill file for the segmentation algorithm

%Parameter subjNum: The number of the subject we are interested in
%Parameter trial: The type of procedural we are interested in for the
%particular subject (ie Trial1, Practice4, Reference1, etc...)
%Parameter skill: A string indicating skill (ie Novice, Expert)
%Parameter technique: The name of the procedure (ie TR, TL, CR, CL)

%Output D: A data object with the information from the file
function D = NDITrackToRecord(subjNum,trial,skill,technique)

%Read the data as a matrix
[procFile segFile] = findData(subjNum,trial,skill,technique);

procData = dlmread(procFile);

%The size of the raw data
[n dof3] = size(procData);

%The first 7 columns are the needle
%The next 7 columns are the reference
%The final 7 columns are the probe
framesPerSec = 20;

%Get the columns
NeedleAngle = procData(:,1);
NeedleW = procData(:,2:4);
NeedlePos = procData(:,5:7);

ProbeAngle = procData(:,8);
ProbeW = procData(:,9:11);
ProbePos = procData(:,12:14);

RefAngle = procData(:,15);
RefW = procData(:,16:18);
RefPos = procData(:,19:21);

%Create a vector of DOFs to store the needle data
X = zeros(n,8);

%Iterate over all time steps, and calculate the DOF in quaternion for the
%needle in reference to the reference sensor
for i=1:n
    %Repeat if there the point is all zeros
    if ( RefPos(i,:) == zeros(size(RefPos(i,:))) )
        X(i,:) = X(i-1,:);
    else
        X(i,:) = axisAngleToDOF(NeedleW(i,:),NeedleAngle(i,:),NeedlePos(i,:),RefW(i,:),RefAngle(i,:),RefPos(i,:));
    end
end%for

%Now, we must determine the time
T = (1:n)' .* 1/framesPerSec;

S = 0;

%Read the manual segmentation points from the Microsoft Excel file we have
%compiled
[transT transK] = readManualSegmentation(segFile,trial);

%Now, turn the segmentation into a task record
K = segmentationToRecord(T,transT,transK);

%Now, finally, for any times that the task is not assigned, crop them out
T = T( K ~= 0 );
X = X( K ~= 0 , : );
K = K( K ~= 0 );

%Finally, create the data objects
D = Data(T,X,K,S);

writeRecord(D);

