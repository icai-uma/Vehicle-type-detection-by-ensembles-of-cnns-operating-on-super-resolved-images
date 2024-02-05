function kalmanObjectsVisualization(obj_kalman,ax)

hold(ax,'on');
grosor = 1;

for k=1:length(obj_kalman)
  text(obj_kalman(k).x(end,1),obj_kalman(k).x(end,2),num2str(obj_kalman(k).ID),'BackgroundColor',[.7 .7 .7],'Color', [1 1 1], 'FontSize',8,'Parent',ax);
  c = [obj_kalman(k).x(end,1)-(obj_kalman(k).dim(1)/2) obj_kalman(k).x(end,2)-(obj_kalman(k).dim(2)/2) obj_kalman(k).dim];
  rectangle('Position', [c(1), c(2), c(3), c(4)], 'EdgeColor',obj_kalman(k).color, 'LineWidth',grosor, 'Parent',ax); 
end
hold(ax,'off');