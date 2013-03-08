%This function will be responsible for writing a task record to file given
%data created from a target

%Parameter Key: A key generator object with the data we want to write to
%file specifying the key points of our procedure

%Return status: Whether or not the function was a success
function status = writeKey(Key)

%Initialize the status to zero to indicate we are not done yet
status=0;

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%Concatenate the data together
rawData = cat(2,Key.T,Key.K,Key.X);
    
%Now that we have composed our rawData matrix, write it to file
status = o.write('Key',rawData); 