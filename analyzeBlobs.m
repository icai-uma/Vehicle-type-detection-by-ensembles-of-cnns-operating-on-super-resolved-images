function postModel = analyzeBlobs(postModel)

tam = postModel.FrameSize;

for k=1:length(postModel.blobs)
    % Apaño para que los objetos tengan identificador
    postModel.blobs(k).ID = k;
    postModel.blobs(k).posibleError = 0;
    
    if ~isempty(postModel.map)
        limites = round(postModel.blobs(k).BoundingBox);
        
        if (limites(1) > 1) && ((limites(1)+limites(3)) < tam(1)) && ...
           (limites(2) > 1) && ((limites(2)+limites(4)) < tam(2))

            dim_incorrectas = sum(abs(postModel.map.mean_dim - limites(3:4)) > 2.*postModel.map.std_dim);
%            prop_incorrecta = abs(mapa.media_prop - (limites(3)/limites(4))) > 2.*mapa.std_prop; 
            c = round( postModel.blobs(k).Centroid);
            if ((c(1) > 1) && (c(1) < tam(1))) && ((c(2) > 1) && (c(2) < tam(2)))
                ventana =  postModel.map.trayectories(c(2)-1:c(2)+1,c(1)-1:c(1)+1);
                pixel_trayectoria = nnz(ventana > 0) > 5;
            end

            if abs(postModel.map.mean_dim(2) - limites(4)) > 3*postModel.map.std_dim(2)
            %if prop_incorrecta && (dim_incorrectas > 0)
                 postModel.blobs(k).posibleError = 1;
            elseif (dim_incorrectas > 0 && (~pixel_trayectoria))
                 postModel.blobs(k).posibleError = 1;
            end
        end
    end
    
end