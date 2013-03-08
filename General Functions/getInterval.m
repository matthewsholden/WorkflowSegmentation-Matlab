%Given a set of key times corresponding to the key points, we will calculate
%the interval index in which the time of interest lies

%Parameters: Vector of key times, time of interest
%Return: The interval index in which our time of interest lies
function ki = getInterval(kt,ti)

%Calculate the number of key points we have
kn = length(kt);
ki=0;

%First, calculate the interval in which we lie
%Just use a linear search of kt to find the times between which the point
%lies
%i will be the interval number in which the point of interest resides
for j=1:(kn-1)
    %If we are between the current and next point then this is the interval
    %index the point resides in and we will use for the spline
    if ( ti >= kt(j) && ti <= kt(j+1) )
        ki=j;
    end
    
end


%Altermatively, we we do not lie in the range, assume that we are in
%one of the end intervals because the lack of range lying might be due
%to rounding error
if ( ti < kt(1) )
    ki=1;
end

if ( ti > kt(kn) )
    ki = kn-1;
end