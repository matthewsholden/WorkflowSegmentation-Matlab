%This function will use convert a subject number and a particular procedure
%specification into a file path for the procedure and a file path for the
%manual segmentation in execl. Use an orgnizer object to determine these
%locations

%Parameter subjNum: The number of the subject we are interested in
%Parameter trial: The type of procedural we are interested in for the
%particular subject (ie Trial1, Practice4, Reference1, etc...)
%Parameter skill: A string indicating skill (ie Novice, Expert)
%Parameter technique: The name of the procedure (ie TR, TL, CR, CL)

%Return procFile: The file path for the procedure
%Return segFile: The file path for the manual segmentation
function [procFile segFile] = findData(subjNum,trial,skill,technique)

%First, create an organizer object
o = Organizer();

%Convert the subject number to a string, for easier concatenation with
%other strings
subjStr = num2str(subjNum);

%Next, determine the path associated with this particular subject's
%procedure
procPath = o.pathName{o.search('Subject')};
%And concatenate with the root path
procPath = [o.rootPath, '/', procPath];
%Now, extend the procedural path given the subject's number and the vrc
procPath = [procPath, '/', skill, '/', 'Subject ', subjStr];

%Next, determine the path associated with this subject's manual
%segmentation
segPath = o.pathName{o.search('Segmentation')};
%And concatenate with the root path
segPath = [o.rootPath, '/', segPath];


%Now, file the file names using this provided information
procName = ['Subject ', subjStr, ' - ', trial, ' - ', technique];
segName = ['Subject ', subjStr];

%Finally, concatenate the file path with the file name
procFile = [procPath, '/', procName, '.txt'];
segFile = [segPath, '/', segName, '.xlsx'];

