%This function will produce the results for the trials we have not yet
%accomplished...

%Parameter type: The type of noise we would like to try
%Parameter p: The power of noise we would like to try
%Parameter K: The key generator object corresponding to the procedure we
%want generated
%Parameter itr: The number of iterations over which we shall average

%Return status: Whether or not we have completed the function
function acc = segmentSubtrial(type,p,K,itr)

%create an organizer object for reading/writing files
o = Organizer();

%Delete all of the procedures and tasks at the beginning
o.deleteAll('Procedure');
o.deleteAll('Task');
o.deleteAll('Skill');

%Use a count of how many points of data we have calculated segmentation for
count = 0;
%Initialize our vector of accuracies
acc = zeros(2,itr(1));

%Reset the noise to zero for all parameters
newParam('X_Bs',[8 5 1],0);
newParam('X_Wt',[8 5 1],0);
newParam('X_Mx',[8 5 1],1);

%We shall even reset the time noise parameters
newParam('T_Bs',[1 5 1],0);
newParam('T_Wt',[1 5 1],0);
newParam('T_Mx',[1 5 1],1);

%The actual noise
e = 10^p;
%Set the noise

if (strcmp(type,'X_Bs_Tr'))
    %Over all translational dofs
    for i=1:3
        %For all tasks
        for j=1:5
            setParam('X_Bs',[i j 1],e);
        end
    end
end
if (strcmp(type,'X_Wt_Tr'))
    %Over all translational dofs
    for i=1:3
        %For all tasks
        for j=1:5
            setParam('X_Wt',[i j 1],e);
        end
    end
end
if (strcmp(type,'X_Bs_Ro'))
    %Over all rotational dofs
    for i=4:7
        %For all tasks
        for j=1:5
            setParam('X_Bs',[i j 1],e);
        end
    end
end
if (strcmp(type,'X_Wt_Ro'))
    %Over all rotational dofs
    for i=4:7
        %For all tasks
        for j=1:5
            setParam('X_Wt',[i j 1],e);
        end
    end
end



while (count < itr(1))
    
    %Increment count
    count = count + 1;
    
%     %First, the threshold algorithm!
%     
%     %Write the data to file
%     K.writeProcedure(0);
%     %Perform the segmentation using the threshold algorithm
%     KC = thresholdSegmentOptimize(1,itr(2));
%     
%     %Return the accuracy of the segmentation
%     disp(['   Count ', num2str(count), ' (Threshold): ', num2str(segmentAccuracy(1,KC)) ])
%     acc(1,count) = segmentAccuracy(1,KC);
%     
%     %Delete all of the procedural records
%     o.deleteAll('Procedure');
%     o.deleteAll('Task');
%     o.deleteAll('Skill');
    
    
    
    %Second, the Markov algorithm!
    
    %Produce our training data
    for i=1:itr(2)
        K.writeRecord();
    end
    
    %Train our markov model parameters using the training data
    markovTrain();
    
    %Produce the test procedure
    K.writeRecord();
    
    %Perform task segmentation on test procedure
    M = markovSegment(itr(2)+1);
    
    %Return the accuracy of the segmentation
    disp(['   Count ', num2str(count), ' (Markov): ', num2str(segmentAccuracy(itr(2)+1,M.KC)) ])
    acc(2,count) = segmentAccuracy(itr(2)+1,M.KC);
    
    %Delete all of the procedural records
    o.deleteAll('Procedure');
    o.deleteAll('Task');
    o.deleteAll('Skill');
    
end


%Reset the noise parameters
if (strcmp(type,'X_Bs_Tr') || strcmp(type,'X_Bs_Ro'))
    newParam('X_Bs',[8 5 1],0);
end
if (strcmp(type,'X_Wt_Tr') || strcmp(type,'X_Wt_Ro'))
    newParam('X_Wt',[8 5 1],0);
end
