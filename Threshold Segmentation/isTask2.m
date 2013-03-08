%This function determines whether or not task 2 is being executed

%Parameter x: A vector of values in each degree of freedom
%Parameter v: A vector of veclocities in each degree of freedom
%Parameter t: The threshold value for the task
%Parameter in: Whether or not the needle was within the phantom in the
%previous task
%Parameter ET: The referece vector for the entry-target line

%Return task: A boolean valued scalar indicating whether or not this task
%is being executed
function task = isTask2(x,v,t,in,ET)

%Task 2: Needle outside, within some threshold distance to entry point,
%needle pivoting about entry point

%Assign the task to be false, and return if one of the conditions is not
%satisfied, otherwise, return true
task=false;

%Now, we determine
%1. Is the needle outside the plane of the phantom?
%Note that the skin of the phantom has finite thickness
if (in == false)
    if (dot(x(1:3),ET)/norm(ET) < (norm(ET)-t(1)))
        return;
    end
else
    if (dot(x(1:3),ET)/norm(ET) < (norm(ET)+t(1)))
        return;
    end
end

%2. Is the needle close to the entry point?
if (norm(x(1:3)-ET) > t(2))
    return;
end

%3. Is the needle pivoting?
if (norm(v(4:7)) < t(3))
    return;
end

%Otherwise, task=true
task=true;