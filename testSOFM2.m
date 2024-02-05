% Demo code for the paper
% Stochastic approximation for background modelling
% Computer Vision and Image Understanding, DOI: 10.1016/j.cviu.2011.01.007
% Coded by R.M.Luque and Ezequiel Lopez-Rubio -- February 2011 

%clear all
close all;
captura = 0;
addpath('./mmread');

% Load the video to analyse
disp('Loading the input sequence...');
%sName = 'L:\Secuencias\Escenas Tracking\sb-camera1-0750am-0805am\frames';
sName='C:\Users\rafa.ICAI\Documents\coches\videos\sb-camera2-0750am-0805am.avi';
%sName='video.avi';
fInfo = loadSequence(sName);

frame = getFrame(fInfo,1);
%d=mmread(sName,1);

% Create the structures of the stochastic approximation model
disp('Creating the structures of the stochastic approximation model...');
model = createAEModel(frame);

% Create the structures of postprocessing if it is activated
disp('Creating the structures of the postprocessing model...');
postModel = createPostprocessingModel(frame);
postModel.SOFM = createSOFMModel;

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

% Load a temporary image
nodisponible = imread('nodisponible.jpg');

trainingSamples = [];

if captura 
    mov = avifile([datestr(now,30) '.avi'], 'compression' , 'iyuv','fps',50);
end

%d=mmread(sName);
scrsz = get(0,'ScreenSize');
%hand = figure('PaperSize',[20.98 29.68],'Position',[scrsz(1) scrsz(2) scrsz(3) scrsz(4)]);
hand = figure('Position',[1 scrsz(4)/4 4*scrsz(3)/4 scrsz(4)/2]);
subplot(1,3,1);
disp('Analysing the model...');
for i=1:fInfo.NumFrames
    frame = getFrame(fInfo,i);
    [model,imMask,resp]=updateAE_MEX(model,frame);
    postModel.imMask_prob = imMask;
    imMask = (1 - imMask) >= 0.5;
    
    if i > postModel.Start
        postModel = Postprocessing(postModel, imMask);
        
        [currentSamples, idxBlobs] = blob2samples(postModel);
        
        if i >= postModel.StartModellingObjects
            if i == postModel.StartModellingObjects
                postModel.SOFM = InitialTrainingSOFM3(postModel, trainingSamples, postModel.StartModellingObjects);
                [currentSamples, idxBlobs] = blob2samples(postModel);
            end
            
            h4 = subplot(1,3,3); 
            fondo = uint8(shiftdim(squeeze(model.Mu),1));
            imshow(fondo, 'parent', h4);
            visualizeSOFM(postModel, h4);
            %drawZones(postModel, fondo, h4);
            title('Zone Analysis');    
        
            [postModel.SOFM,Winners,Errors,Distances] = UpdateSOFM(postModel.SOFM, currentSamples, i);
            
            postModel = detectUnusualObjectsSOFM(postModel,Winners,Errors,idxBlobs);
            
            dibujarObjetosDetectados(postModel.blobs,h3);
        end
        
        if i < postModel.StartModellingObjects
            trainingSamples = [trainingSamples currentSamples];
        end
        
        %postModel = updateZones(postModel,i);
        
        
        
        imMask_postprocessed = postModel.cleanMask;
        h3 = subplot(1,3,2); imshow(imMask_postprocessed,'InitialMagnification','fit');
        title('Segmentation');
        
        if i >= postModel.StartCuttingObjects
            drawUnusualObjects(postModel,h3);
            
            postModel = splitObjects(postModel, i);
            
        end
                
        %title('Postprocessing');    
      
    else
        subplot(1,3,2); imshow(uint8(nodisponible),'InitialMagnification','fit');
    end
    
    % Visualization
    subplot(1,3,1),imshow(frame);
    title(['Frame nº ' num2str(i)]);
    %subplot(3,1,2); imshow(imMask,'InitialMagnification','fit');
    %title('Raw segmentation');

    if captura
        F = getframe(hand);
        mov = addframe(mov,F);
    end
    
    pause(0.01);
end
if captura
    mov = close(mov);
end
disp('End of the process');

