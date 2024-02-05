function [Lt,num_obj] = reasignar(L, indices)

tot = 1:max(max(L));
L1 = zeros(size(L,1), size(L,2));
for i=1:length(indices)
    R = L == indices(i);
    L1 = L1 + R;
    tot(tot == indices(i)) = 0;
    L(L == indices(i)) = 0;    
end

quedan = nonzeros(tot)';

for i=1:length(quedan)
    L(L == quedan(i)) = i;    
end

num_obj = length(quedan) + 1;
Lt = L + L1.*num_obj;

