%This function will determine the maximum skill number for a given set of
%skill records by simply looking at all of them and finding the largest
%number

%Parameter D: A cell array of data objects, storing procedural records

%Return maxSkill: The largest skill-level number in existence
function maxSkill = calcMaxSkill(D)

%We need an organizer to read/write from file if we do not have the
%records inputted
if (nargin == 0)
    D = readRecord();
end
   
%Otherwise, there's nothing to read

%First, find the maximum skill number...
maxSkill = 0;

%Recall that procs, the number of procedures is the length of D
procs = length(D);

%Look through all procedure files
for p=1:procs
    
    %Find the maximum skill number and if it is larger than the previous
    %maximum skill number then proceed
    if ( max( D{p}.S ) > maxSkill )
        maxSkill = max( D{p}.S );
    end
    
end