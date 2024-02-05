function [Evaluaciones]=EvaluarClasificador(GruposReales,GruposEstimados)
% Evaluar el rendimiento de un clasificador
% Tomado en parte de:
%   "Assessment of self-organizing map variants for clustering with
%   application to redistribution of emotional speech patterns",
%   Vassiliki Moschou, Dimitrios Ververidis, Constantine Kotropoulos,
%   Neurocomputing 71 (2007) 147–156. 
% Entradas:
%   GruposReales: Vector que contiene los índices de las clases a las que
%   realmente pertenecen ciertos patrones
%   GruposEstimados: Vector que contiene los índices de las clases a las 
%   que el clasificador estima que pertenecen esos mismos patrones

% Número de patrones y número de parejas que se pueden formar con los patrones
NumPatrones=length(GruposReales);
NumParejas=NumPatrones*(NumPatrones-1)/2;

% Hallar la tabla de contingencia
Contin=zeros(max([max(GruposEstimados),max(GruposReales)]));
for ndx=1:NumPatrones
    Contin(GruposEstimados(ndx),GruposReales(ndx))=...
        Contin(GruposEstimados(ndx),GruposReales(ndx))+1;
end
[NumClustersEstimados,NumClasesReales]=size(Contin);

% Tamaño de las clases reales y clusters estimados
TamanoClusterEstimado=sum(Contin,2);
TamanoClaseReal=sum(Contin,1);


% Proporción (tanto por uno) de aciertos de clasificación
Evaluaciones.Aciertos=sum(diag(Contin))/sum(sum(Contin));

% Rand index: A.K. Jain, R.C. Dubes, Algorithms for Clustering Data, Prentice-
% Hall, Englewood Cliffs, NJ, 1988. Pages 173-174.
% Valores en [0,1]: 1 indica clasificación perfecta 
Evaluaciones.RandIndex=1+(sum(sum(Contin.^2))-0.5*...
    sum(TamanoClusterEstimado.^2)-0.5*sum(TamanoClaseReal.^2))/NumParejas;

% Hubert's GAMMA statistic: A.K. Jain, R.C. Dubes, Algorithms for Clustering Data, Prentice-
% Hall, Englewood Cliffs, NJ, 1988. Pages 173-174.
% Valores en [-1,1], 1 indica correlación positiva (buena clasificación)
Valor_a=0.5*sum(sum(Contin.^2))-0.5*NumPatrones;
Valor_b=0.5*sum(TamanoClaseReal.^2)-0.5*sum(sum(Contin.^2));
Valor_c=0.5*sum(TamanoClusterEstimado.^2)-0.5*sum(sum(Contin.^2));
Valor_m1=Valor_a+Valor_b;
Valor_m2=Valor_a+Valor_c;
Evaluaciones.HubertGamma=(NumParejas*Valor_a-Valor_m1*Valor_m2)/...
    sqrt(Valor_m1*Valor_m2*(NumParejas-Valor_m1)*(NumParejas-Valor_m2));


% Overall entropy: J. He, A.H. Tan, C.L. Tan, S.Y. Sung, On quantitative evaluation of
% clustering systems, in: W. Wu, H. Xiong, S. Shekhar (Eds.),
% Clustering and Information Retrieval, Kluwer Academic Publishers,
% Norwell, MA, 2003, pp. 105–133.
% OverallClusterEntropy, ClassEntropy y OverallEntropy están en el
% intervalo [0,1]. Cuanto más bajo el valor, mejor agrupamiento
for NdxCluster=1:NumClustersEstimados
    Vector=Contin(NdxCluster,:);
    Vector=Vector(find(Vector>0));
    Evaluaciones.IndividualClusterEntropy(NdxCluster)=...
        -sum((Vector/TamanoClusterEstimado(NdxCluster)).*...
        log(Vector/TamanoClusterEstimado(NdxCluster)));
end
Evaluaciones.OverallClusterEntropy=sum(TamanoClusterEstimado'.*...
    Evaluaciones.IndividualClusterEntropy)/NumPatrones;
for NdxClase=1:NumClasesReales
    Vector=Contin(:,NdxClase);
    Vector=Vector(find(Vector>0));    
    Evaluaciones.IndividualClassEntropy(NdxClase)=...
        -sum((Vector/TamanoClaseReal(NdxClase)).*...
        log(Vector/TamanoClaseReal(NdxClase)));
end
Evaluaciones.OverallClassEntropy=sum(TamanoClaseReal.*...
    Evaluaciones.IndividualClassEntropy)/NumPatrones;
Evaluaciones.OverallEntropy=0.5*Evaluaciones.OverallClusterEntropy+...
    0.5*Evaluaciones.OverallClassEntropy;

% Mean Square Error (Error cuadrático medio)
Evaluaciones.MeanSquareError = sum((GruposReales - GruposEstimados).^2)/NumPatrones;

