function drawZones(model, fondo, h)

zonas = model.zonas;
grosor = 2;
color = [1 0 0];

imshow(fondo, 'parent', h);
hold(h, 'on');
for i=1:length(zonas)
    zone = zonas(i);
    if ~isempty(zone.MediaArea)
        ancho = zone.MediaDim(1);
        alto = zone.MediaDim(2);
        xp = zone.Punto(1);
        yp = zone.Punto(2);
        rectangle('Position', [xp-(ancho/2), yp-(alto/2), ancho, alto], 'EdgeColor',color, 'LineWidth',2, 'Parent',h);
        
        radio = sqrt(zone.MediaArea / pi);
        circle([xp,yp], radio, 100, '-', [0 0 0], h);
        
        if ~isempty(zone.VarianzaDim)
            
            ancho_upper = zone.MediaDim(1) + 2.5*sqrt(zone.VarianzaDim(1));
            alto_upper = zone.MediaDim(2) + 2.5*sqrt(zone.VarianzaDim(2));
            rectangle('Position', [xp-(ancho_upper/2), yp-(alto_upper/2), ancho_upper, alto_upper], 'EdgeColor',color, 'LineWidth',1, 'Parent',h);
                
            ancho_lower = zone.MediaDim(1) - 2.5*sqrt(zone.VarianzaDim(1));
            alto_lower = zone.MediaDim(2) - 2.5*sqrt(zone.VarianzaDim(2));
            
            if (ancho_lower > 0) && (alto_lower > 0)
                rectangle('Position', [xp-(ancho_lower/2), yp-(alto_lower/2), ancho_lower, alto_lower], 'EdgeColor',color, 'LineWidth',1, 'Parent',h);
            end
            
            radio_upper = sqrt((zone.MediaArea + 2.5*sqrt(zone.VarianzaArea)) / pi);
            circle([xp,yp], radio_upper, 100, '--', [1 1 1], h);

            radio_lower = sqrt((zone.MediaArea - 2.5*sqrt(zone.VarianzaArea)) / pi);
            if radio_lower > 0
                circle([xp,yp], radio_lower, 100, '--', [1 1 1], h);
            end
        end
        
        
    end
    
end

hold(h, 'off');

             
% plot(x,y,'--rs','LineWidth',2,...
%                 'MarkerEdgeColor','k',...
%                 'MarkerFaceColor','g',...
%                 'MarkerSize',10)