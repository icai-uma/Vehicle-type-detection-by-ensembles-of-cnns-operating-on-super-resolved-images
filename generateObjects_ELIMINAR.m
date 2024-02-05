function [obj_detectados,flag] = generateObjects(objetos)

% subtract background & select pixels with a big difference
%fore = im2bw(frame, 40/255);

% Morphology Operation  erode to remove small noise
%foremm = bwmorph(fore,'erode',2); %2 time

% select largest object
%[labeled] = bwlabel(foremm,4);
%stats = regionprops(labeled,['basic']);%basic mohem nist
stats  = regionprops(objetos, 'Area', 'ConvexHull', 'ConvexImage','Orientation','Centroid','BoundingBox');
[N,W] = size(stats);
flag = 0;
cont = 1;
for i=1:N
    %if stats(i).Area > 50
    obj_detectados(cont).ID = cont;
    %obj_detectados(cont).lado = sqrt(stats(i).Area);
    obj_detectados(cont).x = stats(i).Centroid(1);
    obj_detectados(cont).y = stats(i).Centroid(2);
    obj_detectados(cont).Centroid = stats(i).Centroid;
    obj_detectados(cont).Area = stats(i).Area;
    obj_detectados(cont).BoundingBox = stats(i).BoundingBox;
    obj_detectados(cont).ConvexImage = stats(i).ConvexImage;
    obj_detectados(cont).ConvexHull = stats(i).ConvexHull;
    obj_detectados(cont).posibleError = 0;

    %X = ListaPixeles_y_ColoresObjeto(obj_detectados(cont),frame);
    %obj_detectados(cont).imagen = ConvexImage2Image(uint8(frame), obj_detectados(cont));
    %obj_detectados(cont).CentroidMedian = median(X(:,1:2));
    %obj_detectados(cont).CentroidMedianL1 = L1median(X(:,1:2));
    %obj_detectados(cont).colorMediano = tonalidadMedianaObjeto(obj_detectados(cont),'RGB');
    %obj_detectados(cont).colorMedianoLab = tonalidadMedianaObjeto(obj_detectados(cont),'Lab');
    %obj_detectados(cont).CircularidadNueva = obtenerCircularidad(obj_detectados(cont), X(:,1:2));
    %obj_detectados(cont).Orientacion = obtenerOrientacion(obj_detectados(cont), X(:,1:2));
    %obj_detectados(cont).DistanciaMediana = obtenerDistanciaMediana(obj_detectados(cont), X(:,1:2));
    %[obj_detectados(cont).probColores, frameColor] = obtenerVectorColores(obj_detectados(cont).ConvexImage, obj_detectados(cont).imagen);
    %obj_detectados(cont).covPosicionColor = obtenerCovarianzaPosicionColor(obj_detectados(cont),X);

    cont = cont + 1;
    %end
end

if cont > 1
    flag = 1;
else
    obj_detectados = [];
end