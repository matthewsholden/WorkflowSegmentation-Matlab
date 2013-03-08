%This class will be used to keep track of parameters, such that we do not
%have a mess of parameters floating about in our other classes or functions

classdef ParameterCollection
    
    %A list of all of the parameters we need to store
    properties (SetAccess = private)
        %A matrix of allowed transitions
        Allow;
        %A matrix of sensible transitions
        Sense;
        %A matrix of next instruction given completed tasks (and order)
        Next;
        
        
        %The parameters for performing our orthogonal transformation
        Orth;
        %The transformation vector associated with the PCA or LDA (if
        %applicable)
        Trans;
        %Mean associated with each degree of freedom
        Mn;
        
        %The number of clustering centroids for each task
        K;
        %The centroid for each of our clusters
        Cent;
        %The number of the clusters corresponding to the end of each task
        End;
        %The weighting associated with each dimension of the clustering
        Weight;
        
        %The parameters associatted with thresholding
        TP;
        %The parameters associated with the optimization of thresholding
        TPO;
        
    end
    
    
    %Methods for reading, setting and accessing the parameters
    methods
        
        %Our constructor will start by reading each parameter from file
        function P = ParameterCollection()
            %Create an organizer object to read from file
            o = Organizer();
            
            %Read each parameter from file. We won't narrate through each
            %parameter, because that would be tedious and unecessary
            
            %Transitions
            P.Allow = Parameter('Allow',o.read('Allow'));
            P.Sense = Parameter('Sense',o.read('Sense'));
            P.Next = Parameter('Next',o.read('Next'));
            
            %Transformations
            P.Orth = Parameter('Orth',o.read('Orth'));
            P.Trans = Parameter('Trans',o.read('Trans'));
            P.Mn = Parameter('Mn',o.read('Mn'));
            
            %Clustering
            P.K = Parameter('K',o.read('K'));
            P.Cent = Parameter('Cent',o.read('Cent'));
            P.End = Parameter('End',o.read('End'));
            P.Weight = Parameter('Weight',o.read('Weight'));
            
            %Thresholding
            P.TP = Parameter('TP',o.read('TP'));
            P.TPO = Parameter('TPO',o.read('TPO'));
            
        end
        
        %We also want to be able to set the parameters, if we get new
        %information
        function P = set(P,name,value)
            %Determine the relevant field
            Field = P.search(name);
            %Set the object to be the set valued version of field
            P.search(name) = value;
        end
        
        
        
        
        %We want a private method that we can use to find the variable
        %associated with the given input
        function Param = search(P,name)
            %Find the associated variable to the name
            if (P.Allow.isName(name))
                Param = P.Allow;
            end
            if (P.Sense.isName(name))
                Param = P.Sense;
            end
            if (P.Next.isName(name))
                Param = P.Next;
            end
            if (P.Orth.isName(name))
                Param = P.Orth;
            end
            if (P.Trans.isName(name))
                Param = P.Trans;
            end
            if (P.Mn.isName(name))
                Param = P.Mn;
            end
            if (P.K.isName(name))
                Param = P.K;
            end
            if (P.Cent.isName(name))
                Param = P.Cent;
            end
            if (P.End.isName(name))
                Param = P.End;
            end
            if (P.Weight.isName(name))
                Param = P.Weight;
            end
            if (P.TP.isName(name))
                Param = P.TP;
            end
            if (P.TPO.isName(name))
                Param = P.TPO;
            end
            %That is all the parameters
        end
        
        
        
    end
    
end