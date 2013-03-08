%This class will represent a single parameter

classdef Parameter
    
    properties (SetAccess = private)
        %We need a value, which could be a matrix or vector or whatever
        Value;
        %We also need a name, which is a string
        Name;
    end
    
    
    methods
        %This constructor will take a name and a value
        function P = Parameter(name,value)
            %Set the name and value as specified
            P.Name = name;
            P.Value = value;
        end
        
        %Return whether or not the name is a specified name
        function match = isName(P,name)
            %compare the name string and the input
            if (strcmp(P.Name,name))
                match = true;
            else
                match = false;
            end
        end
        
        %Set the value and name
        function P = setValue(P,value)
            P.Value = value;
        end
        
        function P = setName(P,name)
            P.Name = name;
        end
        
    end
    
    
end