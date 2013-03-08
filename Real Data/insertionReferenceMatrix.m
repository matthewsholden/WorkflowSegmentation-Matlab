%This function will calculate the reference matrix of the needle oriented
%at the insertion point

%Parameter subjNum: The number of the subject we are interested in
%Parameter procType: The type of procedural we are interested in for the
%particular subject (ie Trial1, Practice4, Reference1, etc...)
%Parameter skill: A string indicating skill (ie Novice, Expert)
%Parameter procName: The name of the procedure (ie TR, TL, CR, CL)

%Output AvgM: The average tranformation matrix
function AvgM = insertionReferenceMatrix(subjNum,procType,trial,procName)

%Read the data as a matrix
[procFile segFile] = findData(subjNum,procType,trial,procName);

procData = dlmread(procFile);

%The size of the raw data
[n dof3] = size(procData);

%The first 7 columns are the needle
%The next 7 columns are the probe
%The final 7 columns are the reference

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

%The average transformation matrix
AvgM = zeros(4);

%Iterate over all time steps, and calculate the DOF in quaternion for the
%needle in reference to the reference sensor
for i=1:n
    
    %Convert the tool to transformation matrix form
    NeedleR = axisAngleToMatrix(NeedleW(i,:),NeedleAngle(i,:));
    NeedleM = eye(4);
    NeedleM(1:3,1:3) = NeedleR;
    NeedleM(1:3,4) = NeedlePos(i,:);
    
    %Convert the reference to transformation matrix form
    RefR = axisAngleToMatrix(RefW(i,:),RefAngle(i,:));
    RefM = eye(4);
    RefM(1:3,1:3) = RefR;
    RefM(1:3,4) = RefPos(i,:)';
    
    %Calculate the needle in reference to the reference
    M = inv(RefM) * NeedleM;
    
    %Add it to the average transformation matrix
    AvgM = AvgM + M;
  
end%for

%Now, calculate the average M
AvgM = AvgM ./ n;

%Write this to file as the tool
o = Organizer();
o.write('Tool',AvgM);
