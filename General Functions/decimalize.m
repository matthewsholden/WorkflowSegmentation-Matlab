%This function will take a number and reduce it (by dividing by ten
%repeatedly) to a number that is completely a decimal

%Paramter init: An initial number we want reduced

%Return decimal: A number that is the completely decimal version of the
%initial number
function decimal = decimalize(init)

%If init is a decimal its magnitude is less than one (does not really make
%sense for complex numbers...)
if (abs(init) < 1)
    decimal = init;
else
    decimal = decimalize(init/10);
end