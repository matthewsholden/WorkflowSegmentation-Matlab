%This function will take a data object, and write an fCal tracking
%style file

%Parameter D: Cell array of data objects to write to file
%Parameter outFile: The name of the xml file to write the data
%Parameter toolNames: The names of the tools/transforms we wish to read

%Return status: Whether or not writing to file was successful
function status = DataTofCalTrack(D,outFile,toolNames)

%Indicate the function has not finished
status = 0;

%Create cell array of each part of the data object
%We have up to n tools to record
numTools = length(toolNames);

XTT = cell(1,numTools);
X = cell(1,numTools);

%Grab the information from the data objects
for j=1:numTools
    XTT{j} = D{j}.T;
    X{j} = D{j}.X;
end%for


%Open the file
file = fopen( outFile, 'w' );
numFrames = D{1}.count;

%Whatever boilerplate at the start of fCal track files
fprintf( file, ['ObjectType = Image', '\n' ]);
fprintf( file, ['NDims = 3', '\n' ]);
fprintf( file, ['AnatomicalOrientation = RAI', '\n' ]);
fprintf( file, ['BinaryData = True', '\n' ]);
fprintf( file, ['BinaryDataByteOrderMSB = False', '\n' ]);
fprintf( file, ['CenterOfRotation = 0 0 0', '\n' ]);
fprintf( file, ['CompressedData = False', '\n' ]);
fprintf( file, ['DimSize = 0 0 ', num2str(numFrames), '\n' ]);
fprintf( file, ['ElementSpacing = 1 1 1', '\n' ]);
fprintf( file, ['ElementType = MET_UCHAR', '\n' ]);
fprintf( file, ['Offset = 0 0 0', '\n' ]);
fprintf( file, ['TransformMatrix = 1 0 0 0 1 0 0 0 1', '\n' ]);
fprintf( file, ['UltrasoundImageOrientation = MF', '\n' ]);

%Assume all of the tools have the transforms at the same time
%No imaging
for i = 1:numFrames
    
    %Get the time from the first tool
    currTime = num2str( D{1}.T(i) );
    currFrame = num2str( i - 1 ); %indexing starts at zero in PLUS
    while ( length(currFrame) < 4 )
        currFrame = ['0', currFrame];
    end%while
    
    %Iterate over all tools
    for j = 1:numTools
        
        %Convert the current transform to string
        currTransform = mat2str( reshape( dofToMatrix(X{j}(1,:))',1,16 ), 6 );
        currTransform = currTransform( 2:end-1 );
        currTransformName = toolNames{j};
        
        %Write to file
        fprintf( file, ['Seq_Frame', currFrame, '_', currTransformName, ' = ', currTransform, '\n' ]);
        fprintf( file, ['Seq_Frame', currFrame, '_', currTransformName, 'Status = OK', '\n' ]);

        
        %Now, remove a row from all observations
        XTT{j} = XTT{j}(2:end,:);
        X{j} = X{j}(2:end,:);
    
    end%for

    fprintf( file, ['Seq_Frame', currFrame, '_Timestamp = ', currTime, '\n' ]);
    fprintf( file, ['Seq_Frame', currFrame, '_ImageStatus = INVALID', '\n' ]);

end%for

fprintf( file, 'ElementDataFile = LOCAL' );

%Close the file
fclose( file );

%Free the memory
clearvars;

%Indicate the function is finished
status = 1;