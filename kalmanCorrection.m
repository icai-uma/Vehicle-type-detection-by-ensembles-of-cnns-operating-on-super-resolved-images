function [kModel,obj_detectados] = kalmanCorrection(kModel,obj_detectados,m_asoc)

for k=1:length(kModel.objects)

    obk = kModel.objects(k);
    if m_asoc ~= 0
        relacion_kalman_objeto = (m_asoc'*(m_asoc(:,1) == obk.ID))';

        if relacion_kalman_objeto(1) > 0
            id = relacion_kalman_objeto(2);
            enc = 1;
        else
            enc = 0;
        end
    else
        enc = 0;
    end

    num_elem = size(obk.x,1);
    % Actualizamos las variables de kalman
    obk.K = (obk.PP*kModel.H')/(kModel.H*obk.PP*kModel.H'+kModel.R);
    if enc > 0
        % Seleccionamos el indice dentro del vector que se corresponde con el
        % ID
        idx = find(([obj_detectados.ID] == id) == 1);
        
        % Obtenemos el objeto y lo quitamos de la lista de objetos que nos
        % quedan
        obj_asociado = obj_detectados(idx);
        obj_detectados = [obj_detectados(1:idx-1) obj_detectados(idx+1:end)];
                
        obk.xreal(size(obk.xreal,1)+1,:) = [obj_asociado.Centroid(1),obj_asociado.Centroid(2)]';
        obk.x(size(obk.x,1)+1,:) = (double(obk.xp) + obk.K*([obj_asociado.Centroid(1),obj_asociado.Centroid(2)]' - kModel.H*double(obk.xp)))';
        if enLimites(obj_asociado.BoundingBox,kModel.FrameSize)
            obk.dim = obj_asociado.BoundingBox(3:4);
        else
            obk.dim = ((num_elem-1)/num_elem)*obk.dim + (1/num_elem)*obj_asociado.BoundingBox(3:4);
        end
        obk.ultimaAsociacion = kModel.LastFrame;
        obk.color = [1 0 0];
        obk.corr_o_pred(length(obk.corr_o_pred)+1) = 1;
        obk.numVecesMatching = obk.numVecesMatching + 1;
        obk.lifeTime = kModel.LifeTime;
        % Obtenemos los pixeles del objeto que hemos detectado y lo almacenamos
        % en la estructura
%         X = ListaPixelesObjeto(obj_asociado,[size(frame,2) size(frame,1)]);
%         obj_asociado.imagen = ConvexImage2Image(uint8(frame), obj_asociado);
%         obj_asociado.CentroidMedian = median(X);
%         obj_asociado.CentroidMedianL1 = L1median(X);
%         obj_asociado.colorMediano = tonalidadMedianaObjeto(obj_asociado,'RGB');
%         obj_asociado.colorMedianoLab = tonalidadMedianaObjeto(obj_asociado,'Lab');
%         obj_asociado.CircularidadNueva = obtenerCircularidad(obj_asociado, X);
%         obj_asociado.Orientacion = obtenerOrientacion(obj_asociado, X);        
%         obj_asociado.DistanciaMediana = obtenerDistanciaMediana(obj_asociado, X);
        
        obk.features(length(obk.features)+1) = obj_asociado;
    else
        obk.x(size(obk.x,1)+1,:) = obk.xp;
        obk.color = [1 1 0];
        obk.corr_o_pred(length(obk.corr_o_pred)+1) = 0;
        obk.lifeTime = obk.lifeTime - 1;
        %obk.features(length(obk.features)) = [];
        % obk.lado = lado_m;
    end
    obk.P = (kModel.I-obk.K*kModel.H)*obk.PP;

    kModel.objects(k) = obk;


end