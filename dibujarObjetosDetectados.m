function dibujarObjetosDetectados(obj_detectados,ax)

grosor = 1;
color_detectados = [0 1 0];
hold(ax,'off');
for k=1:length(obj_detectados)
    
  c = obj_detectados(k).BoundingBox;
  rectangle('Position', [c(1)+1, c(2)+1, c(3), c(4)], 'EdgeColor',color_detectados, 'LineWidth',grosor, 'Parent',ax); 
%   plot(obj_detectados(k).Centroid(1), obj_detectados(k).Centroid(2), '*y','parent', ejes.Tracking);
end
