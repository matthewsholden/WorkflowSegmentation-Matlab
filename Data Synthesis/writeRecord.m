%This function will write the entire procedural record to file. This
%includes the degrees of freedom, the task and the skill-level

%Parameter D: A data object containing the necessary fields

%Return status: Whether or not the writing to file was successful
function status = writeRecord(D)
%Initialize the status to zero
status = 0;
%Create an organizer to write things to file
o = Organizer();

%Concatenate the time with the dofs
rawData = cat(2,D.T,D.X);
%Write the dofs to file
status = o.write('Procedure',rawData);

%Concatenate the time with the task
rawData = cat(2,D.T,D.K);
%Write the task to file
status = o.write('Task',rawData);

%Write the skill to file
status = o.write('Skill',D.S);

clear o;