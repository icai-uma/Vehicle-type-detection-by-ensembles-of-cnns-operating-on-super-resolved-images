function []=AutomatedTestBMsinglethread(SelectedFeatures,VideoFileSpec,deltaFrame,numFrames,epsilon)
% Batch mode background modeling test, single thread version

% Create the structures of the stochastic approximation model
VideoFrame=double(imread(sprintf(VideoFileSpec,deltaFrame+1)));
FeatureFrame=ExtractFeatures(VideoFrame,SelectedFeatures);
model = createBM(FeatureFrame);
model.Epsilon=epsilon;

% model.NumPatterns=43;

% Allocate scape for the set of images to initialise the model 
FirstFrames = zeros(size(FeatureFrame,1),size(FeatureFrame,2),size(FeatureFrame,3),model.NumPatterns);
FirstFrames(:,:,:,1) = FeatureFrame;

% Store the frames
for NdxFrame=2:model.NumPatterns
    VideoFrame=double(imread(sprintf(VideoFileSpec,deltaFrame+NdxFrame)));
    FeatureFrame=ExtractFeatures(VideoFrame,SelectedFeatures);
    FirstFrames(:,:,:,NdxFrame) = FeatureFrame;
end

% Initialize the model using a set of frames
model = initializeBM_MEX(model,FirstFrames); 

% Estimate the noise of the sequence
model.Noise = estimateNoise(model);

for NdxFrame=model.NumPatterns+1:numFrames
    VideoFrame=double(imread(sprintf(VideoFileSpec,deltaFrame+NdxFrame)));
    tic
    FeatureFrame=ExtractFeatures(VideoFrame,SelectedFeatures);
    [model,imMask,resp]=updateBM_MEXsingle(model,FeatureFrame);
    toc
    fprintf('Frame %d processed.\r\n',NdxFrame);
    %imwrite(imMask<0.5,(sprintf(strcat('../../../../proyectos_matlab/Videos/ImagenesSegmentadas','/in%06d.jpg'),deltaFrame+NdxFrame)));
    
    %if ispc
        subplot(1,2,1),imshow(uint8(VideoFrame));
        subplot(1,2,2),imshow(imMask<0.5);
        title(NdxFrame);
        pause(0.001);
    %end
end

fprintf('Process finished.\r\n',NdxFrame);