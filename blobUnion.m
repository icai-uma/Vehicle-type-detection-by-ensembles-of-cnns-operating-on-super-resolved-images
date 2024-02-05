function [objetos, num_blobs] = blobUnion(L, num_obj)

s  = regionprops(L, 'BoundingBox','ConvexHull', 'Centroid', 'Area');

num_obj_ant = 0;
while (num_obj_ant ~= num_obj)
    num_obj_ant = num_obj;

    for i=1:num_obj
        cnx = blobUnido2(s(i), s(i+1:end));
        cnx = cnx + i;
        if ~isempty(cnx)
            [L,num_obj] = reasignar(L, [i cnx]);
            s  = regionprops(L, 'BoundingBox','ConvexHull', 'Centroid','Area');
            break;
        end
    end
%    L = L1;
end

objetos = L;
num_blobs = num_obj;
