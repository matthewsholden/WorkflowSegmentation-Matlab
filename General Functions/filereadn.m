%This task will be used to read an array of strings from a file separated
%by new lines

%Parameter fileName: The name of the file to read from

%Return data: A cell array of strings
function data = filereadn(fileName)

%First, read the characters from file as a large one dimensional array
rawData = fileread(fileName);

%Go through each element of the rawData and assign it into the array of
%strings, appending to the current string
c = 1;
%Index of the current string we are appending to
ix = 0;
%Initialize the first data string
currStr = '';
%Initialize the cell array of characters
data = cell(1,1);

%Now go through all characters
while (c < length(rawData))
    %Test if the character is a new line and if it is, move on to the next
    %string
    if (rawData(c) == 13 || rawData(c) == 10)
        ix = ix + 1;
        data{ix} = currStr;
        currStr = '';
        %For some reason each newline character is read by Matlab as two
        %newline characters
        if (rawData(c) == 13)
            c = c + 1;
        end%if
    else
        %Otherwise append the character to the current string
        currStr = [currStr, rawData(c)];
    end%if
    
    %Increment our count c
    c = c + 1;
end%while