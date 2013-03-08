%This class will be used to keep track of parameters, such that we do not
%have a mess of parameters floating about in our other classes or functions

classdef ParameterCollection
    
    %A list of all of the parameters we need to store
    properties (SetAccess = private)
        %A cell array of parameters, noting that we cannot sort, add,
        %remove parameters at all
        Params;
        
    end
    
    
    %Methods for reading, setting and accessing the parameters
    methods
        
        %Our constructor will start by reading each parameter from file
        function P = ParameterCollection()
            %Create an organizer object to read from file
            o = Organizer();
            
            %Create params as a cell array of parameter objects
            P.Params = cell(1,1);
            
            %If we use getters and setters, we won't be affected if we just
            %numbers to reference, because each number will have an
            %associated name, so we can search by name
            
            %Transitions
            P.Params{1} = Parameter('Allow',o.read('Allow'));
            P.Params{2} = Parameter('Sense',o.read('Sense'));
            P.Params{3} = Parameter('Next',o.read('Next'));
            
            %Transformations
            P.Params{4} = Parameter('Orth',o.read('Orth'));
            P.Params{5} = Parameter('Trans',o.read('Trans'));
            P.Params{6} = Parameter('Mn',o.read('Mn'));
            
            %Clustering
            P.Params{7} = Parameter('K',o.read('K'));
            P.Params{8} = Parameter('Cent',o.read('Cent'));
            P.Params{9} = Parameter('End',o.read('End'));
            P.Params{10} = Parameter('Weight',o.read('Weight'));
            
            %Thresholding
            P.Params{11} = Parameter('TP',o.read('TP'));
            P.Params{12} = Parameter('TPO',o.read('TPO'));
            
        end
        
        %We also want to be able to set the parameters, if we get new
        %information
        function P = set(P,name,value)
            %Determine the number of the parameter we wish to set
            setNum = P.search(name);
            %And set this numbered parameter to the value
            P.Params{setNum}.setValue(value);
        end
        
        %Get what the value of the parameter is
        function value = get(P,name)
            %Determine the number of the parameter we wish to get
            getNum = P.search(name);
            %Set value to the value of this parameter
            value = P.Params{getNum}.Value;
        end
        
        %Read the parameter to file
        function P = read(P,name)
            %Read the parameter for the name from file
            P = o.read(name);
        end
        
        %Write the parameter to file
        function P = write(P,name)
            %Determine the number of the parameter we wish to write
            writeNum = P.search(name);
            %Set value to the value of this parameter
            P = o.write(name,P.Params{writeNum}.Value);
        end
        
        
        
        %We want a private method that we can use to find the variable
        %associated with the given input
        function paramNum = search(P,name)
            %Iterate over all parameters numbers
            for p=1:length(P.Params)
                %Find the associated variable to the name
                if (P.Params{p}.isName(name))
                    paramNum = p;
                end
            end
            %That is all the parameters
        end
        
        
        
    end
    
end