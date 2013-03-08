%This function will take an MHA file (recorded in fCal) and convert it to
%an XML file (format from TransformRecorder) such that we can visualize the
%procedure in Slicer

%Parameter inputFile: The name of the input MHA file
%Parameter outputFile: The name of the output XML file

%Return DXML: The data object with the StylusTipToReference transform
function DXML = mhaToXML(inputFile,outputFile)

%Create an organizer
o = Organizer();
o.deleteAll('Procedure');
o.deleteAll('Task');
o.deleteAll('Skill');

%Create the cell arrays of tool names
toolNamesMHA = {'ReferenceToTrackerTransform','StylusToTrackerTransform','NeedleSensorToTrackerTransform'};
toolNamesXML = {'StylusTipToReference','StylusToNeedleBase'};
procNum = {1,2};

%First, read the input mha file
MHA = mhaToText( toolNamesMHA, inputFile );

Ref_Tr = MHA{1};
Sty_Tr = MHA{2};
Ns_Tr = MHA{3};

%Now, find the relative transform from Stylus to Reference
Sty_Ref = Ref_Tr.relative( Sty_Tr, true, false );
Sty_Ns = Ns_Tr.relative( Sty_Tr, true, false );

%Read the StylusTipToStylus transform
StyTip_Sty = dlmreadn ( replaceExtension(inputFile,'.tfm') ); 

%Then, find the StylusTipToReference
StyTip_Ref = Sty_Ref.calibration( o.read('Identity'), StyTip_Sty );

%Write this as a procedural record
writeRecord(StyTip_Ref);
writeRecord(Sty_Ns);

%Finally, read this record from file and write it to an XML file
DXML = textToXML( outputFile, toolNamesXML, procNum);

%Free the memory
clearvars -except DXML;


% %Calculate some distance metric to determin if the stylet is in needlebase
% Ns_Ref = Ref_Tr.relative( Ns_Tr, true, false );
% Sty_Ns = Ns_Ref.relative( Sty_Ref, true, false );
% 
% %Write this as a procedural record
% writeRecord(Sty_Ns);
% 
% %Finally, read this record from file and write it to an XML file
% DXML = textToXML( outputFile, toolNamesXML, {2});

% In_Base = someFunction(Sty_Ns);
% StyTip_Ref_In = StyTip_Ref.remove(In_Base);
% 
% %Write this as a procedural record
% writeRecord(StyTip_Ref_In);
% 
% %Finally, read this record from file and write it to an XML file
% DXML = textToXML( outputFile, toolNamesXML, {2});