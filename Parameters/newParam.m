%This function will be used to set the Param matrix to a particular size, and
%each element to a particular specified value

%Parameter sz: A n component vector specifying the for Param
%Parameter value: The value to which all Param should be set

%Return status: Whether or not the procedure was successful
function Param = newParam(paramName,sz,value)

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%First, create a tensor all of ones pf the appropriate size
Param=ones(sz);

%Now, multiply the tensor by value such that each element is equal to value
Param=value*Param;

%Now, write the tensor to file appropriately
o.write(paramName,Param);

%Clear the organizer object
clear o;

%Return the parameter that has been written to file
