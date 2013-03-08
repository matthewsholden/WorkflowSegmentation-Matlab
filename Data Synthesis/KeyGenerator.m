%This object will be used to generate the key points in a needle-based
%procedure based on the definitions of the tasks

classdef KeyGenerator
    
    %Keep track of the time stamps, the position at the time stamps and the
    %task at the time stamps
    properties (SetAccess = private)
        %The time at each key point
        T;
        %The position at each key point
        X;
        %The task which was just performed and ended at the key point
        K;
        %The definitions of the tasks
        TaskDef
        %A count of how many key points have been added to the object
        count;
    end
    
    
    methods
        
        %This constructor will create an object with an initial point
        function Key = KeyGenerator(x)
            %Initialize all of our matrices
            Key.T = zeros(1,1);
            Key.X = zeros(1,length(x));
            Key.K = zeros(1,1);
            Key.TaskDef = cell(1,5);
            
            %Initialize count to be one since we just added a point
            Key.count = 1;
            
            %Now, assign the specified point to the first element of X
            Key.X(1,:) = x;
            
            %Find the definitions of the tasks from the entry-target line
            Key = Key.defineTasks();
            
        end
        
        %This function will be used to add a key point to the list of key
        %points as defined by the task we wish to execute next
        function Key = addTask(Key,k,tasklength)
            %Noise will be added immediately to the task length
            tasklength = tasklength + addTimeNoise(k,tasklength);
            
            %Increment the count of tasks
            %For each case of task
            if ( task == 1 )
                Key = Key.addTask1(tasklength);
            elseif ( task == 2 )
                Key = Key.addTask2(tasklength);
            elseif ( task == 3 )
                Key = Key.addTask3(tasklength);
            elseif ( task == 4 )
                Key = Key.addTask4(tasklength);
            elseif ( task == 5 )
                Key = Key.addTask5(tasklength);
            else
                %If the task is not one of the tasks we have defined, then do
                %nothing, ensure we do not increment count
            end
            
        end
        
        %This function will read data from the ET file and from the
        %entry-target point will define each of the tasks
        function Key = defineTasks(Key)
            
            %Create an organizer such that the data is written to the specified
            %location recorded in file
            o = Organizer();
            %The the entry-target points from file
            ET = o.read('ET');
            %Now, separate into the entry and target points
            Entry = ET(:,1);
            Target = ET(:,2);
            
            %The first task
            Key.TaskDef{1} = [Entry', 0, 0, 0, 0, 0]';
            %The second task
            Key.TaskDef{2} = [Entry', vectorToQuat(Entry-Target,[1 0 0]'), 0]';
            %The third task
            Key.TaskDef{3} = [Target', vectorToQuat(Entry-Target,[1 0 0]'), 0]';
            %The fourth task
            Key.TaskDef{4} = [Target', vectorToQuat(Entry-Target,[1 0 0]'), 0]';
            %The fifth task
            Key.TaskDef{5} = [Entry', vectorToQuat(Entry-Target,[1 0 0]'), 0]';
            
        end
        
        %This function will add task 1 to the list of key points
        function Key = addTask1(Key,tasklength)
            %Increment the count of tasks
            Key.count = Key.count + 1;
            %Add the point to the point matrix
            Key.X(Key.count,:) = Key.TaskDef{1};
            %For the first task, the end point will take the same angle as
            %the previous key point
            Key.X(Key.count,4:7) = Key.X(Key.count-1,4:7);
            %Add the time to the time matrix
            Key.T(Key.count,1) = Key.T(Key.count-1,1) + tasklength;
            %Add the task completed to the task matrix
            Key.K(Key.count,1) = 1;
        end
        
        %This function will add task 2 to the list of key points
        function Key = addTask2(Key,tasklength)
            %Increment the count of tasks
            Key.count = Key.count + 1;
            %Add the point to the point matrix
            Key.X(Key.count,:) = Key.TaskDef{2};
            %Add the time to the time matrix
            Key.T(Key.count,1) = Key.T(Key.count-1,1) + tasklength;
            %Add the task completed to the task matrix
            Key.K(Key.count,1) = 2;
        end
        
        %This function will add task 3 to the list of key points
        function Key = addTask3(Key,tasklength)
            %Increment the count of tasks
            Key.count = Key.count + 1;
            %Add the point to the point matrix
            Key.X(Key.count,:) = Key.TaskDef{3};
            %Add the time to the time matrix
            Key.T(Key.count,1) = Key.T(Key.count-1,1) + tasklength;
            %Add the task completed to the task matrix
            Key.K(Key.count,1) = 3;
        end
        
        %This function will add task 4 to the list of key points
        function Key = addTask4(Key,tasklength)
            %Increment the count of tasks
            Key.count = Key.count + 1;
            %Add the point to the point matrix
            Key.X(Key.count,:) = Key.TaskDef{4};
            %Add the time to the time matrix
            Key.T(Key.count,1) = Key.T(Key.count-1,1) + tasklength;
            %Add the task completed to the task matrix
            Key.K(Key.count,1) = 4;
        end
        
        %This function will add task 5 to the list of key points
        function Key = addTask5(Key,tasklength)
            %Increment the count of tasks
            Key.count = Key.count + 1;
            %Add the point to the point matrix
            Key.X(Key.count,:) = Key.TaskDef{5};
            %Add the time to the time matrix
            Key.T(Key.count,1) = Key.T(Key.count-1,1) + tasklength;
            %Add the task completed to the task matrix
            Key.K(Key.count,1) = 5;
        end
        
        
        %This procedure will be responsible for writing the keypoint data
        %we have added to the KeyGenerator object to file
        function Key = write(Key)
            
            %Use the write key function we have previously implemented
            writeKey(Key);
            
        end
        
        %Let us also have a method for generating a synthetic procedure
        %from this set of key points
        function Key = writeRecord(Key)
            %The first thing we shall do is get the data generated by the 
            %synthetic data generator
            D=Synthetic(Key);
            
            %Now that we have constructed the procedure record from the 
            %keypoints, write the procedure to file
            writeRecord(D);
            
            clear D;
        end
        
        %This procedure will be responsible for reading the keypoint data
        %we have added to the KeyGenerator object from file, in case we
        %wish to append to it or use the keypoint data to generate a
        %procedural record
        function Key = read(Key,num)
            
            %Use the readKey function we have previously implemented
            [cellT cellX cellK] = readKey();
            
            %But we only want the key number specified by num
            Key.T = cellT{num};
            Key.X = cellX{num};
            Key.K = cellK{num};
            
            
            %Adjsut the count of keypoints
            Key.count = size(Key.X,1);
            
        end
        
        
        
    end
    
    
end