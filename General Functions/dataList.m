%This class will represent a queue object for storing data points (ie
%doubles). We will choose to implement this using an array structure.

classdef dataList < Handle
    
    %First, declare all of the properties of the list
    properties (SetAccess = private)
        %An array of entries
        x;
        %An count of how many data points are in the array
        count;
    end
    
    %Now declare the methods (there are 5: addAt, removeAt, elementAt, size, isEmpty)
    methods
        
        %We need a constructor that initialize the list. Since x will be
        %resized dynamically, we only need to initialize the count to zero,
        %but we may as well give a starting value for x if we have one
        function L = dataList(initialSize,initialArray)
            L.count=0;
            %If we are passed an initial array, then add all of its entries
            %to the list
            if (nargin > 1)
                L.count = max(size(initialArray));
                L.x=initialArray;
            else
                L.x=zeros(initialSize,1);
            end
        end
        
        %Add an element to the specified location in the list
        function L = addAt(L,loc,value)
            
            %Must test for emptiness prior to incrementing count
            if (L.isEmpty)
                %Only increment the count
                L.count = L.count + 1;
            else
                %First, incerement the count
                L.count = L.count + 1;
                %Now, shuffle the data points if necessary
                for i=(L.count-1):loc
                    L.x(i+1)=L.x(i);
                end
            end
            %Finally, assign the element at location to be the new value
            L.x(loc)=value;
        end
        
        %Add an element to the rear of the list
        function L = addRear(L,value)
            %Increment the count
            L.count = L.count + 1;
            %Assign the new element to be the new value
            L.x(L.count)=value;
        end
        
        %Take the element off the front of the list
        function L = removeAt(L)
            %Now, shuffle the succeeding elements of the queue
            for i=loc:(L.count-1)
                L.x(i) = L.x(i+1);
            end
            %Decrease the count of the queue
            Q.count=Q.count-1;
        end
        
        %Display the element at the front of the list
        function res = elementAt(L,loc)
            %Assign the result to be the first entry of the queue
            res = L.x(loc);
        end
        
        %Return a count of how many data points are in the list
        function res = getSize(L)
            res = L.count;
        end
        
        %Return whether or not the list is empty (use count attribute)
        function res = isEmpty(L)
            res = (L.count == 0);
        end
        
    end
end