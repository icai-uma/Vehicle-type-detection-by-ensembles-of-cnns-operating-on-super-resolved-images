function model = splitObjects(model, i)

objetos = model.blobs;
mask = model.cleanMask;

idxs = find([objetos.posibleError]);


for k=1:length(idxs)
    ob = objetos(idxs(k));
    x_ini = round(ob.BoundingBox(1));
    y_ini = round(ob.BoundingBox(2));
    x_fin = round(ob.BoundingBox(1) + ob.BoundingBox(3));
    y_fin = round(ob.BoundingBox(2) + ob.BoundingBox(4));
    
    angle = -ob.OrientationNeuronAssociated;
    I = model.cleanMask(y_ini:y_fin,x_ini:x_fin);
    R2 = imrotate(I,angle, 'bilinear');
    
    % Histogramas proyectados (horizontal)
    [corteH, idx_h, handle_h] = posibleCorte(sum(R2));
    %saveas(handle_h, [num2str(i,'%5.6d') '_ob_' num2str(k) '_hor.jpg']);
    %saveas(handle_h, [num2str(i,'%5.6d') '_ob_' num2str(k) '_hor.fig']);
    close(handle_h);
    
    % Histogramas proyectados (horizontal)
    [corteV, idx_v, handle_v] = posibleCorte(sum(R2,2)');
    %saveas(handle_v, [num2str(i,'%5.6d') '_ob_' num2str(k) '_ver.jpg']);
    %saveas(handle_v, [num2str(i,'%5.6d') '_ob_' num2str(k) '_ver.fig']);
    close(handle_v);
    
    %imwrite(R2,[num2str(i,'%5.6d') '_ob_' num2str(k) '_imagenOrientada.jpg']);
    if corteH || corteV
        a = 1;
    end
    
    I = model.imMask_prob(y_ini:y_fin,x_ini:x_fin);
    I = 1 - I;
    %save(['corte_' num2str(i) '_' num2str(k) '.mat'],'I');
         
end

