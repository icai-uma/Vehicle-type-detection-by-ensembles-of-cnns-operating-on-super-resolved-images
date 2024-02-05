function dibujarInfoObjetoTrayectoria(lista_ID, obj_trayectorias,frame_avg)

%global obj_trayectorias;

figure;
sub1 = subplot(1,1,1);
imagen = frame_avg;
hold on;
% 
% colores(1,:) = [0.0417 0 0];
% colores(2,:) = [1.0000    0.0417         0];
% colores(3,:) = [ 1.0000    0.75         0];
% colores(4,:) = [0 0 1]; 

colores = hsv(length(lista_ID));

for i=1:length(lista_ID)
    % Obtengo el objeto asociado al identificador dado como entrada
    ID = lista_ID(i);
    idx = find(([obj_trayectorias.ID] == ID) == 1);
    if ~isempty(idx)
        obj = obj_trayectorias(idx);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Mostrar información sobre la trayectoria
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        posicion_xy = [obj.features.Centroid];
        posicion_xy = [posicion_xy(1:2:end)' posicion_xy(2:2:end)'];

        xlim([0 size(frame_avg,2)]);
        ylim([0 size(frame_avg,1)]);

     
        % Dibujamos la silueta del coche en un instante de tiempo k
        for k=1:10:length(posicion_xy(:,1))
            region = uint8(obj.features(k).ConvexImage);
            limites = round(obj.features(k).BoundingBox);
            regionIMG = imagen(limites(2):limites(2)+limites(4)-1,limites(1):limites(1)+limites(3)-1,:);
            regionIMG2 = regionIMG;
            regionIMG2(:,:,1) = (1 - region).*regionIMG(:,:,1);
            regionIMG2(:,:,2) = (1 - region).*regionIMG(:,:,2);
            regionIMG2(:,:,3) = (1 - region).*regionIMG(:,:,3);

            regionIMG2 = uint8(double(regionIMG2) + double(obj.features(k).imagen));
            imagen(limites(2):limites(2)+limites(4)-1,limites(1):limites(1)+limites(3)-1,:) = regionIMG2;
        end

        % Dibujamos la silueta del coche en su ultima aparicion
        k = length(posicion_xy(:,1));
        region = uint8(obj.features(k).ConvexImage);
        limites = round(obj.features(k).BoundingBox);
        regionIMG = imagen(limites(2):limites(2)+limites(4)-1,limites(1):limites(1)+limites(3)-1,:);
        regionIMG2 = regionIMG;
        regionIMG2(:,:,1) = (1 - region).*regionIMG(:,:,1);
        regionIMG2(:,:,2) = (1 - region).*regionIMG(:,:,2);
        regionIMG2(:,:,3) = (1 - region).*regionIMG(:,:,3);
        regionIMG2 = uint8(double(regionIMG2) + double(obj.features(k).imagen));
        imagen(limites(2):limites(2)+limites(4)-1,limites(1):limites(1)+limites(3)-1,:) = regionIMG2;
    end
end    

imshow(uint8(imagen));
hold on;
for i=1:length(lista_ID)
    % Obtengo el objeto asociado al identificador dado como entrada
    ID = lista_ID(i);
    idx = find(([obj_trayectorias.ID] == ID) == 1);
    if ~isempty(idx)
        obj = obj_trayectorias(idx);

        posicion_xy = [obj.features.Centroid];
        posicion_xy = [posicion_xy(1:2:end)' posicion_xy(2:2:end)'];

   
        plot(posicion_xy(:,1), posicion_xy(:,2),'Color',colores(i,:),'Linewidth',3,'LineStyle','--');
        
        % Dibujamos el convex hull de cada objeto
        for k=1:10:length(posicion_xy(:,1))
            plot(obj.features(k).ConvexHull(:,1),obj.features(k).ConvexHull(:,2), '-w', 'Linewidth', 1);
        end
        k = length(posicion_xy(:,1));
        plot(obj.features(k).ConvexHull(:,1),obj.features(k).ConvexHull(:,2), '-w', 'Linewidth', 1);

        pos_text_x = posicion_xy(1,1)-20;
        pos_text_y = posicion_xy(1,2)-10;
        if pos_text_x < 0
            pos_text_x = pos_text_x + 40;   
        end
        text(pos_text_x, pos_text_y,num2str(ID),'HorizontalAlignment','center',... 
        'BackgroundColor',[.7 .9 .7],'FontSize',14);
    end
end

%hTitle = title('Trajectories');
%hTitle = title('Vehicle types');
%hXLabel = xlabel('X Coordinate');
%hYLabel = ylabel('Y Coordinate');
set(sub1, 'YDir', 'reverse');
set(sub1, 'TickDir', 'out');
set(sub1, 'PlotBoxAspectRatioMode', 'manual');
set(sub1,'DataAspectRatio',[1 1 1]);

%set([hXLabel, hYLabel]  , ...
%    'FontSize'   , 10          );
set( hTitle                    , ...
    'FontSize'   , 18          , ...
    'FontWeight' , 'bold'      );

box on;