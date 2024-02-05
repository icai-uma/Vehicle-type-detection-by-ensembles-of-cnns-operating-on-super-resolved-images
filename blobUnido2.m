function cnx = blobUnido2(blob, resto)

global zonas;
% Area persona = 5000
% Area coche = 350


DISTANCIA_OBJETO = 5;
AREA_OBJETO_BLOB = 5000;
AREA_OBJETO_RESTO = 5000;
temp = blob.ConvexHull;
areaBlob = blob.Area;

% Busco la zona a la que pertenece el objeto
if ~isempty(zonas)
    id = IDZona(blob.Centroid);
    if ~isempty(zonas(id).MediaArea)
        AREA_OBJETO_BLOB = 0.4*zonas(id).MediaArea;
    end
end
pto = temp;
% pto(1,:) = [temp(1) temp(2)];
% pto(2,:) = [temp(1)+temp(3) temp(2)];
% pto(3,:) = [temp(1) temp(2)+temp(4)];
% pto(4,:) = [temp(1)+temp(3) temp(2)+temp(4)];


cnx = [];
num_cnx = 0;
for i=1:length(resto)
    temp = resto(i).ConvexHull;
    areaR = resto(i).Area;
    
    % Busco la zona a la que pertenece el objeto
    if ~isempty(zonas)
        id = IDZona(resto(i).Centroid);
        if ~isempty(zonas(id).MediaArea)
            AREA_OBJETO_RESTO = 0.4*zonas(id).MediaArea;
        end
    end
    
    if ((areaBlob < AREA_OBJETO_BLOB) || (areaR < AREA_OBJETO_RESTO))
        pto2 = temp;
%         pto2(1,:) = [temp(1) temp(2)];
%         pto2(2,:) = [temp(1)+temp(3) temp(2)];
%         pto2(3,:) = [temp(1) temp(2)+temp(4)];
%         pto2(4,:) = [temp(1)+temp(3) temp(2)+temp(4)];

        for j=1:size(pto,1)
            d = sqrt(sum([(pto(j,1)-pto2(:,1)).^2 (pto(j,2)-pto2(:,2)).^2],2));
            if any(d < DISTANCIA_OBJETO)
                num_cnx = num_cnx + 1;
                cnx(num_cnx) = i;  
                break;
            end
        end
    end
end
