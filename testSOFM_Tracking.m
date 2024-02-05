% Demo code for the paper
% Stochastic approximation for background modelling
% Computer Vision and Image Understanding, DOI: 10.1016/j.cviu.2011.01.007
% Coded by R.M.Luque and Ezequiel Lopez-Rubio -- February 2011 

warning('off','all')
%clear all
close all;
captura = 0;
addpath('./mmread');
addpath('./WeightedMoG2');
addpath('../src');
% Load the video to analyse
disp('Loading the input sequence...');
%sName = 'L:\Secuencias\Escenas Tracking\sb-camera1-0750am-0805am\frames';
%sName='C:\Users\rmluque\Google Drive\coches\videos\sb-camera2-0750am-0805am.avi';
%sName='C:\Users\rafa.ICAI\Google Drive\coches\videos\sb-camera3-0820am-0835am.avi';
%sName = 'C:\Users\rafa.ICAI\Google Drive\coches\videos\sb-camera2-0750am-0805am.avi';
%sName = 'C:\Users\rafa.ICAI\Google Drive\coches\videos\sb-camera2-0750am-0805am_red.avi';
%sName='C:\Users\rafa.ICAI\Dropbox\coches\videos\hormigas.avi';
%sName='video.avi';

params.MatlabProjectsDirectory = '/home/icai21/Modelos/codigos/icae/';
params.CarsVideosDirectory = strcat(params.MatlabProjectsDirectory,'iwinac/videos/');

sName=strcat(params.CarsVideosDirectory,'sb-camera2-0750am-0805am.avi');
fInfo = loadSequence(sName);
global frame;

% Ground Truth with regard to the number of vehicles in each frame
if exist([sName(1:end-3) 'txt'],'file')
    GTcounter = load([sName(1:end-3) 'txt']);
end
splitted = 0;

frame = getFrame(fInfo,1);
%d=mmread(sName,1);

% Create the structures of the stochastic approximation model
disp('Creating the structures of the stochastic approximation model...');
model = createAEModel(frame);

% Create the structures of postprocessing if it is activated
if model.PostprocessingEnabled
    disp('Creating the structures of the postprocessing model...');
    postModel = createPostprocessingModel(frame);
    postModel.SOFM = createSOFMModel;
end

%Create the structures of tracking model if it is activated
if model.TrackingEnabled
    disp('Creating the structures of the kalman model tracking...');
    kModel = createKalmanModel(frame);
    kModel.path = postModel.path;
    
end
    
model.LastFrame = fInfo.NumFrames;

% Allocate scape for the set of images to initialise the model 
images = zeros(size(frame,1),size(frame,2),size(frame,3),model.NumPatterns);
images(:,:,:,1) = uint8(frame);

% Store the frames
images(:,:,:,2:model.NumPatterns) = getFrame(fInfo,2:model.NumPatterns);
images = uint8(images);

disp('Initialising the model...');
% Initialize the model using a set of frames
model = initializeAE_MEX(model,images); 

% Estimate the noise of the sequence
model.Noise = estimateNoise(model);
%model.Noise = [0.5 0.5 0.5];
% Load a temporary image
nodisponible = imread('nodisponible.jpg');

trainingSamples = [];

if captura 
    mov = avifile([postModel.path datestr(now,30) '.avi'], 'compression' , 'xvid','fps',25);
end

%d=mmread(sName);
%scrsz = get(0,'ScreenSize');
%hand = figure('PaperSize',[20.98 29.68],'Position',[scrsz(1) scrsz(2) scrsz(3) scrsz(4)]);

[hand, h1, h2, h3, h4] = createfigure_representation;

%subplot(2,2,1);
disp('Analysing the model...');
for i=1:fInfo.NumFrames
    
    disp(sprintf('%d frame - start',i));
    th = tic();
    
    frame = getFrame(fInfo,i);
    [model,imMask,resp]=updateAE_MEX(model,frame);
    postModel.imMask_prob = imMask;
    postModel.frame = frame;
    
    imMask = (1 - imMask) >= 0.5;

    if i > postModel.Start
        postModel = Postprocessing(postModel, imMask);

        [currentSamples, idxBlobs] = blob2samples(postModel);
        
        if i >= postModel.StartModellingObjects
            if i == postModel.StartModellingObjects
                postModel.SOFM = InitialTrainingSOFM3(postModel, trainingSamples, postModel.StartModellingObjects);
                [currentSamples, idxBlobs] = blob2samples(postModel);
            end
     
