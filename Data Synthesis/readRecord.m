%This function will be responsible for reading a procedure record from file and
%converting the data into a form that the Sythetic function can handle,
%such that it can generate the required synthetic data

%Return D: A cell array of data objects
function D = readRecord()

%Create an organizer such that the data is written to the specified
%location recorded in file
o = Organizer();

%Read the procedures from file
rawProcedure = o.readAll('Procedure');
%Read the tasls from file
rawTask = o.readAll('Task');
%Read the skill level from file
rawSkill = o.readAll('Skill');

%The number of procedures is the length of the cell arrays
procs = length(rawProcedure);

%Create cell arrays for the variables to save time
T = cell(1,procs);
X = cell(1,procs);
K = cell(1,procs);
S = cell(1,procs);


%Now, iterate over all procedures and assign each record to a data
%object...
for p=1:procs
   %For each procedure, take out the time from the procedural record
   %We could do this for the task record also
   T{p} = rawProcedure{p}(:,1);
   %The X data is the rest
   X{p} = rawProcedure{p}(:,2:end);
   %The task data is all but the first row of the rawTask
   K{p} = rawTask{p}(:,2:end);
   %The skill is just the rawSkill
   S{p} = rawSkill{p}; 
end

%Now that we have read the data from file, create a cell array of data
%objects to store our newly read data
D = cell(1,procs);
%Now, iterate over all procedures and create the data objects
for p=1:procs
   %For each data object 
    D{p} = Data(T{p},X{p},K{p},S{p});
end

