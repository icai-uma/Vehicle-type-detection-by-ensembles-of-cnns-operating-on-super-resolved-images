function generateVehiclesImagesTrainingCNN()

%% MOTO %%
% 422 tiene 95 numVecesMatching
saveImage(422,10);
saveImage(422,20);
saveImage(422,30);
saveImage(422,40);
saveImage(422,50);
saveImage(422,60);
saveImage(422,70);
saveImage(422,80);

% 1029 tiene 54 numVecesMatching
saveImage(1029,5);
saveImage(1029,10);
saveImage(1029,15);
saveImage(1029,20);
saveImage(1029,30);
saveImage(1029,40);
saveImage(1029,45);

% 1146 tiene 33 numVecesMatching
saveImage(1146,5);
saveImage(1146,10);
saveImage(1146,15);
saveImage(1146,20);
saveImage(1146,25);
saveImage(1146,30);

% 3762 tiene 45 numVecesMatching
saveImage(3762,5);
saveImage(3762,10);
saveImage(3762,15);
saveImage(3762,20);
saveImage(3762,25);
saveImage(3762,30);
saveImage(3762,35);
saveImage(3762,40);

% 3959 tiene 101 numVecesMatching
saveImage(3959,10);
saveImage(3959,20);
saveImage(3959,30);
saveImage(3959,40);
% saveImage(3959,50);
% saveImage(3959,60);
% saveImage(3959,70);
% saveImage(3959,80);
% saveImage(3959,90);



%% CARS %%
saveImage(45,'');
saveImage(47,'');
%saveImage(49,'');
saveImage(596,'');
saveImage(608,'');
saveImage(873,'');
saveImage(1401,'');
saveImage(1403,'');
saveImage(1430,'');
saveImage(1431,'');
saveImage(1433,'');
saveImage(1606,'');
saveImage(1608,'');
saveImage(1613,'');
saveImage(1759,'');
saveImage(1864,'');
saveImage(1871,'');
saveImage(2070,'');
saveImage(2078,'');
saveImage(2180,'');
saveImage(2195,'');
saveImage(2196,'');
saveImage(2217,'');
saveImage(2219,'');
saveImage(2221,'');
%saveImage(2364,'');


%% VANS %%
saveImage(275,'');
saveImage(598,'');
saveImage(600,'');
saveImage(640,'');
saveImage(641,'');
%saveImage(642,'');
saveImage(853,'');
saveImage(1216,'');
saveImage(1226,'');
saveImage(1400,'');
saveImage(1425,'');
saveImage(1461,'');
%saveImage(1470,'');
%saveImage(1603,'');
%saveImage(1614,'');
saveImage(1767,'');
saveImage(1799,'');
saveImage(1801,'');
saveImage(1805,'');
saveImage(1808,'');
saveImage(1872,'');
saveImage(1979,'');
saveImage(1981,'');
saveImage(2372,'');
saveImage(2383,'');


%% TRUCKS %%
saveImage(17,'');
saveImage(582,'');
saveImage(607,'');
saveImage(630,'');
saveImage(1410,'');
saveImage(1610,'');
saveImage(1746,'');
saveImage(1866,'');
saveImage(1983,'');
saveImage(1984,'');
saveImage(1987,'');
saveImage(2061,'');
saveImage(2080,'');
saveImage(2093,'');
saveImage(2198,'');
saveImage(2222,'');
saveImage(2395,'');
%saveImage(2400,'');
%saveImage(2637,'');
saveImage(2662,'');
%saveImage(2666,'');
%saveImage(3031,'');
%saveImage(3101,'');
%saveImage(3103,'');
saveImage(3308,'');
saveImage(4209,'');
saveImage(4239,'');
%saveImage(4239,10);



%%% CARS test
saveImage(40,'');
%saveImage(37,'');
saveImage(34,'');
saveImage(51,'');
saveImage(55,'');
saveImage(57,'');
saveImage(56,'');
saveImage(60,'');
saveImage(118,'');
saveImage(108,'');

%%% VANS test
%saveImage(61,'');
saveImage(70,'');
saveImage(65,'');
saveImage(93,'');
saveImage(89,'');
saveImage(97,'');
saveImage(165,'');
%saveImage(150,'');
saveImage(185,'');
saveImage(176,'');

%%% TRUCKS test
saveImage(66,'');
saveImage(68,'');
saveImage(144,'');
saveImage(193,'');
saveImage(340,'');
saveImage(346,'');
%saveImage(341,'');
%saveImage(708,'');
saveImage(853,'');
%saveImage(860,'');




