%This function will, given a manual annotation written to a Microsoft Excel
%file, return the task segmentation points (the time stamp at which each
%task starts)

%Parameter fileName: The name of the file we wish to read the manual
%segmentation from
%Parameter proc: The particular procedure we wish to consider for the
%subject (ie Trial 1)

%Return T: The time stamps at which each task transitions occurs
%Return K: The tasks starting at the corresponding time stamps
function [T K] = readManualSegmentation(fileName,proc)

%Our file will be in the format:
%Practice 1     Practice 2      Trial 1     Trial 2
%  T  K           T   K          T  K        T  K

%First, convert the proc specification into a number, so we can read the
%corresponding part of the xls file
if (strcmp(proc,'Trial1'))
   position = 1; 
elseif (strcmp(proc,'Trial2'))
    position = 2;
elseif (strcmp(proc,'Trial3'))
    position = 3;
elseif (strcmp(proc,'Trial4'))
    position = 4;
elseif (strcmp(proc,'Trial5'))
    position = 5;
elseif (strcmp(proc,'Trial6'))
    position = 6;
end

%Now, read the manual segmentation from file
Data = xlsread(fileName);

%Consider only the data of the appropriate procedure (given the position)
T = Data( : , 2 * position );
K = Data( : , 2 * position - 1 );

%Since there may be other procedures with more task transitions, there may
%be some pesky NaNs on the end, so chop them off
chop = ~isnan(T);

T = T(chop);
K = K(chop);
