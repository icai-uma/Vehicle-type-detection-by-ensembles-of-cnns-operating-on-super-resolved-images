function model = detectUnusualObjects(model)

objetos = model.blobs;
cont = 1;
for k=1:length(objetos)
    id = IDZona(model,objetos(k).Centroid);
    area = objetos(k).Area;
    res = 1;
    if ~isempty(model.zonas(id).MediaArea) && ~isempty(model.zonas(id).VarianzaArea)
        res = abs(area - model.zonas(id).MediaArea) <= 2.5*sqrt(model.zonas(id).VarianzaArea);
    end
    
    if res
        L(cont) = objetos(k);
        cont = cont + 1;
    else
        % Que hacer cuando el objeto no esta en la distribucion
        objetos(k).posibleError = 1;
    end
end

model.blobs = objetos;

model.coloredImage = object2doubleImage(model.blobs, model.FrameSize);