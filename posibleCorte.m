function [corte, idx, h] = posibleCorte(vector)

NPEAKS_MAX = 2;
THRESH_DIF_MAXMIN = 0.7;

corte = 0;
idx = -1;

hist_h = vector;
y = hist_h;
x = 1:length(y);
%xs = SignalSmoothing(x);
%ys = SignalSmoothing(y);
xs = x;
ys = y;

h = figure; 
bar(hist_h,2,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.25 0.25 0.25]);
hold on;
plot(xs,ys,'-', 'Color', [1 0 0], 'LineWidth',2);
[pks,locs] = findpeaks(ys, 'MINPEAKDISTANCE', 10,'SORTSTR','descend');

if length(pks) >= NPEAKS_MAX
    pks = pks(1:NPEAKS_MAX);
    locs = locs(1:NPEAKS_MAX);

    % Valor de los máximos locales
    pto_y_max = pks+0.05;
    pto_x_max = x(locs);

    plot(pto_x_max,pto_y_max,'o', 'MarkerEdgeColor','k',...
                'MarkerFaceColor','b','MarkerSize',10);

    locs = sort(locs);

    % Curva en la que buscar el mínimo
    x_min = x(locs(1):locs(2));
    y_min = ys(locs(1):locs(2));

    plot(x(locs(1):locs(2)),ys(locs(1):locs(2)),'-g','LineWidth',3);
    [pks_min,locs_min] = findpeaks(-y_min,'SORTSTR','descend');

    if length(pks_min) >= 1
        % Valor del mínimo local
        pto_y_min = -pks_min(1);
        pto_x_min = x_min(locs_min(1));
        plot(pto_x_min,pto_y_min+0.05,'o', 'MarkerEdgeColor','k',...
                    'MarkerFaceColor','w','MarkerSize',10);

        altura = pto_y_max(1);
        distancias = pto_y_max - pto_y_min;

        if all((distancias / altura) > THRESH_DIF_MAXMIN)
            corte = 1;
            idx = pto_x_min;
            
            plot(pto_x_min,pto_y_min+0.05,'o', 'MarkerEdgeColor','k',...
                    'MarkerFaceColor','k','MarkerSize',20);
            
            lim_y = get(gca,'ylim');
            linea_y = lim_y(1):lim_y(2);
            linea_x = pto_x_min*ones(1,length(linea_y));
            plot(linea_x,linea_y,'--', 'Color','k','LineWidth',5);
            


            
        end
        %saveas(h, [num2str(i,'%5.6d') '_ob_' num2str(indice_objeto) '_' tipo '.jpg']);
    end
end
