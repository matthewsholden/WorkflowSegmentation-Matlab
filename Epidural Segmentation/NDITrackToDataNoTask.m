%This function will take an output file from the NDI tracking software, and
%produce a Data object from the file

%Parameter subjNum: The number of the subject we are interested in
%Parameter trial: Type of protocol (ie Trial1, Practice4, Reference1)
%Parameter skill: A string indicating skill (ie Novice, Expert)
%Parameter technique: The name of the procedure (ie TR, TL, CR, CL)

%Output D: A data object with the information from the file
function [Sty_Tr Pro_Tr Ref_Tr] = NDITrackToDataNoTask(subjNum,trial,skill,technique)


%Find the location of the NDI output file and segmention xlsx file
[procFile segFile] = findDataEP(subjNum,trial,skill,technique);
procData = dlmread(procFile);

%Determine the number of data points collected
[n, ~] = size(procData);

%Read the frequency of recording from file
o = Organizer();
framesPerSec = o.read('FramesPerSec');
%Now, we must determine the time and tasks
T = (1:n)' .* 1/framesPerSec;
K = zeros( size(T) );


%The first 7 columns are the needle
%The next 7 columns are the probe
%The final 7 columns are the reference
StyAngle = procData(:,1);
StyW = procData(:,2:4);
StyPos = procData(:,5:7);

ProAngle = procData(:,8);
ProW = procData(:,9:11);
ProPos = procData(:,12:14);

RefAngle = procData(:,15);
RefW = procData(:,16:18);
RefPos = procData(:,19:21);


%Create a vector of DOFs to store the needle data
X_Sty_Tr = zeros(n,8);
X_Ref_Tr = zeros(n,8);
X_Pro_Tr = zeros(n,8);


%Iterate over all time steps, and calculate the DOF in quaternion for the
%needle in reference to the reference sensor
for i=1:n
    %Repeat if there the point is all zeros
    if ( RefPos(i,:) == zeros(size( RefPos(i,:)) ) )
        X_Sty_Tr(i,:) = X_Sty_Tr(i-1,:);
        X_Pro_Tr(i,:) = X_Pro_Tr(i-1,:);
        X_Ref_Tr(i,:) = X_Ref_Tr(i-1,:);
    else
        X_Sty_Tr(i,:) = axisAngleToDOF(StyW(i,:),StyAngle(i,:),StyPos(i,:));
        X_Pro_Tr(i,:) = axisAngleToDOF(ProW(i,:),ProAngle(i,:),ProPos(i,:));
        X_Ref_Tr(i,:) = axisAngleToDOF(RefW(i,:),RefAngle(i,:),RefPos(i,:));
    end
end%for

%Convert the dofs in time into data objects
Sty_Tr = Data(T,X_Sty_Tr,K,0);
Ref_Tr = Data(T,X_Ref_Tr,K,0);
Pro_Tr = Data(T,X_Pro_Tr,K,0);

