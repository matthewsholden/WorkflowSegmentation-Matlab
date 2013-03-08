%This procedure will, given two KeyGenerator objects, create procedures of
%different key points ("skill-levels"), train the segmentation algorithm,
%segment them, produce a procedure with identical keypoints to one of the
%original procedures and correctly classify which procedure it resembles

%Parameter K: A cell array of KeyGenerator objects (representing different
%procedural skill-levels)
%Parameter itr: The number of training procedures for each skill-level of
%task

%Return skill: The classified skill-level at each test procedure
%Return prob: The probability the result was each skill-level for each test
%procedure
%Return tprob: The probability each task was at each skill-level for each
%test procedure
function [skill prob tprob] = classTrial(K,itr)

%Assume itr to be 1 unless otherwise specified
if (nargin < 2)
   itr = [1 1]; 
end

%We will need an organizer to delete the files for the test procedures we
%have created
o = Organizer();

%Delete any previous procedures that might still be in the relevant folder
o.deleteAll('Procedure');
o.deleteAll('Task');
o.deleteAll('Skill');

%First, iterate over all of the KeyGenerator objects and write them to file
for k=1:length(K)
    %Create the specified number of procedures by itr
    for i=1:itr(2)
        K{k}.writeProcedure(k);
    end
end

%Now, train the algorithm using the two training procedures we just
%generated
markovTrain();

%We need to initialize our matrices for storing the skill-level
%classification data in
skill = zeros(1,k);
prob = zeros(k,k);
tprob = zeros(k,k,calcMaxTask());

%Now, for each different KeyGenerator object, create a test procedure
%corresponding to the keypoints and test the classification algorithm on
%this test procedure
for k = 1:length(K)
 
    %Perform a subtrial over all the specified number of iterations
    prob = classSubtrial(itr);
    %Now, find the statistics of the classification
    probprod = prod(prob,2);
    %And find the most likely skill-level that the trainee has
    disp('Actual Skill-Level: ', num2str(k));
    disp('Predicted Skill-Level: ', num2str(k));
    
end

