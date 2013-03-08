%This function will be used to set the Q matrix to a particular size, and
%each element to a particular specified value

%Parameter elem: A 3 component vector specifying the for Q: one, dof
%the element which should be set to the particular value
%Parameter value: The value to which all Q should be set

%Return status: Whether or not the procedure was successful
function Param = setParam(paramName,elem,value)

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, read the tensor WX from file
Param=o.read(paramName);

%Now, set the appropriate element to the specified value
Param(linearIndex(elem,size(Param)))=value;

%Now, write the tensor to file appropriately
o.write(paramName,Param);

%Clear the organizer object
clear o;

%Return the parameter that has been written to file