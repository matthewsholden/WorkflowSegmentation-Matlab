%This function will, given a cell array, enter each cell array and
%transpose the data within the cell array, as opposed to the cell array
%itself

%Parameter C: A cell array of data

%Parameter CT: A cell array of tranposed data
function CT = celltranpose(C)

%Check if we have a cell array
if (iscell(C))
    %Create a cell array CT
    CT = cell(size(C));
    %Iterate over all elements of C
    for i=1:numel(C)
        %Perform the same operation on each entry of C
        CT{i} = celltranpose(C{i});
    end
    %Othewise simply transpose C
else
    CT = C';
end
