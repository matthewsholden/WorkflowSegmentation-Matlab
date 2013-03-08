%This function will take a string filename, and replace its extension with
%a specified extension

%Parameter inFile: The name of the original file
%Parameter ext: The name of the new file extension
%Parameter all: Whether to replace all extensions, or just the last one

%Return outFile: The name of the file name with new extension
function outFile = replaceExtension(inFile,ext,all)

%Assume all to be false if not specified
if (nargin < 3)
    all = false;
end%if

%Find where all the dots appear
dotLoc = strfind(inFile,'.');

%Choose the indexing of 'dots' based on the all
if (all)
    dot = 1;
else
    dot = length(dotLoc);
end%if

%If there is no dot in the name, the just append
if (isempty(dotLoc))
    dotLoc = length(inFile) + 1;
else
    %Choose the correct dot
    dotLoc = dotLoc(dot);
end%if


%Now, choose only the characters before the dot and append the new ext
outFile = [ inFile(1:dotLoc-1), ext ];