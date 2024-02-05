function getTrackingInfo

addpath('./mmread');

% Load the video to analyse
disp('Loading the input sequence...');
%sName = 'L:\Secuencias\Escenas Tracking\sb-camera1-0750am-0805am\frames';
%sName='C:\Users\rafa.ICAI\Dropbox\coches\videos\lankershim-camera3-0830am-0845am.avi';
%sName='C:\Users\rafa.ICAI\Dropbox\coches\videos\sb-camera3-0820am-0835am.avi';
%sName = 'C:\Users\rafa.ICAI\Dropbox\coches\videos\sb-camera2-0750am-0805am.avi';
sName = 'C:\Users\Rafa\Google Drive\coches\videos\sb-camera2-0750am-0805am_red.avi';
%sName='C:\Users\rafa.ICAI\Dropbox\coches\videos\hormigas.avi';
%sName='video.avi';
fInfo = loadSequence(sName);

hFigure = figure; 
h = subplot(1,1,1);
frame = getFrame(fInfo,1);

imshow(frame,'parent', h);
title(h,['Frame nº ' num2str(1)]);


ini = input('Seleccione el fotograma de comienzo: ');


frame = getFrame(fInfo,ini);

imageHandle =  imshow(frame,'parent', h);
title(h,['Frame nº ' num2str(ini)]);

set(hFigure,'Pointer','crosshair');

id = round(rand*now);

set(imageHandle,'ButtonDownFcn',@ImageClickCallback);
set(hFigure,'KeyPressFcn', @key_pressed_fcn);

% confirmacion = 'S';
% while confirmacion == 'S'
%     ini = input('Seleccione el fotograma de comienzo: ');
% 
% 
%     frame = getFrame(fInfo,ini);
% 
%     imshow(frame,'parent', h);
%     title(h,['Frame nº ' num2str(i)]);
% 
%     id = round(rand*now);
%     input('El ID del coche a marcar es: ');
% 
%     for i=ini:fInfo.NumFrames
%         frame = getFrame(fInfo,i);
% 
%         imshow(frame,'parent', h);
%         title(h,['Frame nº ' num2str(i) ', ID coche: ' num2str(id)]);
% 
% 
%         di*sp('Pulse una tecla para continuar...');
%         pause();
%     end
% 
%     confirmacion = input('¿Desea continuar marcando coches? (S para continuar, N para salir):');
% end
% 

    function ImageClickCallback ( objectHandle , eventData )

      axesHandle  = get(objectHandle,'Parent');
       
      if strcmpi(get(gcf, 'SelectionType'), 'alt') == 1
        ini = ini + 1;

        frame = getFrame(fInfo,ini);

      elseif   strcmpi(get(gcf, 'SelectionType'), 'normal') == 1
          
        coordinates = get(axesHandle,'CurrentPoint'); 
        coordinates = coordinates(1,1:2);
        disp([num2str(id) ' ' num2str(ini) ' ' num2str(coordinates(1)) ' ' num2str(coordinates(2))]);
        %fprintf(1,'%d x: %.1f , y: %.1f',ini, coordinates (1) ,coordinates (2));

        ini = ini + 1;

        frame = getFrame(fInfo,ini);

      end
      set(objectHandle, 'CData', frame)
      title(axesHandle,['Frame nº ' num2str(ini) ', ID coche: ' num2str(id)]);

    end

    function key_pressed_fcn ( fig_obj , eventData )
        if strcmpi(get(fig_obj, 'CurrentKey'), 'return') 
            ini = input('Seleccione el fotograma de comienzo: ');
            frame = getFrame(fInfo,ini);
            id = round(rand*now);
            set(imageHandle, 'CData', frame)
            title(h,['Frame nº ' num2str(ini) ', ID coche: ' num2str(id)]);
         
        end
     
    end

    
end

