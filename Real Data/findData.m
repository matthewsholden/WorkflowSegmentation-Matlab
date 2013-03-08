%This function will use convert a subject number and a particular procedure
%specification into a file path for the procedure and a file path for the
%manual segmentation in execl. Use an orgnizer object to determine these
%locations

%Parameter subNum: The number of the subject we are interested in
%Parameter proc: The type of procedure we are interested in
%Parameter vrc: Whether or not we have a virtual reality or control group
%subject
%Parameter L: Whether the procedure is L4-5 or L3-4

%Return procFile: The file path for the procedure
%Return segFile: The file path for the manual segmentation
function [procFile segFile] = findData(subjNum,procType,virtual,lumbarJoint)

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
procPath = [procPath, '/', virtual, '/', 'Subject ', subjStr];

%Next, determine the path associated with this subject's manual
%segmentation
segPath = o.pathName{o.search(['Manual ', lumbarJoint])};
%And concatenate with the root path
segPath = [o.rootPath, '/', segPath];


%Now, file the file names using this provided information
procName = ['Subject ', subjStr, ' - ', procType, ' - ', lumbarJoint];
segName = ['Subject ', subjStr];

%Finally, concatenate the file path with the file name
procFile = [procPath, '/', procName, '.xml'];
segFile = [segPath, '/', segName, '.xlsx'];

