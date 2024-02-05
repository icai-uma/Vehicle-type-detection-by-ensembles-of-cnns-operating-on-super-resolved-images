function [model, splitted] = splitObjects_new(model, idxFrame, Winners,idxBlobs)

splitted = 0;
NumRowsMap = model.SOFM.NumRowsMap;
NumColsMap = model.SOFM.NumColsMap;
LIMITE_FRONTERA = 0.6;

objetos = model.blobs;
mask = model.cleanMask;

if ~isempty(objetos)
    idxs = find([objetos.posibleError]);

    for k=1:length(idxs)
        ob = objetos(idxs(k));

        [NdxRow,NdxCol] = ind2sub([NumRowsMap NumColsMap],Winners(find(idxBlobs == idxs(k))));
        areaNeuron = model.SOFM.Prototypes(3,NdxRow,NdxCol) * model.SOFM.GlobalDesv(3) + model.SOFM.GlobalMu(3);

        if ob.Area > areaNeuron 
            x_ini = round(ob.BoundingBox(1));
            y_ini = round(ob.BoundingBox(2));
            x_fin = round(ob.BoundingBox(1) + ob.BoundingBox(3));
            y_fin = round(ob.BoundingBox(2) + ob.BoundingBox(4));

            I = model.imMask_prob(y_ini:y_fin,x_ini:x_fin);
            I = 1 - I;

            [propFrontera,IOut,handle] = corteCoches(I,model);
            if propFrontera < LIMITE_FRONTERA
                %nonzeros(unique(model.cleanMask(y_ini:y_fin,x_ini:x_fin)))

                imgTemp = zeros(size(model.cleanMask));
                imgTemp(y_ini:y_fin,x_ini:x_fin) = IOut;
                blobsToAdd = extractObjects(imgTemp); 

                maxID_blobs = max([model.blobs.ID]) + 1;
                maxID = max(max(model.cleanMask)) + 1;

                numObjects = length(blobsToAdd);
                % TEMP
                colores = [0.1255 0 1; 0 1 0.6235];
                %
                for i=1:numObjects
                    IOut(IOut == i) = maxID;
                    blobsToAdd(i).ID = maxID_blobs;
                    blobsToAdd(i).splitted = 1;
                    maxID = maxID + 1;
                    maxID_blobs = maxID_blobs + 1;
                    % TEMP
                    blobsToAdd(i).ColorToDraw = colores(i,:);
                    %
                end

                model.cleanMask(y_ini:y_fin,x_ini:x_fin) = IOut;

                % Remove the original object
                idx_remove = find([model.blobs.ID] == ob.ID);
                model.blobs(idx_remove) = [];

                % Add the new objects
                model.blobs(1).splitted = 0; % Necessary to joint the two sets
                model.blobs = [model.blobs blobsToAdd];

                splitted = splitted + 1;
            end

            if model.debug
                title(['Frontier Ratio: ' num2str(propFrontera) ' < Limit: ' num2str(LIMITE_FRONTERA)]);
                saveas(handle, [model.path num2str(idxFrame,'%5.6d') '_frame_ob_' num2str(k) '_corte.jpg']);
                saveas(handle, [model.path num2str(idxFrame,'%5.6d') '_frame_ob_' num2str(k) '_corte.fig']);
                
                handle_frame = figure;
                imshow(model.frame(y_ini:y_fin,x_ini:x_fin),'InitialMagnification','fit');
                saveas(handle_frame, [model.path num2str(idxFrame,'%5.6d') '_frame_ob_' num2str(k) '_imagen.jpg']);
                
                coloredImage = uint8(object2doubleImageColored(model.blobs, model.FrameSize));
                handle_frame2 = figure;
                imshow(coloredImage(y_ini:y_fin,x_ini:x_fin,:),'InitialMagnification','fit');
                saveas(handle_frame2, [model.path num2str(idxFrame,'%5.6d') '_frame_ob_' num2str(k) '_final.jpg']);
                saveas(handle_frame2, [model.path num2str(idxFrame,'%5.6d') '_frame_ob_' num2str(k) '_final.fig']);
                
                close(handle);
                close(handle_frame);
                close(handle_frame2);
                
                
                
            end


            %imwrite(R2,[num2str(i,'%5.6d') '_ob_' num2str(k) '_imagenOrientada.jpg']);
        end      
    end
end
