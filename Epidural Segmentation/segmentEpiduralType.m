%Segment the procedures from the epidural procedures using the automatic
%segmentation algorithm

%Parameter skill: A string indicating skill (ie Novice, Expert)
%Parameter procName: The name of the procedure (ie TR, TL, CR, CL)

%Return status: Whether or not we have completed the function
function acc = segmentEpiduralType(skill,technique)

%create an organizer object for reading/writing files
o = Organizer();

%Delete all of the procedures and tasks at the beginning
o.deleteAll('Procedure');
o.deleteAll('Task');
o.deleteAll('Skill');


%Get the segmentation subjects and trials
procMatrix = o.read([skill, ' ', technique]);
trialMatrix = procMatrix(:,2:end)';
subjMatrix = bsxfun(@times,~~trialMatrix,procMatrix(:,1)');
%Convert these into appropriate arrays
trialArray = trialMatrix(~~trialMatrix);
subjArray = subjMatrix(~~subjMatrix);
subjNum = length(subjArray);

%NOTE: K = 295 is a good parameter for the Markov Model. This is good! That
%means we get a total of 300 clusters when we add the end of task clusters.

%First, write all of our data to file, except the first procedure
for i=2:subjNum
    NDITrackToRecord(subjArray(i),['Trial',num2str(trialArray(i))],skill,technique);
end

disp('Procedure files created');

%Iterate over all subjects (leave-one-out method)
for subj = 1:subjNum
    
    %Now, train the Markov model algorithm
    markovTrain();
    
    disp('Algorithm trained');
    
    %Write the test procedure to file
    NDITrackToRecord(subjArray(subj),['Trial',num2str(trialArray(subj))],skill,technique);
    
    disp('Test procedure file created');
    
    %Perform a Markov Model task segmentation on the test procedure
    MD = markovSegment(subjNum);
    
    disp('Procedure segmented');

    %Now, we shall write the data we have acquired to the screen and
    %store it in an array
    disp(['   Subject ', num2str(subjArray(subj)), ' (Markov): ', num2str(segmentAccuracy(subjNum,MD.DK.X)) ])
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
    NDITrackToRecord(subjArray(subj),['Trial',num2str(trialArray(subj))],skill,technique);
    
    disp('Training procedures organized');
    
    %Clear the MarkovData object
    clear MD;
    
end

%Clear the organizer object
clear o;
