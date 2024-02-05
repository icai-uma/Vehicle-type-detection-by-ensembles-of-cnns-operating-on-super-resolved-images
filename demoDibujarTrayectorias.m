params.MatlabProjectsDirectory = '../../../../proyectos_matlab/';
params.TrajectoryDirectory = strcat(params.MatlabProjectsDirectory,'coches/');


%% Secuencia sb3
% Con corte
%lista_ID = [115 117 122 119 157 158 227 228 296 297 501 500];

lista_ID = [115 117 157 153 156]; %corte
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
frame_avg = imread(strcat(params.TrajectoryDirectory,'Results/Para la revision/sb3_background.bmp'));
%frame_avg = imread('C:\Users\Rafa\Google Drive\coches\Results\Para la revision\lk_background.bmp');

%lista_ID = [60 75]; %corte
lista_ID = [422 75]; %corte
kModel = load(strcat(params.TrajectoryDirectory,'Results/Para la revision/kModel_sb3_corte.mat')); %corte

%lista_ID = [49 51]; %sinCorte
%kModel = load('C:\Users\Rafa\Google Drive\coches\Results\Para la revision\kModel_660_sb3_sinCorte.mat'); %sincorte

dibujarInfoObjetoTrayectoria(lista_ID, kModel.kModel.SavedTrayectories,frame_avg);

