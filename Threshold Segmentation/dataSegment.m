%This class will be used to create an interface type object such that data
%points can be added to the object, and the classification algorithm can be
%run in real-time. Run the task segmentation algorithm every time we
%receive a new data point

classdef dataSegment
    
    %We need an array of data points, with an associated array of time
    %stamps, and a count of the number of time stamps we have
    properties (SetAccess = private)
        %An array of time stamps
        T;
        %An array of data points
        X;
        %A count of how many time steps we have data from
        count;
        %Also, keep a copy of the thresholding matrix such that we do not
        %have to read it from file each time we wish to threshold
        TXV;
        %Keep a copy of the other parameters we must read from file such
        %that we need only read them once
        start;  taskLength; depth;
        ET;
        %Keep a copy of what the current and previous task are
        curr;   prev;
    end
    
    %We need to be able to add data to the object, and segment the
    %procedure into its task (in particular, determine what task is
    %currently being performed)
    methods
        
        %This constructor will create the object. We will already know the
        %number of degrees of freedom, but will not know how many data
        %points will be produced
        function S = dataSegment(depth,ET)
            %Assume that we have the regular 8 DOF variables
            S.count=0;
            S.T=zeros(1,1);
            S.X=zeros(8,1);
            
            %Create an organizer such that the data is written to the specified
            %location recorded in file
            o = Organizer();
            
            %Import the task thresholding data only once
            S.TXV=o.read('TP');
            %Also, import parameters specifying the plan
            S.depth = depth;
            %If the user does not specify an entry-target line, assume it
            %is along the x-axis
            if (nargin < 2)
                S.ET=[1 0 0]';
            else
                S.ET = ET;
            end
            %Initially, let the current and previous tasks be the first
            %task
            S.curr=1;
            S.prev=1;
        end
        
        %This function will be used to add a data point to the object,
        %noting that a transformation matrix will be provided rather than a
        %series of degrees of freedom including quaternions
        function S = addPoint(S,t,A)
            %First, create a local variable, and use this to store the
            %array of DOFs, which we have converted from the 4x4
            %transformation matrix
            x=matrixToDOF(A);
            %Now, add this data to the arrays kept in the object
            %First, increment the count of time stamps
            S.count = S.count + 1;
            %Now, assign the next time stamp to the array
            S.T(S.count) = t;
            %Finally, assign the dofs to the array of dofs
            S.X(:,S.count)=x;
            %Now, assign prev to what curr was
            S.prev=S.curr;
            %And calculate what the curr task is
            S.curr = thresholdSegmentRT(S.T,S.X,S.prev,S.depth,S.ET,S.TXV);
        end
        
        %This function will return the current task, given all of the
        %points that were previously added to the object
        function task = currentTask(S)
            %Use the task segmentation algorithm given the data stored in
            %this object
            task=S.curr;
        end
        
        %Alternatively, we can also allow the user to add a point and
        %request the current task at the same time (Although I don't
        %recommend it)
        function [S task] = addPointTask(S,t,A)
            %Call the add point method
            S = S.addPoint(S,t,A);
            %Call the current task method
            task = currentTask;
        end
        
        
    end
    
end