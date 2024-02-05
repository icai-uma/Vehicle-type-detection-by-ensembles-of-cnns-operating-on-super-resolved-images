function L = splitObjects2(model, objetos, label)

cont = 1;
for k=1:length(objetos)
    id = IDZona(model,objetos(k).Centroid);
    area = objetos(k).Area;
    res = 1;
    if ~isempty(model.zonas(id).MediaArea) && ~isempty(model.zonas(id).VarianzaArea)
        res = (area - model.zonas(id).MediaArea) <= 2.5*sqrt(model.zonas(id).VarianzaArea);
    end
    
    if res
        L(cont) = objetos(k);
        cont = cont + 1;
    else
        % Que hacer cuando el objeto no esta en la distribucion
        obj = (label == k);
        D = bwdist(~obj);
        D = -D;
        D(~obj) = -Inf;
        Lnew = watershed(D);    
        Lnew2 = abs(Lnew - 1);
        num_objetos = max(max(Lnew2));
        if (num_objetos > 1)
            disp(['Se ha producido un split en el objeto ' num2str(k)]);
            obj_splits = extractObjects(Lnew2);
            ID_maximo = max([objetos.ID])+1;
            for j=1:length(obj_splits)
                obj_splits(j).ID = ID_maximo;
                L(cont) = obj_splits(j);
                cont = cont + 1;
                ID_maximo = ID_maximo + 1;
            end
        else
            L(cont) = objetos(k);
        end
        
    end
end

