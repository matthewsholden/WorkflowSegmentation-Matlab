%This function will determine the maximum task number for a given set of
%task records by simply looking at all of them and finding the largest
%number

%Parameter D: A cell array of data objects, storing procedural records

%Return maxTask: The largest task number in existence
function [maxTask maxSkill] = calcMaxTask(D)

%We need an organizer to read/write from file if we do not have the
%records inputted
if (nargin == 0)
    D = readRecord();
end

%We might have just a single record as an input, in this case, create a
%cell array
if ( ~iscell(D) )
   D{1} = D; 
end
   
%Otherwise, there's nothing to read

%First, find the maximum task number...
maxTask = 0;

%Recall that procs, the number of procedures is the length of D
procs = length(D);

%Look through all procedure files
for p=1:procs
    
    %Find the maximum task number and if it is larger than the previous
    %maximum task number then proceed
    if ( max( D{p}.K ) > maxTask )
        maxTask = max( D{p}.K );
    end
    
end