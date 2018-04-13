
function assignment = testPossibleAssignments(M)
% Matrix M is a cost matrix for assigning cells from one frame to the next

% Confirm that M is a two-dimensional square matrix
assert(length(size(M)) == 2);
assert(diff(size(M)) == 0);

X = length(M);

%     Look at previously created list of unique assignments.
%     Go through each and find which one has the lowest summed cost.
all_unique_assignments = csvread(['C:\Users\Skotheim Lab\Desktop\Matlab-Scripts\Matlab_ilastik_tracking\UniqueAssignments_'...
    num2str(X) '.csv']);
num_unique_assignments = length(all_unique_assignments);
assert(num_unique_assignments == factorial(X));
sums = NaN(1,num_unique_assignments);
for i = 1:num_unique_assignments
    thistry_sum = 0;
    thisassignment = all_unique_assignments(i,:);
    for j = 1:X
        thistry_sum = thistry_sum + M(j, thisassignment(j));
    end
    sums(i) = thistry_sum;
end
[~,indices] = sort(sums);
best_i = indices(1);
assignment = all_unique_assignments(best_i,:);

end