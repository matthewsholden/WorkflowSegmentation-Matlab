%This procedure will take a cell array of data objects, and convert them
%into a cell array of T,X,K,S

%Parameter D: A cell array of data objects of any order or depth

%Return T: A cell array of times
%Return X: A cell array of dofs
%Return K: A cell array of tasks
%Return S: A cell array of skill-levels
function [T X K S] = DataCell(D)
%Determine the size of the cell array of data
sz = size(D);   nm = numel(D);

%Create the cell arrays of data
T = cell(sz);   X = cell(sz);   K = cell(sz);   S = cell(sz);

%Use linear indexing such that we can access all element with only one loop
for i=1:nm
    %If the cell is a cell array of data objects
    if (iscell(D))
        %Assign the sub arrays of the D sub arrays
        [T{i} X{i} K{i} S{i}] = DataCell(D{i});
        %Otherwise, assign the properties in the D object to the cell arrays
    else
        T = D.T;
        X = D.X;
        K = D.K;
        S = D.S;
    end
    
end