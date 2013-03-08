%This function will calculate the B-Y FDR for the significance level over a
%series of comparisons between two data sets

%Parameter a: The significance level required for one comparison
%Parameter m: The number of comparisons we are making

%Return bya: The B-Y corrected significance level
function bya = byfdr(a,m)

%Assign bya to be zero
bya = 0;

%Iterate over all values up to k
for i=1:m
   bya = bya + (1/i);
end

%Now, divide alpha by our sum
bya = a/bya;