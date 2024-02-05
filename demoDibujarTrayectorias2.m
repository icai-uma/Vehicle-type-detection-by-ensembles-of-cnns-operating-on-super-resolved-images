clear all
lista_ID = [422 408 426 2776]; %corte

params.MatlabProjectsDirectory = '../../../../proyectos_matlab/';
params.TrajectoryDirectory = strcat(params.MatlabProjectsDirectory,'coches/');
frame_avg = imread(strcat(params.TrajectoryDirectory,'Results/Para la revision/sb3_background.bmp'));


params.MatlabProjectsDirectory = '../../../../proyectos_matlab/';
params.TrajectoryWithRepresentativeDirectory = strcat(params.MatlabProjectsDirectory,'coches/datosBlobs/trajectoriesWithRepresentative/');

infoFiles = dir(params.TrajectoryWithRepresentativeDirectory);

for j=1:size(lista_ID,2)
i=1;
found=0;

trajectoryId = lista_ID(j);

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
                
                newkModel.SavedTrayectories(j) = kModel.SavedTrayectories(ndxTrajectoryId);
                found = 1;
            end
        end
    end
    i=i+1;
end
if i > length(infoFiles) && found == 0
    disp('Error: trajectoryId not found');
end
end

%% Secuencia sb3
% Con corte
%lista_ID = [115 117 122 119 157 158 227 228 296 297 501 500];

%lista_ID = [115 117 157 153 156]; %corte
%lista_ID = [227 228 296];

%lista_ID = [115 117 120 154 157 161 165 168 178]; %sinCorte

% 
% frame_avg = imread('C:\Users\Rafa\Google Drive\coches\Results\Para la revision\sb3_background.bmp');
% kModel = load('C:\Users\Rafa\Google Drive\coches\Results\Para la revision\kModel_sb3_corte.mat'); %corte
% 
% %kModel = load('C:\Users\Rafa\Google Drive\coches\Results\Para la revision\kModel_660_sb3_sinCorte.mat'); %sincorte
% 
% dibujarInfoObjetoTrayectoria(lista_ID, kModel.kModel.SavedTrayectories,frame_avg);

%% Secuencia lankershim
%frame_avg = imread(strcat(params.TrajectoryDirectory,'Results/Para la revision/lk_background.bmp'));

%frame_avg = imread('C:\Users\Rafa\Google Drive\coches\Results\Para la revision\lk_background.bmp');

%lista_ID = [60 75]; %corte

%kModel = load(strcat(params.TrajectoryDirectory,'Results/Para la revision/kModel_sb3_corte.mat')); %corte

%lista_ID = [49 51]; %sinCorte
%kModel = load('C:\Users\Rafa\Google Drive\coches\Results\Para la revision\kModel_660_sb3_sinCorte.mat'); %sincorte

%dibujarInfoObjetoTrayectoria(lista_ID, kModel.kModel.SavedTrayectories,frame_avg);
dibujarInfoObjetoTrayectoria(lista_ID, newkModel.SavedTrayectories,frame_avg);

