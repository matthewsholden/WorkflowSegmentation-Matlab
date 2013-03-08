%This function will take a single object, and convert it into a cell array
%of objects (only one object in the cell array)

%Parameter Obj: The object we want to make a cell array of
%Parameter check: Whether or not we want to check if the object is already
%a cell array

%Return ObjC: A cell array of the object we have inputted
function ObjC = makeCell(Obj,check)

%Assume that the user wants a check if unspecified
if (nargin < 2)
    check = true;
end

%If the object is not already a cell array, or we don't want to check
if ( ~iscell(Obj) || ~check)
    %Create a cell array
    ObjC = cell(1,1);
    %Assign the cell array contents to be the input object
    ObjC{1} = Obj;
else
    %Otherwise, just output what was inputted
    ObjC = Obj;
end