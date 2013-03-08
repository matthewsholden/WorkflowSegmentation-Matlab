%This function determines whether or not task 4 is being executed

%Parameter x: A vector of values in each degree of freedom
%Parameter v: A vector of veclocities in each degree of freedom
%Parameter t: The threshold value for the task
%Parameter in: Whether or not the needle was within the phantom in the
%previous task
%Parameter ET: The referece vector for the entry-target line

%Return task: A boolean valued scalar indicating whether or not this task
%is being executed
function task = isTask4(x,v,t,in,ET)

%Task 4: Needle inside, velocity in the ET below some threshold in abs
%value

%Assign the task to be false, and return if one of the conditions is not
%satisfied, otherwise, return true
task=false;

%Now, we must determine:
%1. Is the needle in the phantom?
%Note that the skin has finite thickness
if (in == true)
    if (dot(x(1:3),ET)/norm(ET) > (norm(ET)+t(1)))
        return;
    end
else
    if (dot(x(1:3),ET)/norm(ET) > (norm(ET)-t(1)))
        return;
    end
end

%2. Is the velocity of the needle in the -ET direction below some threshold
if (abs(dot(v(1:3),ET)/norm(ET)) > t(3))
   return; 
end

%Otherwise, task=true
task=true;