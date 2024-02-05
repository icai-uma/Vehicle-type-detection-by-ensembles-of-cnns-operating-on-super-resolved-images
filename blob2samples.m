function [currentSamples, idxBlobs] = blob2samples(postModel)

tam = postModel.FrameSize;
currentSamples = [];
idxBlobs = [];

cont = 1;
for k=1:length(postModel.blobs)
    
    limites = round(postModel.blobs(k).BoundingBox);

    if ~isempty(limites) && (limites(1) > 1) && ((limites(1)+limites(3)) < tam(1)) && ...
       (limites(2) > 1) && ((limites(2)+limites(4)) < tam(2))
        
        currentSamples(1:2,cont) = postModel.blobs(k).Centroid;
        
        % Normalizamos los datos en función de la media de las entradas 
        if isfield(postModel.SOFM, 'GlobalMu')
            currentSamples(3,cont) = (postModel.blobs(k).Area - postModel.SOFM.GlobalMu(3)) ./ postModel.SOFM.GlobalDesv(3);
            currentSamples(4:5,cont) = (limites(3:4) - postModel.SOFM.GlobalMu(4:5)') ./ postModel.SOFM.GlobalDesv(4:5)';
            a = 1;
        else
            currentSamples(3,cont) = postModel.blobs(k).Area;
            currentSamples(4:5,cont) = limites(3:4);
        end
        currentSamples(6,cont) = postModel.blobs(k).Orientation;
        idxBlobs(cont) = k;
        cont = cont + 1;
    end

end