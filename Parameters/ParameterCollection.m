%This class will be used to keep track of parameters, such that we do not
%have a mess of parameters floating about in our other classes or functions

classdef ParameterCollection
    
    %A list of all of the parameters we need to store
    properties (SetAccess = private)
        %A cell array of parameters, noting that we cannot sort, add,
        %remove parameters at all
        Params;
        
        %A cell array to readily associate names with indices
        paramNames;
        
    end
    
    
    %Methods for reading, setting and accessing the parameters
    methods
        
        %Our constructor will start by reading each parameter from file
        function P = ParameterCollection()
            %Create an organizer object to read from file
            o = Organizer();
            
            %Create params as a cell array of parameter objects
            P.Params = cell(1,12);
            P.paramNames = cell(1,12);
            
            %If we use getters and setters, we won't be affected if we just
            %numbers to reference, because each number will have an
            %associated name, so we can search by name
            
            %Transitions
            P.Params{1} = Parameter('Allow',o.read('Allow'));
            P.Params{2} = Parameter('Sense',o.read('Sense'));
            P.Params{3} = Parameter('Next',o.read('Next'));
            
            %Transformations
            P.Params{4} = Parameter('Orth',o.read('Orth'));
            P.Params{5} = Parameter('TransPCA',o.read('TransPCA'));
            P.Params{6} = Parameter('TransLDA',o.readAll('TransLDA'));
            P.Params{7} = Parameter('Mn',o.read('Mn'));
            
            %Clustering
            P.Params{8} = Parameter('CP',o.read('CP'));
            P.Params{9} = Parameter('Cent',o.read('Cent'));
            P.Params{10} = Parameter('End',o.read('End'));
            P.Params{11} = Parameter('Weight',o.read('Weight'));
            
            %Thresholding
            P.Params{12} = Parameter('TP',o.read('TP'));
            P.Params{13} = Parameter('TP_Opt',o.read('TP_Opt'));
            
            %Keep a cell array of names such that each name can be readily
            %associated with an index
            P.paramNames{1} = 'Allow';
            P.paramNames{2} = 'Sense';
            P.paramNames{3} = 'Next';
            
            P.paramNames{4} = 'Orth';
            P.paramNames{5} = 'TransPCA';
            P.paramNames{6} = 'TransLDA';
            P.paramNames{7} = 'Mn';
            
            P.paramNames{8} = 'CP';
            P.paramNames{9} = 'Cent';
            P.paramNames{10} = 'End';
            P.paramNames{11} = 'Weight';
            
            P.paramNames{12} = 'TP';
            P.paramNames{13} = 'TP_Opt';
            
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
           %The the index of the parameter corresponding to the specified
           %name
           paramNum = find( strcmp(name,P.paramNames) );
        end
        
        
        
    end
    
end