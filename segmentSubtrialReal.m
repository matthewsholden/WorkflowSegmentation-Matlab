%This function will produce the results for the trials we have not yet
%accomplished...

%Parameter type: The type of noise we would like to try
%Parameter p: The power of noise we would like to try
%Parameter K: The key generator object corresponding to the procedure we
%want generated
%Parameter itr: The number of iterations over which we shall average

%Return status: Whether or not we have completed the function
function acc = segmentSubtrialReal(procType,virtual,lumbarJoint,itr)

%create an organizer object for reading/writing files
o = Organizer();

%Delete all of the procedures and tasks at the beginning
o.deleteAll('Procedure');
o.deleteAll('Task');
o.deleteAll('Skill');

%Read the set of all procedures from file for the particular group under
%the particular type of procedure
Subjects = o.read([virtual, 'Subjects']);
%Determine the total number of subjects we are considering
subjNum = round(length(Subjects)/3);

%Initialize our vector of accuracies
acc = zeros(2,length(Subjects)/3);

%NOTE: K = 295 is a good parameter for the Markov Model. This is good! That
%means we get a total of 300 clusters when we add the end of task clusters.
%This yields an average of subjNum points per cluster (approx)

%First, write all of our data to file, except the first procedure
for i=2:subjNum
    xmlToRecord(Subjects(i),procType,virtual,lumbarJoint);
end

%Iterate over all subjects (leave-one-out method)
for subj = 1:subjNum
    
    %Now, train the Markov model algorithm
    markovTrain();
    
    %Write the test procedure to file
    xmlToRecord(Subjects(subj),procType,virtual,lumbarJoint);
    
    %Perform a Markov Model task segmentation on the test procedure
    MD = markovSegment(subjNum);
    
    
    %For thre threshold algorithm, let's optimize the over the
    %user-specified number of iterations
    %KC = thresholdSegmentOptimize(subjNum,itr);
    
    
    %Now, we shall write the data we have acquired to the screen and
    %store it in an array
    %disp(['   Subject ', num2str(Subjects(subj)), ' (Threshold): ', num2str(segmentAccuracy(subjNum,KC)) ])
    %acc(1,subj) = segmentAccuracy(subjNum,KC);
    
    disp(['   Subject ', num2str(Subjects(subj)), ' (Markov): ', num2str(segmentAccuracy(subjNum,MD.DK.X)) ])
    acc(2,subj) = segmentAccuracy(subjNum,MD.DK.X);
    
    %Delete the testing procedure data
    o.deleteNum('Procedure',subjNum);
    o.deleteNum('Task',subjNum);
    o.deleteNum('Skill',subjNum);
    
    %Delete the subjth procedural record
    o.deleteNum('Procedure',subj);
    o.deleteNum('Task',subj);
    o.deleteNum('Skill',subj);
    
    %Read the current procedure from file
    xmlToRecord(Subjects(subj),procType,virtual,lumbarJoint);
    
    %Clear the MarkovData object
    clear MD;
    
end

%Clear the organizer object
clear o;