%             h4 = subplot(2,2,4); 
%             fondo = uint8(shiftdim(squeeze(model.Mu),1));
%             imshow(fondo, 'parent', h4);
%             visualizeSOFM(postModel, h4);
%             %drawZones(postModel, fondo, h4);
%             title(h4,'Zone Analysis');    
    
        
            
            [postModel.SOFM,Winners,Errors,Distances] = UpdateSOFM(postModel.SOFM, currentSamples, i);
            
            postModel = detectUnusualObjectsSOFM(postModel,Winners,Errors,idxBlobs);
            
            %dibujarObjetosDetectados(postModel.blobs,h3);
        end
        
        if i < postModel.StartModellingObjects
            trainingSamples = [trainingSamples currentSamples];
        end
        
        %postModel = updateZones(postModel,i);
        
        disp(sprintf('%d cutting objects',i));
        
        if i >= postModel.StartCuttingObjects
            [postModel, splitted] = splitObjects_new(postModel, i, Winners,idxBlobs);
            
            if splitted > 0
                [currentSamples, idxBlobs] = blob2samples(postModel);
                [Winners,Errors,Distances] = TestingSOFM(postModel.SOFM, currentSamples, i);
                postModel = detectUnusualObjectsSOFM(postModel,Winners,Errors,idxBlobs);
            end
    
        end
        
        disp(sprintf('%d Kalman',i));
    
        tKalman = tic;
        kModel = trackKalman(kModel, postModel.blobs, i);
        tKalman = toc(tKalman);
        %disp(['Time of tracking process: ' num2str(tKalman) ' seg.']);

        imshow(frame, 'parent', h3);
        tKalman_v = tic;
        kalmanObjectsVisualization(kModel.objects,h3);
        tKalman_v = toc(tKalman_v);
        %disp(['Time of visualization of tracking process: ' num2str(tKalman_v) ' seg.']);
        title(h3,'Tracking');
        
        disp(sprintf('%d postprocessing',i));
        
        imMask_postprocessed = postModel.coloredImage;
        %imshow(imMask_postprocessed,'InitialMagnification','fit','parent', h3);
        %title(h3,'Postprocessing');    
    
        
        
        if i >= postModel.StartCuttingObjects
            %drawUnusualObjects(postModel,h3);   
            if splitted > 0 && postModel.debug 
                saveas(hand, [postModel.path num2str(i,'%5.6d') '_frame.jpg']);
            end
            
            if i == 350
                pause(0.001);
            end
            
            if i == 290
                pause(0.001);
            end
            
            tKalman_v = tic;
            kModel = deepLabellingVehicles(kModel,postModel);            
            frameAnotated = visualizationLabellingVehicles(kModel.objects,frame);
            
            
            
            imshow(frameAnotated, 'parent', h4);
            tKalman_v = toc(tKalman_v);
            disp(['Time of deep testing process: ' num2str(tKalman_v) ' seg.']);
            title(h4,'Vehicle Classification');    
            imwrite(frameAnotated,[postModel.path num2str(i,'%5.6d') '_labelling.jpg']);    
            saveas(gca, [postModel.path num2str(i,'%5.6d') '_image_counterNOGT.jpg']);
        end
      
    else
        %subplot(2,2,3); 
        imshow(uint8(nodisponible),'InitialMagnification','fit','parent', h3);
    end
    
    % Visualization
    %subplot(2,2,1),
    %subplot(2,2,2); 
    imshow(imMask,'InitialMagnification','fit','parent', h2);
    title(h2,'Raw segmentation');

    imshow(frame,'parent', h1);
    title(h1,['Frame no. ' num2str(i)]);
    
    % NOTE: there is a delay of one frame in GT counter (i-1)
    if exist([sName(1:end-3) 'txt'],'file')
        postModel = vehiclesCounter(i-1,GTcounter, postModel);
    end
    if splitted > 0
        %saveas(gca, [postModel.path num2str(i-1,'%5.6d') '_image_counterNOGT.jpg']);
    end
%     if mod(i,200) == 0
%         save([postModel.path 'kModel.mat'], 'kModel');
%     end
%         postModel.debug = 0;
%     end
%     
%     if mod(i,1000) == 0
%         postModel.vehicleCounter
%     end

    if captura
       F = getframe(hand);
        mov = addframe(mov,F);
    end
    
    t_frame = toc(th);
    fprintf('%d time: %.3fs\n', i, t_frame);
    
    disp(sprintf('%d frame - end',i));
    pause(0.1);
    hold on;
    
    pause(0.01);
end
if captura
    mov = close(mov);
end
disp('End of the process');

