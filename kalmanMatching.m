function [m_asoc,matriz_bin] = kalmanMatching(obj_kalman, obj_detectados)

m_asoc = 0;
matriz_bin = 0;
if ~isempty(obj_detectados)

    % Construimos una matriz que muestra la distancia entre cada objeto kalman
    % y cada objeto detectado. Aquellas cuyo valor sea mínimo indicará el
    % emparejhamiento correcto
    matriz = zeros(length(obj_kalman),length(obj_detectados));
    for m=1:length(obj_kalman)
       for n=1:length(obj_detectados)
           matriz(m,n) = sqrt((obj_kalman(m).x(end,1) - obj_detectados(n).Centroid(1))^2 + (obj_kalman(m).x(end,2) - obj_detectados(n).Centroid(2))^2);
       end
    end
    % Calculamos la asociacion "buena" para cada objeto kalman
    matriz_bin = obtenerCorrespondenciaDistancia(matriz);

    [fi,co] = find(matriz_bin == 1);
    if ~isempty(fi)
       kc = [obj_kalman.ID];
       oc = [obj_detectados.ID];
       m_asoc = [kc(fi); oc(co)]';
    end
end
