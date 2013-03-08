%This function will return a vector of trues and falses indicating if a
%particular index appears in the cell array of index sequences

%Parameter seq: A cell array of sequences of indices
%Parameter numMember: The number of member indices we are considering

%Return tf: A vector of true false values indicating whether each index
%appeared in the cell array of sequences
function tf = indexMember(seq,numMember)

%If the sequence is a cell, perform this same procedure on each element
if (iscell(seq))
    %Create a zero, since we don't previously know the size
    tf = zeros(1,numMember);
    %Perform the same operation, iterating over all elements
    for i=1:numel(seq)
        tf = tf | indexMember(seq{i},numMember);
    end
else
    %If the sequence is not a cell, then check over the sequence using the
    %ismember function
    tf = ismember(1:numMember,seq);
    
end