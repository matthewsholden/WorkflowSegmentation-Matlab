%This function will return the task transition times given a manual
%segmentation specified in an Excel file

%Parameter fileName: Name of file from manual segmentation will be read
%Parameter trial: Type of protocol (ie Trial1, Practice4, Reference1)

%Return T: The time stamps at which each task transitions occurs
%Return K: The tasks starting at the corresponding time stamps
function [transT transK] = readManSegLP(fileName,trial)

%Our file will be in the format:
%Trial 1     Trial 2      Trial 3     Trial 4
%  T  K      T   K        T  K        T  K

%Convert trial into position, indicating location of segmentation in file
if (strcmp(trial,'Trial1') || strcmp(trial,'Practice1'))
   position = 1; 
elseif (strcmp(trial,'Trial2') || strcmp(trial,'Practice2'))
    position = 2;
elseif (strcmp(trial,'Trial3') || strcmp(trial,'Practice3'))
    position = 3;
elseif (strcmp(trial,'Trial4') || strcmp(trial,'Practice4'))
    position = 4;
end%if

%Now, read the manual segmentation from the Excel file
Data = xlsread(fileName);

%Consider only the data of the appropriate procedure (given the position)
transT = Data( : , 2 * position );
transK = Data( : , 2 * position - 1 );

%Chop off NaNs associated with different procedures having more transitions
chop = ~isnan(transT);

transT = transT(chop);
transK = transK(chop);
