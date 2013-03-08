%This function will perform a task segmentation of EP procedures, and
%write the results, along with the parameter values to file

%Parameter outFile: The name of the output file we wish to generate

%Return currAcc: The accuracy of the task segmentation
function currAcc = segResultsEP(outFile)

%Create an organizer object
o = Organizer();

%Create a parameter collection object
PC = ParameterCollection();

%Create a cell array of skill levels and techniques
skills = {'Novice','Novice','Expert','Expert'};
techniques = {'CL','CR','CL','CR'};

%Perform the segmentation of the LP procedure
currAcc = [];
try
    %Iterate over all skills/techniques
    for i = 1:length(skills)
        currAcc = padcat(1, currAcc, segmentEpiduralType( skills{i}, techniques{i} ) );
    end%for
    %If there are no errors, the number of accuracies is number of skills
    numAcc = length(skills);
catch
    %Determine the number of accuracies that correctly wrote
    numAcc = size( currAcc, 1 );
    err = lasterror;
    disp(err);
    disp(err.message);
    disp(err.stack);
    disp(err.identifier);
end%trycatch

%Create a cell array of results
R = cell( numAcc, 2);
%Iterate over all recorded skills/techniques
for i = 1:numAcc
    R{ i, 1 } = [ skills{i}, ' ', techniques{i} ];
    R{ i, 2 } = currAcc( i, : );
end%for

%Create a cell array of parameters
A = cell( PC.numParam, 2);
for i=1:PC.numParam
    A{i,1} = PC.paramNames{i};
    A{i,2} = PC.Params{i}.Value;
end%for

%Concatenate the parameters with the results
M = cat( 1, R, A);

%Write to dated file
DS = datestr(clock);
DS( strfind( DS, ':') ) = '-';
fileName = [ o.rootPath, '/../Results/' outFile, ' ', DS, '.xlsx' ];

%Iterate over all worksheets and add data
for i = 1:size(M,1)
    if ( ndims( M{i,2} ) <= 2 )
        xlswrite( fileName, M{i,2}, M{i,1} );
    end%if
end%for