%%% 2 TEST
saveImage(1746,'');
saveImage(1734,'');
saveImage(1866,'');
saveImage(1983,'');
saveImage(1984,'');
saveImage(1987,'');
%saveImage(2012,'');
saveImage(2080,'');
saveImage(2222,'');
saveImage(2292,'');
saveImage(2395,'');
saveImage(2402,'');
%saveImage(2421,'');
%saveImage(2598,'');
%saveImage(2666,'');
saveImage(2776,'');
saveImage(2787,'');

saveImage(1745,'');
saveImage(1722,'');
saveImage(1741,'');
saveImage(1872,'');
saveImage(1871,'');
saveImage(1979,'');
saveImage(1981,'');
saveImage(1978,'');
saveImage(2115,'');
saveImage(2123,'');
saveImage(2120,'');
saveImage(2133,'');
saveImage(2231,'');
saveImage(2236,'');
saveImage(2244,'');
saveImage(2241,'');
%saveImage(2332,'');
saveImage(2333,'');
saveImage(2404,'');
saveImage(2411,'');

saveImage(1679,'');
saveImage(1723,'');
saveImage(1703,'');
saveImage(1732,'');
saveImage(1736,'');
saveImage(1743,'');
saveImage(1677,'');
saveImage(1740,'');
saveImage(1874,'');
saveImage(1878,'');
saveImage(1867,'');
saveImage(1881,'');
saveImage(1863,'');
saveImage(1976,'');
saveImage(1971,'');
saveImage(1964,'');
saveImage(1986,'');
saveImage(1985,'');



function saveImage(trajectoryId,featureId) %podemos elegir el feature para obtener distintas imagenes de un mismo objeto

params.MatlabProjectsDirectory = '../../../../proyectos_matlab/';
params.TrajectoryWithRepresentativeDirectory = strcat(params.MatlabProjectsDirectory,'coches/datosBlobs/trajectoriesWithRepresentative/');

infoFiles = dir(params.TrajectoryWithRepresentativeDirectory);

i=1;
found=0;

while i <= length(infoFiles) && found == 0
    if (infoFiles(i).isdir == 0)         
        filename = infoFiles(i).name;
        [pathstr, name, ext] = fileparts(filename);
        
        % Take only the .mat files
        if (strcmpi(ext,'.mat') == 1)
            path_mat = strcat(params.TrajectoryWithRepresentativeDirectory,filename);
            load(path_mat);
            disp(strcat(filename, ' file is computing...'));
            ndxTrajectoryId = find([kModel.SavedTrayectories.ID]==trajectoryId);
            if size(ndxTrajectoryId,2) == 1
                %disp(strcat('Trajectory ', num2str(trajectoryId), ' founded in file ', filename,'...')); 
                disp(sprintf('Trajectory %s founded in file %s in row %s...',num2str(trajectoryId),filename,num2str(ndxTrajectoryId)));
                Representative = kModel.SavedTrayectories(ndxTrajectoryId).Representative;

                if ~(strcmpi(featureId,'') == 1)
                    im = kModel.SavedTrayectories(ndxTrajectoryId).features(featureId).imagen;
                else
                    im = kModel.SavedTrayectories(ndxTrajectoryId).Representative.Image;
                    featureId = Representative.Ndx;
                end
                %resize
                %imshow(im);
                %im = imresize(im, [227 227]) ;
                
                %fill
%                 imresized = zeros(227,227,3,'uint8');
%                 imresized(1:size(im,1), 1:size(im,2),:) = im(:,:,:);
%                 im=imresized;
                
                imwrite(im,sprintf(strcat(params.TrajectoryWithRepresentativeDirectory,'selectedVehiclesWithoutFill/',Representative.DefinedVehicleType,'/%04d-%02d.jpg'),trajectoryId,featureId));
                %%%imwrite(im,sprintf(strcat(params.TrajectoryWithRepresentativeDirectory,'selectedVehiclesTrainingCNN/',Representative.DefinedVehicleType,'s/%04d-%02d.jpg'),trajectoryId,featureId));
                %%%imwrite(im,sprintf(strcat(params.TrajectoryWithRepresentativeDirectory,'selectedVehiclesTestCNN/',Representative.DefinedVehicleType,'/%04d-%02d.jpg'),trajectoryId,featureId));

                found = 1;
            end
        end
    end
    i=i+1;
end
if i > length(infoFiles) && found == 0
    disp('Error: trajectoryId not found');
end






