
function digits = convertToBaseX(num, X)
%Must be an integer num going to an integer base X

%Find how many digits we need
digits_required = 1;
while X^digits_required <= num
    digits_required = digits_required+1;
end
remainder = num;
for d = digits_required:-1:1
   digits(digits_required + 1 - d) = floor(remainder./X^(d-1));
   remainder = mod(remainder,X^(d-1));
end

end