% Demo code for the paper
% Stochastic approximation for background modelling
% Computer Vision and Image Understanding, DOI: 10.1016/j.cviu.2011.01.007
% Coded by R.M.Luque and Ezequiel Lopez-Rubio -- February 2011 

%clear all
addpath('./mmread');

% Load the video to analyse
disp('Loading the input sequence...');
%sName = 'L:\Secuencias\Escenas Tracking\sb-camera1-0750am-0805am\frames';
sName='L:\Secuencias\TrafficSurveillance\sb-camera2-0750am-0805am_red.avi';
%sName='video.avi';
fInfo = loadSequence(sName);

frame = getFrame(fInfo,1);
%d=mmread(sName,1);

% Create the structures of the stochastic approximation model
disp('Creating the structures of the stochastic approximation model...');
model = createAEModel(frame);

% Create the structures of postprocessing if it is activated
%if model.PostprocessingEnabled
    disp('Creating the structures of the postprocessing model...');
    postModel = createPostprocessingModel(frame);
    postModel.zonas = ZoneDefinition([size(frame,1) size(frame,2)]);
%end

% Create the structures of tracking model if it is activated
%if model.TrackingEnabled
    %disp('Creating the structures of the kalman model tracking...');
    %kModel = createKalmanModel(frame);
%end
    
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

objects = [];
%d=mmread(sName);
h = figure;
subplot(2,2,1);
disp('Analysing the model...');
for i=1:fInfo.NumFrames
    frame = getFrame(fInfo,i);
    [model,imMask,resp]=updateAE_MEX(model,frame);
    imMask = (1 - imMask) >= 0.5;

    if i > postModel.Start
        postModel = Postprocessing(postModel, imMask);
 %       kModel = trackKalman(kModel, postModel.blobs, i);
                
        if i > postModel.StartCuttingObjects
            postModel = detectUnusualObjects(postModel);
            %obj_detectados = splitObjects2(postModel, postModel.blobs, postModel.cleanMask);
            %dibujarObjetosDetectados(potModel.blobs,h3);
        end
        
        postModel = updateZones(postModel,i);
        
        h4 = subplot(2,2,4); 
        
        fondo = uint8(shiftdim(squeeze(model.Mu),1));
        drawZones(postModel, fondo, h4);
        title('Zone Analysis');    
        
        imMask_postprocessed = postModel.coloredImage;
        h3 = subplot(2,2,3); imshow(imMask_postprocessed,'InitialMagnification','fit');
        title('Postprocessing');    
      
    else
        subplot(2,2,3); imshow(uint8(nodisponible),'InitialMagnification','fit');
    end
    
    % Visualization
    subplot(2,2,1),imshow(frame);
    title(['Frame nº ' num2str(i)]);
    subplot(2,2,2); imshow(imMask,'InitialMagnification','fit');
    title('Raw segmentation');
    
    tic;
%    kalmanObjectsVisualization(kModel.objects,subplot(1,2,1));
    toc;
    pause(0.01);
end
disp('End of the process');

