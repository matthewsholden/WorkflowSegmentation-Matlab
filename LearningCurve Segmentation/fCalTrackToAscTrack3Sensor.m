%This function will take an MHA file (recorded in fCal) and convert it to
%an XML file (format from TransformRecorder) such that we can visualize the
%procedure in Slicer

%Parameter inputFile: The name of the input MHA file
%Parameter outputFile: The name of the output XML file

%Return status: Whether or not writing to file was successful
function status = fCalTrackToAscTrack3Sensor(inFile,outFile)

%Create the cell arrays of tool names
toolNamesMHA = {'ReferenceToTrackerTransform','StylusToTrackerTransform','NeedleSensorToTrackerTransform'};
toolNamesXML = {'StylusTipToReference','StylusToNeedleBase'};

%First, read the input mha file
DMHA = fCalTrackToData( inFile, toolNamesMHA );

Ref_Tr = DMHA{1};
Sty_Tr = DMHA{2};
Ns_Tr = DMHA{3};

%Now, find the relative transform from Stylus to Reference
Sty_Ref = Ref_Tr.relative( Sty_Tr, true, false );
Sty_Ns = Ns_Tr.relative( Sty_Tr, true, false );

%Read the StylusTipToStylus transform
StyTip_Sty = dlmreadn ( replaceExtension(inFile,'.tfm') ); 

%Then, find the StylusTipToReference
StyTip_Ref = Sty_Ref.calibration( eye(4), StyTip_Sty );

%Create a data object of these transforms
DXML = { StyTip_Ref, Sty_Ns};

%Finally, read this record from file and write it to an XML file
status = DataToAscTrack( DXML, outFile, toolNamesXML);

%Free the memory
clearvars -except DXML;
