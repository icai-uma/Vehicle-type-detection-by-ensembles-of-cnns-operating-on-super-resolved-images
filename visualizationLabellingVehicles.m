function frameT = visualizationLabellingVehicles(obj_kalman,frame)

posVehicle = [];
color_str = [];
cont = 1;
for k=1:length(obj_kalman)
        typeList = {obj_kalman(k).features.idxType};
        lifetime = obj_kalman(k).lifeTime;
        idx = find(~cellfun(@isempty,typeList));
        if (lifetime >= 10)
        if not(isempty(idx)) && (lifetime > 12)
           idxType = mode([typeList{idx}]);
      
        %cont = cont + 1;
           %disp(PredictedLabel);
           switch idxType
           case 1
               type = 'car';
               colorS = [255 255 0]; % yellow
           case 2
               type = 'moto';
               colorS = [0 255 0]; % green
           case 3
               type = 'truck';
               colorS = [0 255 255]; % cyan
           case 4
               type = 'van';
               colorS = [255 0 0]; % red
           end
        else
           type = '???';
           colorS = [255 255 255 ];
        end
        %text(obj_kalman(k).x(end,1),obj_kalman(k).x(end,2),num2str(obj_kalman(k).ID),'BackgroundColor',[.7 .7 .7],'Color', [1 1 1], 'FontSize',8,'Parent',ax);
        c = [obj_kalman(k).x(end,1)-(obj_kalman(k).dim(1)/2) obj_kalman(k).x(end,2)-(obj_kalman(k).dim(2)/2) obj_kalman(k).dim];
        posVehicle = [posVehicle; c(1), c(2), c(3), c(4)];
        %label_str{k} = [type ' ' num2str(obj_kalman(k).ID)];
        color_str = [color_str; colorS];
        label_str{cont} = type;
        %color_str{cont} = colorS;
        cont = cont + 1;
        %rectangle('Position', [], 'EdgeColor',obj_kalman(k).color, 'LineWidth',grosor, 'Parent',ax); 
        end
end

frameT = insertObjectAnnotation(frame,'rectangle',posVehicle,label_str,'TextBoxOpacity',0.9,'FontSize',12,'Color',color_str);
