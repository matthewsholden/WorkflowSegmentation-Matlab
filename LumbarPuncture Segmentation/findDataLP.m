%This function will use convert a subject number, protocol, skill level,
%and technique into a procedural recording file name and a manual
%segmentation file name

%Parameter subjNum: The number of the subject we are interested in
%Parameter trial: Type of protocol (ie Trial1, Practice4, Reference1)
%Parameter skill: A string indicating skill (ie TrialControl, PracticeVR)
%Parameter technique: The name of the procedure (ie L3-4, L4-5)

%Return procFile: The file path for the procedure
%Return segFile: The file path for the manual segmentation
function [procFile segFile] = findDataLP(subjNum,trial,skill,technique)


%Convert subject number to a string, for concatenation with other strings
subjStr = num2str(subjNum);


%Create an organizer object
o = Organizer();


%Determine path associated with particular subject's procedure
procPath = o.pathName{o.search('Subject')};
%And concatenate with the root path
procPath = [o.rootPath, '/', procPath];
%Find the directory of this subject based on skill and number
procPath = [procPath, '/', skill, '/', 'Subject ', subjStr];


%Determine path associated with particular subject's manual segmentation
segPath = o.pathName{o.search('Segmentation')};
%And concatenate with the root path
segPath = [o.rootPath, '/', segPath];


%Create the file names using this provided information
procName = ['Subject ', subjStr, ' - ', trial, ' - ', technique];
segName = ['Subject ', subjStr];


%Finally, concatenate the file path with the file name
procFile = [procPath, '/', procName, '.xml'];
segFile = [segPath, '/', segName, '.xlsx'];

