function [EvaluacionValidada]=ValidacionCruzadaClasificador(Evaluaciones)
% Evaluar el rendimiento de un clasificador usando validación cruzada
% Entrada:
%   Evaluaciones=Evaluaciones de los clasificadores obtenidos en la
%   validación cruzada, calculadas mediante EvaluarClasificador.m
% Salida:
%   EvaluacionValidada=Resumen de las evaluaciones de los clasificadores

NumDatos=length(Evaluaciones);

% Proporción (tanto por uno) de aciertos de clasificación
for ndx=1:NumDatos
    Aciertos(ndx)=Evaluaciones{ndx}.Aciertos;
end
EvaluacionValidada.Aciertos.Media=mean(Aciertos);
EvaluacionValidada.Aciertos.DesvTip=std(Aciertos);
EvaluacionValidada.Aciertos.Mediana=median(Aciertos);

% Rand index: A.K. Jain, R.C. Dubes, Algorithms for Clustering Data, Prentice-
% Hall, Englewood Cliffs, NJ, 1988. Pages 173-174.
% Valores en [0,1]: 1 indica clasificación perfecta 
for ndx=1:NumDatos
    RandIndex(ndx)=Evaluaciones{ndx}.RandIndex;
end
EvaluacionValidada.RandIndex.Media=mean(RandIndex);
EvaluacionValidada.RandIndex.DesvTip=std(RandIndex);
EvaluacionValidada.RandIndex.Mediana=median(RandIndex);


% Hubert's GAMMA statistic: A.K. Jain, R.C. Dubes, Algorithms for Clustering Data, Prentice-
% Hall, Englewood Cliffs, NJ, 1988. Pages 173-174.
% Valores en [-1,1], 1 indica correlación positiva (buena clasificación)
for ndx=1:NumDatos
    HubertGamma(ndx)=Evaluaciones{ndx}.HubertGamma;
end

HubertGamma=HubertGamma(find(isfinite(HubertGamma)));

EvaluacionValidada.HubertGamma.Media=mean(HubertGamma);
EvaluacionValidada.HubertGamma.DesvTip=std(HubertGamma);
EvaluacionValidada.HubertGamma.Mediana=median(HubertGamma);



% Overall entropy: J. He, A.H. Tan, C.L. Tan, S.Y. Sung, On quantitative evaluation of
% clustering systems, in: W. Wu, H. Xiong, S. Shekhar (Eds.),
% Clustering and Information Retrieval, Kluwer Academic Publishers,
% Norwell, MA, 2003, pp. 105–133.
% OverallClusterEntropy, ClassEntropy y OverallEntropy están en el
% intervalo [0,1]. Cuanto más bajo el valor, mejor agrupamiento
for ndx=1:NumDatos
    OverallClusterEntropy(ndx)=Evaluaciones{ndx}.OverallClusterEntropy;
end
EvaluacionValidada.OverallClusterEntropy.Media=mean(OverallClusterEntropy);
EvaluacionValidada.OverallClusterEntropy.DesvTip=std(OverallClusterEntropy);
EvaluacionValidada.OverallClusterEntropy.Mediana=median(OverallClusterEntropy);

for ndx=1:NumDatos
    OverallClassEntropy(ndx)=Evaluaciones{ndx}.OverallClassEntropy;
end
EvaluacionValidada.OverallClassEntropy.Media=mean(OverallClassEntropy);
EvaluacionValidada.OverallClassEntropy.DesvTip=std(OverallClassEntropy);
EvaluacionValidada.OverallClassEntropy.Mediana=median(OverallClassEntropy);

for ndx=1:NumDatos
    OverallEntropy(ndx)=Evaluaciones{ndx}.OverallEntropy;
end
EvaluacionValidada.OverallEntropy.Media=mean(OverallEntropy);
EvaluacionValidada.OverallEntropy.DesvTip=std(OverallEntropy);
EvaluacionValidada.OverallEntropy.Mediana=median(OverallEntropy);

for ndx=1:NumDatos
    MeanSquareError(ndx)=Evaluaciones{ndx}.MeanSquareError;
end
EvaluacionValidada.MeanSquareError.Media=mean(MeanSquareError);
EvaluacionValidada.MeanSquareError.DesvTip=std(MeanSquareError);
EvaluacionValidada.MeanSquareError.Mediana=median(MeanSquareError);
