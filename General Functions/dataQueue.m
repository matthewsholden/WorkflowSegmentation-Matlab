%This class will represent a queue object for storing data points (ie
%doubles). We will choose to implement this using an array structure.

classdef dataQueue
    
    %First, declare all of the properties of the queue
    properties (SetAccess = private)
        %An array of entries
        x;
        %An count of how many data points are in the array
        count;
    end
    
    %Now declare the methods (there are 5: enqueue, dequeue, front, size, isEmpty)
    methods
        
        %We need a constructor that initialize the queue. Since x will be
        %resized dynamically, we only need to initialize the count to zero,
        %but we may as well give a starting value for x if we have one
        function Q = dataQueue(initialSize)
            Q.count=0;
            Q.x=zeros(initialSize,1);
        end
        
        %Add an element to the end of the queue
        function Q = enqueue(Q,value)
            %First, incerement the count
            Q.count = Q.count + 1;
            %Now, add the new data point to the end of the array
            Q.x(Q.count) = value;
        end
        
        %Take the element off the front of the queue
        function Q = dequeue(Q)
            %Now, shuffle the succeeding elements of the queue
            for i=1:(Q.count-1)
                Q.x(i) = Q.x(i+1);
            end
            %Decrease the count of the queue
            Q.count=Q.count-1;
        end
        
        %Display the element at the front of the queue
        function res = front(Q)
            %Assign the result to be the first entry of the queue
            res = Q.x(1);
        end
        
        %Return a count of how many data points are in the queue
        function res = getSize(Q)
            res = Q.count;
        end

        %Return whether or not the queus is empty (use count attribute)
        function res = isEmpty(Q)
           res = (Q.count == 0); 
        end

    end
end