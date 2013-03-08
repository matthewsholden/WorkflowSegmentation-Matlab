%This function will take a folder, train the algorithm using everything in
%that folder except the last file, and then test on the last file
%Write everything very explicitly

%Parameter dirPath: Name of folder from which we are segmenting
%Parameter toolName: The name of the tool we must segment

%Return status: Whether or not the procedure was successful
function status = WorkflowSegmentationTest( dirPath )

status = 0;


%create an organizer object for reading/writing files
o = Organizer();

%Get the contents of the current directory
currDir = dir( [ dirPath, '/*xml' ] );
numFile = length( currDir );
numTrain = numFile - 1;

%Get the segmentation file
currSeg = dir( [ dirPath, '/*xlsx' ] );

%We know the tool name is Tool_1
toolNames = {'StylusTipToRAS'};

%D is a cell array of procedures
D_Train = cell(1,numTrain);

for i = 1:numFile
    
    %Get the transform information
    StyTip_RAS_Cell = AscTrackToData( [ dirPath, '\', currDir(i).name ], toolNames );
    StyTip_RAS = StyTip_RAS_Cell{1};
    
    
    if ( i > numTrain )
        D_Test = StyTip_RAS;
    else
        %Get the manual task segmentation
        [TransT TransK] = readManSegST( [ dirPath, '\', currSeg(1).name ], i );
        K = segToTaskData( StyTip_RAS.T, TransT, TransK );
        chop = ( K ~= 0 );
        
        T = StyTip_RAS.T(chop);
        X = StyTip_RAS.X(chop,:);
        K = K(chop);
        S = StyTip_RAS.S;
        
        %Now create a new data object
        D_Task = Data( T, X, K, S );
        
        D_Train{i} = D_Task;
    end%if
    
end%for

%Now train the algorithm
markovTrain( D_Train );

%And segment the test procedure
MD = markovSegment( D_Test );

%Output the segmentation...
D_Out = cell(1,1);
D_Out{1} = MD.DK;
DataToTaskSegXML( D_Out, [ dirPath, '\MatlabSegmentation.xml' ], {'StylusTipToRAS'} );

status = 1;