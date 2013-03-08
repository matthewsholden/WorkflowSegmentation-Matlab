%This function will be used to add tensors of two different sizes by
%padding the smaller tensors with zeros on the bottom-right side to make
%the tensors the same size

%Parameter A: The first tensor being added
%Parameter B: The second tensor being added
%Parameter value: The value which will be used for padding. If the user
%doesn't specify anything, then assume value is zero

%Return C: The result of adding A and B with padding value
function C = padAdd(A,B,value)

%First, find the size of A and B
szA = size(A);
szB = size(B);

%If the dimensions are not equal, then assume the size of the matrices in
%the higher dimensions is one

%The dimension is the maximum size of the size of the tensors
dim = max(size(szA,2),size(szB,2));

%Now, for each dimension of the tensor, ensure that the size vectors cover
%the dimension
for d=1:dim
    %If we have a dimension then good, otherwise, create a dimension
    if (size(szA,2) < dim)
        szA(dim) = 1;
    end
    if (size(szB,2) < dim)
        szB(dim) = 1;
    end
end

%Good, now pad the tensors appropriate based on the sizes of the
%dimensions. Note that the sizes of the size vectors are now equal
diffA = szA - szB;
diffB = szB - szA;

%Now, pad each tensor appropriately
for d=1:dim
    %If the difference is non-zero then pad one of the arrays
   if (diffA(dim) > 0)
       %Create the pad vector
       padVector = zeros(size(szA));
       padVector(d) = diffA(d);
       %Pad the tensor
       B = padarray(B,padVector,'post');
   end
   
       %If the difference is non-zero then pad one of the arrays
   if (diffB(dim) > 0)
       %Create the pad vector
       padVector = zeros(size(szB));
       padVector(d) = diffB(d);
       %Pad the tensor
       A = padarray(A,padVector,'post');
   end
    
end

%Now that the tensors are appropriately padded we can add them
C = A + B;