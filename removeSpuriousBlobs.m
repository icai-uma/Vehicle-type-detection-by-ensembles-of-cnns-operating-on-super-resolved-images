function [objetos, num_blobs] = removeSpuriousBlobs(objetos,tam_espurio)

if nargin < 3
    tam_espurio = 100;
end

s = regionprops(objetos, 'Area');
idxs = find([s.Area] > tam_espurio);
obj2 = zeros(size(objetos,1),size(objetos,2));
num_obj2 = 0;
for i=1:length(idxs) 
    Ob = (objetos == idxs(i));
    num_obj2 = num_obj2 + 1;
    obj2 = obj2 + Ob*num_obj2;
end

objetos = obj2;
num_blobs = num_obj2;
