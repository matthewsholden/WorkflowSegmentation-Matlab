%This function will calculate the reference matrix of the needle oriented
%at the insertion point

%Parameter subjNum: The number of the subject we are interested in
%Parameter trial: Type of protocol (ie Trial1, Practice4, Reference1)
%Parameter skill: A string indicating skill (ie Novice, Expert)
%Parameter technique: The name of the procedure (ie TR, TL, CR, CL)

%Output AvgM: The average reference to entry matrix
function X_Ref_Ent = NDITrackRefEnt(subjNum,trial,skill,technique)

%Read the tracking record from file using already defined reading
[Sty_Tr, ~, Ref_Tr] = NDITrackToDataNoTask(subjNum,trial,skill,technique);

%Calculate the reference to stylus transform
Ref_Sty = Sty_Tr.relative( Ref_Tr, true, false);

%The reference to insertion transform is calculated as the average
X_Ref_Ent = mean( Ref_Sty.X, 1);

%Write this transform to file
o = Organizer();
o.write( 'ReferenceToEntry', dofToMatrix(X_Ref_Ent) );