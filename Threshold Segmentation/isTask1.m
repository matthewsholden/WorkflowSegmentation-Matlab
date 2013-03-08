%This function determines whether or not task 1 is being executed

%Parameter x: A vector of values in each degree of freedom
%Parameter v: A vector of veclocities in each degree of freedom
%Parameter t: The threshold value for the task
%Parameter in: Whether or not the needle was within the phantom in the
%previous task
%Parameter Entry: The coordinates of the entry point of the plan
%Parameter Target: The coordinates of the target point of the plan

%Return Task: A boolean valued scalar indicating whether or not this task
%is being executed
function Task = isTask1(x,v,t,in,Entry,Target)

%Task 1: Needle outside, not within some threshold distance to entry point

%Assign the task to be false, and return if one of the conditions is not
%satisfied, otherwise, return true
Task = false;

%Calculate the plane defining the surface of the skin
D = norm(Entry-Target);
n = (Entry - Target)/D;

%Now, we determine
%1. Is the needle outside the plane of the phantom?
%Note that the skin of the phantom has finite thickness
if (in == false)
    if ( dot(x(1:3),n) < (D - t(1)) )
        return;
    end
else
    if ( dot(x(1:3),n) < (D + t(1)) )
        return;
    end
end


%2. Is the needle close to the entry point and adjusting the insertion angle?
if ( norm(x(1:3) - Entry) < t(2) && norm( v(4:7) ) > t(3) )
    return;
end

%Otherwise, task=true
Task=true;