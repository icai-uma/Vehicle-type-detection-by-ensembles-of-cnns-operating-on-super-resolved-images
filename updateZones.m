function model = updateZones(model,i)

% Media del tamaño de los objetos

objetos = model.blobs;
[model,asociados] = objetosPorZonas(model,objetos);

for k=1:length(asociados)
    idxs = asociados(k).idx;
    
    if ~isempty(idxs)
        areas = [objetos(idxs).Area];
        dim = [objetos(idxs).BoundingBox];
        dim = [dim(3:4:end); dim(4:4:end)]';

        media = mean(areas);
        mediaDim = mean(dim,1);

        if (length(areas) > 1)
            if ~isempty(model.zonas(k).MediaArea)
                varianza = sum((areas - model.zonas(k).MediaArea*ones(1,length(areas))).^2) / (length(areas) - 1);
                varianzaDim = sum((dim - (model.zonas(k).MediaDim'*ones(1,length(dim)))').^2) / (length(areas) - 1);
            else
                varianza = var(areas);
                varianzaDim = var(dim);
            end
        end

        if (i-model.Start) > model.Start
            factor = model.Start;
        else
            factor = (i-model.Start);
        end

        if ~isempty(model.zonas(k).MediaArea) && ~isnan(media)
            model.zonas(k).MediaArea = ((factor-1)/factor)*model.zonas(k).MediaArea + (1/factor)*media;
            model.zonas(k).MediaDim = ((factor-1)/factor)*model.zonas(k).MediaDim + (1/factor)*mediaDim;
        elseif ~isnan(media)
            model.zonas(k).MediaArea = media;
            model.zonas(k).MediaDim = mediaDim;
        end

        if (length(areas) > 1)
             if ~isempty(model.zonas(k).VarianzaArea)
                model.zonas(k).VarianzaArea = ((factor-1)/factor)*model.zonas(k).VarianzaArea + (1/factor)*varianza;
                model.zonas(k).VarianzaDim = ((factor-1)/factor)*model.zonas(k).VarianzaDim + (1/factor)*varianzaDim;
             else
                model.zonas(k).VarianzaArea = varianza;
                model.zonas(k).VarianzaDim = varianzaDim;
             end
        end
    end
end




