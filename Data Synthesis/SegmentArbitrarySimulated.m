% This function will generate and segment simulated data with arbitrary
% workflow

%Parameter numProcedures: The number of procedures to generate
%Parameter maxInsertions: The maximum of insertions before ending
%Parameter taskLengths: The average length of each task
%Parameter trainingSize: The number of training data points

%Return acc: The workflow segmentation accuracy for each procedure
function acc = SegmentArbitrarySimulated( numProcedures, maxInsertions, taskLengths, trainingSize )

acc = zeros( 1, numProcedures );

NUM_TASKS = 5;

% Now, train the algorithm
for p = 1:numProcedures
    
    % Generate the keys
    keys = GenerateLPKeys( trainingSize, maxInsertions, taskLengths );
    
    % From the keys, generate the data
    D_Train = cell( 1, trainingSize );
    for t = 1:trainingSize
        D_Train{t} = Synthetic( keys{t} );
    end%for
    
    % Check all task have been generated, otherwise repeat
    for k = 1:NUM_TASKS
        currentTaskSize = 0;
        for t = 1:trainingSize
            currentTaskSize = currentTaskSize + numel( find( D_Train{t}.K == k, 1 ) );
        end
        if ( currentTaskSize == 0 )
            p = p - 1;
            break;
        end
    end
    
    
    
    % Grab the testing procedure
    testKey = GenerateLPKeys( 1, maxInsertions, taskLengths );
    D_Test = Synthetic( testKey{1} );
    
    % Train
    markovTrain( D_Train );
    
    % Segment
    MD = markovSegment( D_Test );
    
    % Check accuracy
    segAcc = segmentAccuracy( D_Test.K, MD.DK.X );
    
    %Write the accuracy to screen, and store it in vector
    disp( [ 'Procedure ', num2str( p ), ': ', num2str( segAcc ) ] );
    acc( p ) = segAcc;
    
    clear MD;
end
