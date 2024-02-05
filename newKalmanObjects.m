function kModel = newKalmanObjects(kModel, obj_detectados)


for k=1:length(obj_detectados)
    obj_nuevokal.ID = kModel.ID;
    kModel.ID = kModel.ID+1;
    %      obj_nuevokal.x = zeros(numFrames-i+1,4);
    %      obj_nuevokal.xpred = zeros(numFrames-i+1,4);
    obj_nuevokal.xp = [obj_detectados(k).Centroid(1),obj_detectados(k).Centroid(2),0,0]';
    obj_nuevokal.xreal(1,:) = obj_nuevokal.xp(1:2);
    obj_nuevokal.P = kModel.P;
    obj_nuevokal.primeraAsociacion = kModel.LastFrame;
    obj_nuevokal.color = [1 0 0];
    % Prediccion
    obj_nuevokal.xpred(1,:) = obj_nuevokal.xp;
    obj_nuevokal.PP = kModel.A*obj_nuevokal.P*kModel.A' + kModel.Q;
    % Actualizamos las variables de kalman
    obj_nuevokal.K = (obj_nuevokal.PP*kModel.H')/(kModel.H*obj_nuevokal.PP*kModel.H'+kModel.R);
    obj_nuevokal.x(1,:) = (double(obj_nuevokal.xp) + obj_nuevokal.K*([obj_detectados(k).Centroid(1),obj_detectados(k).Centroid(2)]' - kModel.H*double(obj_nuevokal.xp)))';
    obj_nuevokal.dim = obj_detectados(k).BoundingBox(3:4);
    obj_nuevokal.P = (kModel.I-obj_nuevokal.K*kModel.H)*obj_nuevokal.PP;
    obj_nuevokal.corr_o_pred(1) = 1;
    obj_nuevokal.numVecesMatching = 1;
    obj_nuevokal.ultimaAsociacion = kModel.LastFrame;
    obj_nuevokal.lifeTime = kModel.LifeTime;
    
    % Obtenemos los pixeles del objeto que hemos detectado y lo almacenamos
    % en la estructura
%     X = ListaPixelesObjeto(obj_detectados(k),[size(frame,2) size(frame,1)]);
%     
%     obj_detectados(k).imagen = ConvexImage2Image(uint8(frame), obj_detectados(k));
%     obj_detectados(k).CentroidMedian = median(X);
%     obj_detectados(k).CentroidMedianL1 = L1median(X);
%     obj_detectados(k).colorMediano = tonalidadMedianaObjeto(obj_detectados(k),'RGB');
%     obj_detectados(k).colorMedianoLab = tonalidadMedianaObjeto(obj_detectados(k),'Lab');
%     obj_detectados(k).CircularidadNueva = obtenerCircularidad(obj_detectados(k), X);
%     obj_detectados(k).Orientacion = obtenerOrientacion(obj_detectados(k), X);
%     obj_detectados(k).DistanciaMediana = obtenerDistanciaMediana(obj_detectados(k), X);
    obj_nuevokal.features(1) =  obj_detectados(k);
    
    if (isempty(kModel.objects))    
        kModel.objects = obj_nuevokal;
    else
        kModel.objects(length(kModel.objects)+1) = obj_nuevokal;
    end
end