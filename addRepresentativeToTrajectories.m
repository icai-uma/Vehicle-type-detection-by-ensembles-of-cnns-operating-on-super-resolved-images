function addRepresentativeToTrajectories()

clear all
close all
warning off
rng('default');

NumMinAssociations = 30;

params.MatlabProjectsDirectory = '../../../../proyectos_matlab/';
params.TrajectoryDirectory = strcat(params.MatlabProjectsDirectory,'coches/datosBlobs/');

newTrajectoriesDirectory = strcat(params.TrajectoryDirectory,'trajectoriesWithRepresentative/');
[stat, mess, id] = rmdir(newTrajectoriesDirectory, 's'); % Delete the directory and its files if it was created
mkdir(newTrajectoriesDirectory);

infoFiles = dir(params.TrajectoryDirectory);
cont = 1;

for i=1:length(infoFiles)
    if (infoFiles(i).isdir == 0)
        
        filename = infoFiles(i).name;
        [pathstr, name, ext] = fileparts(filename);
        % Take only the .mat files
        if (strcmpi(ext,'.mat') == 1) % && (strcmpi(name,'kModel_293') == 1)
            path_mat = strcat(params.TrajectoryDirectory,filename);
            load(path_mat);
            disp(strcat(name, ' file is computing...'));
            % For each trajectory
            for j=1:size(kModel.SavedTrayectories,2)
                %if kModel.SavedTrayectories(j).numVecesMatching > NumMinAssociations  % trajectories with more than NumMinAssociations
                    % Choose the representative car: the median area of all associated areas to the trajectory j
                    AreasTrajectory = int64([kModel.SavedTrayectories(j).features.Area]);
                    SortedAreasTrajectory = sort(AreasTrajectory);
                    % la mediana de matlab devuelve la media de los valores
                    % del medio del array ordenado. Ejemplo: median(int64([ 1 3 5 7]))
                    %%%MedianArea = median(AreasTrajectory);
                    numAreas = numel(SortedAreasTrajectory);
                    if mod(numAreas,2) == 0
                        medianIdx = numAreas/2;
                    else
                        medianIdx = (numAreas + 1)/2;
                    end
                    Representative.Area = SortedAreasTrajectory(medianIdx);
                    RepresentativeObjectNdx = find(AreasTrajectory==Representative.Area);
                    Representative.Ndx = RepresentativeObjectNdx(1); %it can be more than one representative object and we only want one

                    % Calculate the features area, height, width (already in the mat), perimeter, solidity and the median colour of the representative car
                    %doc regionprops
                    % BoundingBox esta guardado como [ul_corner width] donde width es [x_width y_width]
                    statsRepresentativeObject = regionprops(kModel.SavedTrayectories(j).features(Representative.Ndx).ConvexImage, 'Perimeter', 'Solidity', 'BoundingBox');
                    Representative.Solidity = statsRepresentativeObject.Solidity;
                    Representative.Perimeter = statsRepresentativeObject.Perimeter;
                    Representative.BoundingBox = statsRepresentativeObject.BoundingBox;
                    Representative.DefinedVehicleType = '';
                    
                    % The median colour is calculated analysing all the associated pixels to the car and applying the median
                    % First we obtain the indexs of the foreground pixels from ConvexImage
                    ndxForegroundPixels = find(kModel.SavedTrayectories(j).features(Representative.Ndx).ConvexImage==1);
                    % Then we obtain the values (colour) of the foreground pixels from the image
                    R = kModel.SavedTrayectories(j).features(Representative.Ndx).imagen(:,:,1);
                    G = kModel.SavedTrayectories(j).features(Representative.Ndx).imagen(:,:,2);
                    B = kModel.SavedTrayectories(j).features(Representative.Ndx).imagen(:,:,3);
                    RForegroundPixels = R(ndxForegroundPixels);
                    GForegroundPixels = G(ndxForegroundPixels);
                    BForegroundPixels = B(ndxForegroundPixels);
                    % Finally we calculate the median to these values
                    Representative.medianColour(1) = median (RForegroundPixels);
                    Representative.medianColour(2) = median (GForegroundPixels);
                    Representative.medianColour(3) = median (BForegroundPixels);
                    
                    Representative.ConvexImage = kModel.SavedTrayectories(j).features(Representative.Ndx).ConvexImage;
                    Representative.Image = kModel.SavedTrayectories(j).features(Representative.Ndx).imagen;
                    
                    % Save data
                    kModel.SavedTrayectories(j).Representative = Representative;

%                     subplot(1,3,1),imshow(Representative.Image);
%                     subplot(1,3,2),imshow(Representative.ConvexImage);
%                     subplot(1,3,3),imshow(Representative.medianColour);
%                     pause(0.1);

                    % agrupar trayectorias utilizando el modelo que consideréis (autoorganizado, kmeans, etc.).
                    
                %end
            end
            save(strcat(newTrajectoriesDirectory,'/',name,'.mat'),'kModel');
            disp(strcat(filename, ' file finished...'));
            cont = cont + 1;
        end
    end
end



