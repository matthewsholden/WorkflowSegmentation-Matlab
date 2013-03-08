%This function determines whether or not task 4 is being executed

%Parameter x: A vector of values in each degree of freedom
%Parameter v: A vector of veclocities in each degree of freedom
%Parameter t: The threshold value for the task
%Parameter in: Whether or not the needle was within the phantom in the
%previous task
%Parameter Entry: The coordinates of the entry point of the plan
%Parameter Target: The coordinates of the target point of the plan

%Return task: A boolean valued scalar indicating whether or not this task
%is being executed
function Task = isTask4(x,v,t,in,Entry,Target)

%Task 4: Needle inside, velocity in the ET below some threshold in abs
%value

%Assign the task to be false, and return if one of the conditions is not
%satisfied, otherwise, return true
Task = false;

%Calculate the plane defining the surface of the skin
D = norm(Entry-Target);
n = (Entry - Target)/D;

%Now, we must determine:
%1. Is the needle in the phantom?
%Note that the skin has finite thickness
if (in == true)
    if ( dot(x(1:3),n) > (D + t(1)) )
        return;
    end
else
    if ( dot(x(1:3),n) > (D - t(1)) )
        return;
    end
end

%2. Is the velocity of the needle in the -ET direction below some threshold
if ( abs( dot(v(1:3),n) ) > t(3) )
   return; 
end

%Otherwise, task=true
Task = true;