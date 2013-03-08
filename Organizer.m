%This object will be responsible for organizing the reading and writing of
%data into files

classdef Organizer
    
    %The only property required here is the rootPath of the thing which we are
    %organizing
    properties (SetAccess = private)
        %The rootpath of the thing we are organizing (and also the root
        %directory for this thing)
        rootPath;
        %The name of the parameter
        paramName;
        %The location in which the parameter is stored
        pathName;
        %Also, keep track of overwriting, that is, when we write to a file
        %should we overwrite a previously written file or not overwrite a
        %previously written file
        overwrite;
    end
    
    
    methods
        
        %This constructor will create an object with a name
        function O = Organizer()
            %Read from file the rootPath. In this case we will use a file
            %read because we are reading a string
            data = filereadn('Organizer');
            
            %Take the root path
            O.rootPath = data{1};
           
            %Count the data point number
            count = 0;
            %Keep track of our position in the file
            pos = 2;
            %Go through all element of the data
            while (pos < length(data))
                %Increment the count
                count = count + 1;
                %Take the parameter name off
                O.paramName{count}=data{pos};
                pos = pos + 1;
                %Take the path of the parameter off
                O.pathName{count}=data{pos};
                pos = pos + 1;
                %Take the overwriting procedure off
                O.overwrite{count}=data{pos};
                pos = pos + 1;
            end
            
            %Ensure that recycling is turned off
            recycle off;
                     
        end
        
        %This function will be used to read from a file specified by the
        %following catgeorization, where pathArray is a cell array of
        %strings specifying the data we wish to read
        function data = read(O,paramName)
            %Create an initial string with the rootPath in it
            filePath = O.rootPath;
            %The index corresponding to the parameter
            ix = O.search(paramName);
            %Append pathName to the path array to the root path with a
            %slash        
            filePath = [ filePath, '/', O.pathName{ix} ];
            %Now use the dlmreadn function
            data = dlmreadn(filePath);
        end
        
        %This function will read data from all files specified by the
        %categrorization if they have differing numbers
        function data = readAll(O,paramName)
            %Create an initial string with the rootPath in it
            filePath = O.rootPath;
            %The index corresponding to the parameter
            ix = O.search(paramName);
            %Append pathName to the path array to the root path with a
            %slash
            origPath = [ filePath, '/', O.pathName{ix} ];
            %Assign the count to be one
            count = 1;
            %Now, create the first path name
            filePath = [origPath, num2str(count)];
            while ( exist(filePath,'file') )
                %Read from the file
                data{count} = dlmreadn(filePath);
                %Increase the count
                count = count + 1;
                %Append the count to the original file name
                filePath = [origPath, num2str(count)];
            end
        end
        
        %This function will read data from the file specified by the
        %categroization and number
        function data = readNum(O,paramName,num)
            %Create a string representing the path to the file we wish to
            %write
            %Create an initial string with the rootPath in it
            filePath = O.rootPath;
            %The index corresponding to the parameter
            ix = O.search(paramName);
            %Append pathName to the path array to the root path with a
            %slash
            filePath = [ filePath, '/', O.pathName{ix}, num2str(num) ];
            %Read from the file
            data = dlmreadn(filePath);
        end
        
        %We shall implement delete functions to delete the specified
        %parameter files. These will have the exact same structure as the
        %reading methods except the files will be deleted rather than read
        function O = delete(O,paramName)
            %Create an initial string with the rootPath in it
            filePath = O.rootPath;
            %The index corresponding to the parameter
            ix = O.search(paramName);
            %Append pathName to the path array to the root path with a
            %slash        
            filePath = [ filePath, '/', O.pathName{ix} ];
            %Now use the delete function
            delete(filePath);
        end
        
        %Delete all of the specified file of this parameter type
        function O = deleteAll(O,paramName)
            %Create an initial string with the rootPath in it
            filePath = O.rootPath;
            %The index corresponding to the parameter
            ix = O.search(paramName);
            %Append pathName to the path array to the root path with a
            %slash
            origPath = [ filePath, '/', O.pathName{ix} ];
            %Assign the count to be one
            count = 1;
            %Now, create the first path name
            filePath = [origPath, num2str(count)];
            while ( exist(filePath,'file') )
                %Delete the file. Make sure recycling is off, otherwise
                %this will clog up the memory...
                delete(filePath);
                %Increase the count
                count = count + 1;
                %Append the count to the original file name
                filePath = [origPath, num2str(count)];
            end
        end
        
        %This function will delete files specified by the
        %categroization and number
        function O = deleteNum(O,paramName,num)
            %Create an initial string with the rootPath in it
            filePath = O.rootPath;
            %The index corresponding to the parameter
            ix = O.search(paramName);
            %Append pathName to the path array to the root path with a
            %slash
            filePath = [ filePath, '/', O.pathName{ix}, num2str(num) ];
            %Read from the file
            delete(filePath);
        end
        
        
        
        %This function will be used to write to a file specified by the
        %following catgeorization, where pathArray is a cell array of
        %strings specifying the data we wish to write and data is the
        %tensor of data which we wish to write to file
        function status = write(O,paramName,data)
            %Create an initial string with the rootPath in it
            filePath = O.rootPath;
            %The index corresponding to the parameter
            ix = O.search(paramName);
            %Append pathName to the path array to the root path with a
            %slash
            filePath = [ filePath, '/', O.pathName{ix} ];
            filePath = O.newPath(filePath,O.overwrite{ix});
            %Now use the dlmrwriten function
            status = dlmwriten(filePath,data,'\t');
        end
        
        %This function will be used to write to a file specified by the
        %following catgeorization, where pathArray is a cell array of
        %strings specifying the data we wish to write and data is the
        %tensor of data which we wish to write to file
        function status = writeCell(O,paramName,data)
            %If it was previously overwrite, then delete all entries prior
            %to adding the new ones
            if ( strcmp(O.overwrite{O.search(paramName)},'Overwrite') )
               O.deleteAll(paramName); 
            end
            %Let the overwrite option on this be temporarily suspended
            O.overwrite{O.search(paramName)} = 'Insert';
            %Iteratively call the write function for each element of the
            %cell array
            for i = 1:numel(data)
                status = O.write(paramName,data{i});
            end
        end
        
        
        %This function is used to compute the index given an inputted
        %parameter name
        function ix = search(O,paramName)
            %Iterate through all parameters
            for i=1:length(O.paramName)
                %Test for equivalence
                %If they match them we have found what we are looking for
                if (strcmp(paramName,O.paramName{i}))
                    ix = i;
                    continue;
                end
            end
        end
        
        %This function will be used to choose a file path which has not
        %already been written to
        function filePath = newPath(O,origPath,over)
            %If the overwriting is not on, then just return the original file
            %name we wanted to write to in the first place
            if ( strcmp(over,'Overwrite') )
                filePath = origPath;
                return;
            end
            
            count = 1;
            %We will test a path by appending a number to the end of the
            %origPath and seeing if such a file already exists
            filePath = [origPath, num2str(count)];
            %We will let the original have a one at the end rather than
            %having nothing at the end
            %Go through all numbers and append this number to the file if the
            %file has already been written to
            while ( exist(filePath,'file') )
                %Increase the count
                count = count + 1;
                %Append the count to the original file name
                filePath = [origPath, num2str(count)];
            end
        end
        
    end
    
    
end