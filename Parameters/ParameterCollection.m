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
        function P = set(P,name,value)
            %Determine the number of the parameter we wish to set
            setNum = P.search(name);
            %And set this numbered parameter to the value
            P.Params{setNum}.setValue(value);
        end%function
        
        
        %Get what the value of the parameter is
        function value = get(P,name)
            %Determine the number of the parameter we wish to get
            getNum = P.search(name);
            %Set value to the value of this parameter
            value = P.Params{getNum}.Value;
        end%function
        
        
        %Read the parameter from file
        function P = read(P,name)
            o = Organizer();
            %Determine the number of the parameter we wish to read
            readNum = P.search(name);
            %Read the parameter for the name from file
            P.Params{readNum} = o.read(name);
        end%function
        
        
        %Write the parameter to file
        function P = write(P,name)
            o = Organizer();
            %Determine the number of the parameter we wish to write
            writeNum = P.search(name);
            %Set value to the value of this parameter
            P = o.write(name, P.Params{writeNum}.Value );
        end%function
        
                
        %Find the number associated with the inputted parameter name
        function paramNum = search(P,name)
           %The the index of the parameter corresponding to the specified
           %name
           paramNum = find( strcmp(name,P.paramNames) );
        end%function
        
        
    end%function
    
end%function