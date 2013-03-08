%This function will return the task transition times given a manual
%segmentation specified in an Excel file

%Parameter fileName: Name of file from manual segmentation will be read
%Parameter position: The procedure number we are interested in

%Return T: The time stamps at which each task transitions occurs
%Return K: The tasks starting at the corresponding time stamps
function [transT transK] = readManSegST( fileName, position )

%Our file will be in the format:
%Trial 1     Trial 2      Trial 3     Trial 4
%  T  K      T   K        T  K        T  K

%Now, read the manual segmentation from the Excel file
Data = xlsread(fileName);

%Consider only the data of the appropriate procedure (given the position)
transT = Data( : , 2 * position );
transK = Data( : , 2 * position - 1 );

%Chop off NaNs associated with different procedures having more transitions
chop = ~isnan(transT);

transT = transT(chop);
transK = transK(chop);
