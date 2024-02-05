function [model,asociados] = objetosPorZonas(model,objetos)

if ~isempty(objetos)
    errores = ([objetos.posibleError]);
    idxs_validos = find(1 - errores);
    
    c = [objetos(idxs_validos).Centroid];
    c = [c(1:2:end); c(2:2:end)]';
    
    puntos = [model.zonas.Punto];
    puntos = [puntos(1:2:end); puntos(2:2:end)]';

    [m, pos] = min(dist(puntos,c'));

    for k=1:length(model.zonas)
        idxs_z = find(pos == k);
        asociados(k).idx = idxs_validos(idxs_z);
    end
else
    asociados = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Representacion de los puntos
% figure,imshow(frame);
% hold on;
% plot(puntos(:,1), puntos(:,2), 'o', 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor','r',...
%                 'MarkerSize',15);
% text(puntos(:,1), puntos(:,2),num2cell(1:length(puntos)),'FontSize',8,'Color',[1 1 1]);
%             
% plot(c(:,1), c(:,2), 'o', 'MarkerEdgeColor','b',...
%                 'MarkerFaceColor','b',...
%                 'MarkerSize',5);
%            
% text(c(:,1)-10, c(:,2)-10,num2cell([objetos.ID]),'FontSize',7,'BackgroundColor',[.7 .9 .7]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
