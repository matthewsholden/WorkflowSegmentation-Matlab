%This function will take a cell array and output a matrix with the entries,
%padding matrices as necessary

%Parameter C: A cell array of data

%Return M: A matrix of the same data
function M = cellToMatrix(C)

%If C is cell array, then make C a cell array of cell arrays
if (iscell(C))
    
    %Test if it is multidimensional
    szC = size(C);
    ndim = length(szC);
    
    %Turn the matrix of cells into a cell array of cell arrays
    if ( ndim > 1 && ~( numel(C) == max(szC) ) )
        
        D = cell( 1 ,szC(1) );
        
        %Iterate over all elements of C
        for i=1:szC(end)
            
            %Get the vector of entries we wish to keep
            prodBeg = prod(szC(2:end));
            ix = ( 1 + (i-1) * prodBeg ) : ( i * prodBeg );
            
            %Assign the subarray of cells
            if ( ndim > 2 )
                D{i} = reshape( C(ix), szC(2:end) );
            else
                D{i} = C(ix);
            end%if
            
            D{i} = cellToMatrix(D{i});
            
        end%for
        
        C = D;
        
        %If we are (1,1)
    elseif ( szC == ones(size(szC)) )
        
        C = C{1};
        
    end%if
    
    
    %Iterate over all possible dimensions, and check if it is singleton
    largeDim = 0;
    found = false;
    
    while (~found)
        
        %Increment the test dimension
        largeDim = largeDim + 1;
        found = true;
        
        for i=1:length(C)
            
            %Check if such a dimension exists for this cell
            %Calculate the number of non-singleton dimensions
            if ( length(size(C{i})) >= largeDim && size(C{i},largeDim) > 1)
                found = false;
            end%if
            
        end%for
        
    end%while
    
    %If the number of dimensions is 1 then pad the cells together
    szC1 = size(C{1});
    szC1(largeDim) = 0;
    M = double.empty(szC1);
    
    %Pad the matrices together in dimension one larger than the largest
    for i=1:length(C)
        M = cat( largeDim, M, C{i} );
    end%for
    
    %Otherwise, assign D to C
else
    
    M = C;
    
end%if

