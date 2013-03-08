%This function will, given a vector of doubles round some up and some down
%appropriately such that their total is equal to some other integer

%Parameter vec: The vector of doubles
%Parameter target: The target we wish to match

%Return roundVec: The rounded vector of integers summing to sum
function roundVec = roundToMatch( vec, target )

%Idea: Round everything down, then add one to highest fractional part items
%until the floored sum reaches the target sum

roundVec = vec;
floorSum = sum( floor( roundVec ) );

while ( floorSum < target )
    
    if ( roundVec == floor( roundVec ) )
        break;
    end%if
    
    frac = roundVec - floor(roundVec);
    [ ~, priority ] = max( frac );
    
    %Now, add one to highest priority item
    roundVec( priority ) = ceil( roundVec( priority ) );
    
    floorSum = sum( floor( roundVec ) );
    
end%while

if ( floorSum < target )
    warning('Vector could not be rounded to match target');
end%if

roundVec = floor( roundVec );