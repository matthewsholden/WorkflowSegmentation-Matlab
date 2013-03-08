%This function will determine the maximum task number for a given set of
%task records by simply looking at all of them and finding the largest
%number

%Parameter D: A cell array of data objects, storing procedural records
%Parameter type: What thing we want the maximum of

%Return maxTask: The largest task number or skill number in existence
function maxVector = calcMax(D,type)

%Create a cell array if we do not already have one
D = makeCell(D);

%If no records inputted, read records from file
if (nargin < 1)
    D = readRecord();
end
if (nargin < 2)
    type = '';
end
   
%Otherwise, there's nothing to read

%First, find the maximum task number...
maxTask = 0; maxSkill = 0;

%Recall that procs, the number of procedures is the length of D
procs = length(D);

%Look through all procedure files
for p=1:procs
    
    %Find the maximum task number and if it is larger than the previous
    %maximum task number then proceed
    if ( max( D{p}.K ) > maxTask )
        maxTask = max( D{p}.K );
    end
    
     %Find the maximum skill number and if it is larger than the previous
    %maximum skill number then proceed
    if ( max( D{p}.S ) > maxSkill )
        maxSkill = max( D{p}.S );
    end
    
end

%If we want just one of skill or task, only add one of them to maxVector
if (strcmp(type,'Task'))
    maxVector = maxTask;
elseif (strcmp(type,'Skill'))
    maxVector = maxSkill;
else
    maxVector = [maxTask maxSkill];
end
