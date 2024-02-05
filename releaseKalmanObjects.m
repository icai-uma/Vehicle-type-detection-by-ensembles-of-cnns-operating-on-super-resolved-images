function kModel = releaseKalmanObjects(kModel)

cont = 1;
for k=1:length(kModel.objects)
    x = kModel.objects(k).x(end,:);
%    numVecesSinAparecer = i - obj_kalman(k).ultimaAsociacion;
    if ((x(1) <= 0 || x(1) > kModel.FrameSize(1)) || (x(2) <= 0 || x(2) > kModel.FrameSize(2)))
        disp(['Fuera de los límites de la escena. Eliminado el objeto con ID ' int2str(kModel.objects(k).ID)]);
        kModel = storeObjectTrayectory(kModel, k);
    elseif kModel.objects(k).lifeTime == 0
        disp(['Demasiado tiempo sin aparecer. Eliminado el objeto con ID ' int2str(kModel.objects(k).ID)]);
        kModel = storeObjectTrayectory(kModel, k);
    else
        obj_kalman_new(cont) = kModel.objects(k);
        cont = cont + 1;
    end
end

if (cont == 1)
    obj_kalman_new = [];
end

kModel.objects = obj_kalman_new;