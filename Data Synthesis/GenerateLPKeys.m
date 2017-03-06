% This function will generate random needle insertion procedures with
% arbitrary task repitition.

%Parameter numProcedures: The number of procedures to generate
%Parameter maxInsertions: The maximum of insertions before ending
%Parameter taskLengths: The average length of each task

%Return procedureKeys: A cell array of procedure keys that can be used to
%generate simulated data
function procedureKeys = GenerateLPKeys( numProcedures, maxInsertions, taskLengths )

TASK_OFFSET = 1;
END_TASK = 6 + TASK_OFFSET;
INSERT_TASK = 3 + TASK_OFFSET;

% This are the transitions we will use
o = Organizer();
TRANS = zeros(7);
TRANS(1,2) = 1; % Ensure that task one is done first
TRANS(2:6,2:6) = o.read('Sense');
TRANS(6,7) = 1; % When finished that retraction, transition to the end task
TRANS(7,7) = 1; % Stay on end task
TRANS = bsxfun( @rdivide, TRANS, sum( TRANS, 2 ) );

EMIS = eye(7);

procedureKeys = cell ( 1, numProcedures );
% Generate random sequences
for i = 1:numProcedures
   currSeq = hmmgenerate( 200, TRANS, EMIS );
   currSeq = currSeq( currSeq ~= END_TASK );
   insertionIndices = find( currSeq == INSERT_TASK, maxInsertions + 1, 'first' );
   
   if ( numel( insertionIndices ) > maxInsertions )
       % This gets the vector up until the offending insertion
       currSeq = currSeq( 1:( insertionIndices( maxInsertions + 1 ) - 1 ) );
   end
   
   % This line replaces with optimal sequence
   currSeq = [ 1 2 3 4 5 ] + TASK_OFFSET;
   
   currKey = KeyGenerator();
   
   for j = 1:numel( currSeq )
       currKey = currKey.addTask( currSeq(j) - TASK_OFFSET, taskLengths( currSeq(j) - TASK_OFFSET ) );   
   end
   
   procedureKeys{i} = currKey;
   
end
