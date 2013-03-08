%Given a manual segmentation of when the stylet is in and out of needle
%(recorded in Microsoft Excel), this function will read and output the
%start times of the segmentation

%Parameter fileName: The file containing the manual segmentation
%Parameter procName: The name of the procedure to be read

%Return T: The time stamps at which in/out transitions occur
%Return K: The name of the in (1), out (0)
function [T K] = readManSegLC(fileName,procName)

%Our file will be in the format:
%   TEST        Trial 1     Trial 2     Trial 3
%   T  K        T   K       T  K        T  K

%Convert procedure name into position in the xls file
if ( strcmp( procName, 'TEST_Parse.xml' ) )
   position = 1; 
elseif ( strcmp( procName, 'Trial01_Parse.xml' ) )
    position = 2;
elseif ( strcmp( procName, 'Trial02_Parse.xml' ) )
    position = 3;
elseif ( strcmp( procName, 'Trial03_Parse.xml' ) )
    position = 4;
elseif ( strcmp( procName, 'Trial04_Parse.xml' ) )
    position = 5;
elseif ( strcmp( procName, 'Trial05_Parse.xml' ) )
    position = 6;
end

%Now, read the manual segmentation from file
Data = xlsread(fileName);

%Consider only the data of the appropriate procedure (given the position)
T = Data( : , 2 * position );
K = Data( : , 2 * position - 1 );

%Since there may be other procedures with more segmentations, there may
%be some pesky NaNs on the end, so chop them off
chop = ~isnan(T);

T = [T(chop); 999999];
K = [K(chop); NaN];
