%This class will be used to keep track of parameters, such that we do not
%have a mess of parameters floating about in our other classes or functions

classdef ParameterCollection
    
    %A list of all of the variables we need to store
    properties (SetAccess = private)
        %A cell array of parameters
        Params;
        %A cell array to readily associate names with indices
        paramNames;
        %The number of parameters
        numParam;
    end%properties
    
    
    %Methods for reading, setting and accessing the parameters
    methods
        
        %Our constructor will start by reading each parameter from file
        function P = ParameterCollection()
            
            %Create an organizer object to read from file
            o = Organizer();
            
            %Read the list of parameters from file
            paramFile = filereadn('Parameter');
            P.numParam = length(paramFile);
            
            %Create params as a cell array of parameter objects
            P.Params = cell( size(paramFile) );
            P.paramNames = cell( size(paramFile) );
            
            %Create the cell array of parameter objects and parameter names
            for p=1:P.numParam
                P.Params{p} = Parameter( paramFile{p}, o.read(paramFile{p}) );
                P.paramNames{p} = paramFile{p};
            end%for

        end%function
        
        
        %Set the parameter value
        function PC = set(PC,name,value)
            %Determine the number of the parameter we wish to set
            setNum = PC.search(name);
            %And set this numbered parameter to the value
            PC.Params{setNum} = PC.Params{setNum}.setValue(value);
        end%function
        
        
        %Get what the value of the parameter is
        function value = get(PC,name)
            %Determine the number of the parameter we wish to get
            getNum = PC.search(name);
            %Set value to the value of this parameter
            value = PC.Params{getNum}.Value;
        end%function
        
        
        %Read the parameters from file
        function PC = read(PC)
            o = Organizer();
            for p = 1:PC.numParam
                %Read the parameter for the name from file
                PC.Params{readNum} = Parameter( PC.paramNames{p}, o.read( PC.paramNames{p} ) );
            end%for
        end%function
        
        
        %Write the parameters to file
        function PC = write(PC)
            o = Organizer();
            for p = 1:PC.numParam
                %Write the parameter for the name to file
                o.write( PC.paramNames{p}, PC.Params{p}.Value );
            end%for
        end%function
        
                
        %Find the number associated with the inputted parameter name
        function paramNum = search(P,name)
           %The the index of the parameter corresponding to the specified
           %name
           paramNum = find( strcmp(name,P.paramNames) );
        end%function
        
        
    end%methods
    
end%class