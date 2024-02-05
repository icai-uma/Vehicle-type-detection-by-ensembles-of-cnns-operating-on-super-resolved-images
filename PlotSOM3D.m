function [Handle]=PlotSOM3D(Model,Samples)
% Plot un mapa autoorganizado sobre un espacio de entrada
% de tres dimensiones o más
% Entradas:
% Model=Mapa a dibujar
% Samples=Samples a dibujar junto al modelo



NumRowsMap=Model.NumRowsMap;
NumColsMap=Model.NumColsMap;
if Model.Dimension>3
    Prototypes=reshape(Model.Prototypes,[Model.Dimension size(Model.Prototypes,2)*size(Model.Prototypes,3)]);
    Prototypes=Model.UqT*(Prototypes-repmat(Model.GlobalMu,[1 size(Prototypes,2)]));
    SamplesPCA=Model.UqT*(Samples-repmat(Model.GlobalMu,[1 size(Samples,2)]));
    Prototypes=reshape(Prototypes,[size(Prototypes,1) size(Model.Prototypes,2) size(Model.Prototypes,3)]);
    Prototypes=squeeze(mat2cell(Prototypes,3,ones(1,Model.NumRowsMap),ones(1,Model.NumColsMap)));
else
    Prototypes=squeeze(mat2cell(Model.Prototypes,3,ones(1,Model.NumRowsMap),ones(1,Model.NumColsMap)));
    SamplesPCA=Samples;
end

 


Handle=figure
hold on



% Pintar las conexiones horizontales
for NdxRow=1:NumRowsMap
    for NdxCol=1:(NumColsMap-1)
        LineaX=[Prototypes{NdxRow,NdxCol}(1) Prototypes{NdxRow,NdxCol+1}(1)];
        LineaY=[Prototypes{NdxRow,NdxCol}(2) Prototypes{NdxRow,NdxCol+1}(2)];  
        LineaZ=[Prototypes{NdxRow,NdxCol}(3) Prototypes{NdxRow,NdxCol+1}(3)];
        plot3(LineaX,LineaY,LineaZ,'-k','LineWidth',0.5);
    end
end

% Pintar las conexiones verticales
for NdxRow=1:(NumRowsMap-1)
    for NdxCol=1:NumColsMap
        LineaX=[Prototypes{NdxRow,NdxCol}(1) Prototypes{NdxRow+1,NdxCol}(1)];
        LineaY=[Prototypes{NdxRow,NdxCol}(2) Prototypes{NdxRow+1,NdxCol}(2)];  
        LineaZ=[Prototypes{NdxRow,NdxCol}(3) Prototypes{NdxRow+1,NdxCol}(3)];  
        plot3(LineaX,LineaY,LineaZ,'-k','LineWidth',0.5);
    end
end

% Pintar las muestras
plot3(SamplesPCA(1,:),SamplesPCA(2,:),SamplesPCA(3,:),'.k','Color',[0.5 0 0]);



