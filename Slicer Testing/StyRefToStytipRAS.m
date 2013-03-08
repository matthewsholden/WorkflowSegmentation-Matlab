%This function will convert StylusToReference transforms into
%StylusTipToRAS transforms

%Parameter dirPath: Directory to relevant files

%Return status: Whether or not the function succeeded
function status = StyRefToStytipRAS( dirPath )

status = 0;


%create an organizer object for reading/writing files
o = Organizer();

%Get the contents of the current directory
currDir = dir( [ dirPath, '/*xml' ] );
numFile = length( currDir );

%We know the tool name is Tool_1
toolNames = {'Tool_1'};

for i = 1:numFile
    
    %Get the transform information
    Sty_Ref = AscTrackToData( [ dirPath, '\', currDir(i).name ], toolNames );
    StyTip_RAS{1} = Sty_Ref{1}.calibration( o.read('ReferenceToRAS'), o.read('StylusTipToStylus') );   
    DataToAscTrack( StyTip_RAS, [ dirPath, '\StyTipToRAS_', currDir(i).name ], {'StylusTipToRAS'} );    
    
end%for

status = 1;