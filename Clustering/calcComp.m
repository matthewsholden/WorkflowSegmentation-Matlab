%This function will calculate the number of components we should keep in a
%principal component analysis or a linear discriminant analysis be
%determining when the rate of decrease of eigenvalue corresponding to a
%component begins to increase

%Parameter evalue: A list of eigenvalues in desending order
%Parameter userComp: The user-specified number of components

%Return numComp: The actual number of components we shall use
function numComp = calcComp(evalue,userComp)

%The number of total possible dimensions is equal to the number of
%eigenvalues
dim = length(evalue);

%First, if the user has specified the number of components they want, then
%that is what they shall get
if (userComp > 0)
    numComp = userComp;
    return;
end

%Otherwise, check to see we the acceleration is negative

%Start the feature vector as just the first eigenvector, since this is
%guaranteed to be part of the feature vector
numComp = 1;

%We will choose a stopping rule such that we stop when the rate of
%eigenvalue decrease becomes positive (second derivative negative)

%Matlab automatically orders the eigenvectors in increasing eigenvalue and
%normalizes the eigenvectors, but note that we have flipped them
for k=2:(dim-1)
    %Calculate the concavity of the eigenvalues. If it is concave down then
    %stop.
    conc = evalue(k-1) - 2*evalue(k) + evalue(k+1);
    %Concatenate the feature vector with the eigenvector
    numComp = numComp + 1;
    %If it is concave down (the next one) then stop
    if ( conc < 0 || ~isreal(evalue(k+1)) )
        break;
    end
end