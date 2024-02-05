function visualizeSOFM(model, h)


NumRowsMap = model.SOFM.NumRowsMap;
NumColsMap = model.SOFM.NumColsMap;
colores = hsv(NumRowsMap * NumColsMap); 

hold(h,'on');

% Pintar las conexiones horizontales
for NdxRow=1:NumRowsMap
    for NdxCol=1:(NumColsMap-1)
        LineaX=[model.SOFM.Prototypes(1,NdxRow,NdxCol) model.SOFM.Prototypes(1,NdxRow,NdxCol+1)];
        LineaY=[model.SOFM.Prototypes(2,NdxRow,NdxCol) model.SOFM.Prototypes(2,NdxRow,NdxCol+1)];
        %LineaZ=[model.SOFM.Prototypes{NdxRow,NdxCol}(3) model.SOFM.Prototypes{NdxRow,NdxCol+1}(3)];
        plot(LineaX,LineaY,'-k','LineWidth',1);
    end
end

% Pintar las conexiones verticales
for NdxRow=1:(NumRowsMap-1)
    for NdxCol=1:NumColsMap
        LineaX=[model.SOFM.Prototypes(1,NdxRow,NdxCol) model.SOFM.Prototypes(1,NdxRow+1,NdxCol)];
        LineaY=[model.SOFM.Prototypes(2,NdxRow,NdxCol) model.SOFM.Prototypes(2,NdxRow+1,NdxCol)];
        %LineaZ=[model.SOFM.Prototypes{NdxRow,NdxCol}(3) model.SOFM.Prototypes{NdxRow,NdxCol+1}(3)];
        plot(LineaX,LineaY,'-k','LineWidth',1);
    end
end

% Pintar las conexiones horizontales
for NdxRow=1:NumRowsMap
    for NdxCol=1:NumColsMap
         xp = model.SOFM.Prototypes(1,NdxRow,NdxCol);
         yp = model.SOFM.Prototypes(2,NdxRow,NdxCol);
         area = model.SOFM.Prototypes(3,NdxRow,NdxCol) * model.SOFM.GlobalDesv(3) + model.SOFM.GlobalMu(3);
         radio = sqrt(area / pi);
         
         idx = sub2ind([NumRowsMap NumColsMap],NdxRow,NdxCol);
         filledCircle([xp,yp], radio, 100, colores(idx,:), h); 
         %filledCircle([xp,yp], radio, 100, [1 1 1], h); 
         circle([xp,yp], radio, 100, '-', [0 0 0], h);
         
%         LineaX=[Prototypes{NdxRow,NdxCol}(1) Prototypes{NdxRow,NdxCol+1}(1)];
%         LineaY=[Prototypes{NdxRow,NdxCol}(2) Prototypes{NdxRow,NdxCol+1}(2)];  
%         LineaZ=[Prototypes{NdxRow,NdxCol}(3) Prototypes{NdxRow,NdxCol+1}(3)];
%         plot3(LineaX,LineaY,LineaZ,'-k','LineWidth',0.5);
    end
end

hold(h,'off');