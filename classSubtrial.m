%This function will perform a specified number of subtrials for the
%classification of skill-levels using a user-specified number of
%skill-levels

%Parameter itr: The number of iterations of skill-level classification we
%wish to perform

%Parameter skill: The predicted skill-level of the procedure(s)
%Parameter prob: The probability of the performer being of each skill-level
function prob = classSubtrial(K,itr)

%Iterate over the specified number of iterations
for i=1:itr(1)
    
    %Create the test procedure
    K{k}.writeProcedure(0);
    %Now, perform the segmentation procedure using this most recently
    %writtern procedure as the test. Note that the number of this procedure
    %is length(K)+1 always
    M = markovSegment(itr(2)*length(K)+1);
    
    %Now, determine the skill-level classification of this segmentation
    %algorithm, and the corresponding probabilities
    [s p tp] = M.skillClassify();
    
    %Add this data to the overall matrices containing the skill-level
    %classification data
    prob(k,:) = p;
    
    %Delete the test procedure we just created
    o.deleteNum('Procedure',itr(2)*length(K)+1);
    o.deleteNum('Task',itr(2)*length(K)+1);
    o.deleteNum('Skill',itr(2)*length(K)+1);
    
end