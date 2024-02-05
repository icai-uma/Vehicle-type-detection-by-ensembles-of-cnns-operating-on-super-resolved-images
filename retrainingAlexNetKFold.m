%% Fine Tuning A Deep Neural Network
% This example shows how to fine tune a pre-trained deep convolutional
% neural network (CNN) for a new recognition task.

% Copyright 2016 The MathWorks, Inc.

%% Check System Requirements
% Get GPU device information
%rng('default');
deviceInfo = gpuDevice;
% Check the GPU compute capability
computeCapability = str2double(deviceInfo.ComputeCapability);
assert(computeCapability > 3.0, 'This example requires a GPU device with compute capability 3.0 or higher.')
% Mi pc de la univ tiene computeCapability = 5


%% Load network
params.MatlabProjectsDirectory = '../../../../proyectos_matlab/';
params.TrainedCNNDirectory = strcat(params.MatlabProjectsDirectory,'trained_cnn/');
cnnMatFile = fullfile(params.TrainedCNNDirectory, 'matconvnet', 'imagenet-cnn.mat');
if ~exist(cnnMatFile,'file')
    disp('Run downloadAndPrepareAlexNetCNN.m to download and prepare the CNN');
    return;
end
imagenet_cnn = load(cnnMatFile);
net = imagenet_cnn.convnet;


%% Look at structure of pre-trained network
% Notice the last layer performs 1000 object classification
net.Layers

%% Perform net surgery
% The pre-trained layers at the end of the network are designed to classify
% 1000 objects. But we need to classify 2 different objects now. So the
% first step in transfer learning is to replace the last 3 layers of the
% pre-trained network with a set of layers that can classify 2 classes.

% Get the layers from the network. the layers define the network
% architecture and contain the learned weights. Here we only need to keep
% everything except the last 3 layers.
layers = net.Layers(1:end-3);

% Add new fully connected layer for 2 categories.
layers(end+1) = fullyConnectedLayer(4, 'Name', 'fc8_4');

% Add the softmax layer and the classification layer which make up the
% remaining portion of the networks classification layers.
layers(end+1) = softmaxLayer('Name','prob_4');
layers(end+1) = classificationLayer('Name','classificationLayer_4');

% Modify image layer to add randcrop data augmentation. This increases the
% diversity of training images. The size of the input images is set to the
% original networks input size.
layers(1) = imageInputLayer([227 227 3], 'DataAugmentation', 'randcrop');


%% Setup learning rates for fine-tuning
% For fine-tuning, we want to changed the network ever so slightly. How
% much a network is changed during training is controlled by the learning
% rates. Here we do not modify the learning rates of the original layers,
% i.e. the ones before the last 3. The rates for these layers are already
% pretty small so they don't need to be lowered further. You could even
% freeze the weights of these early layers by setting the rates to zero.
%
% Instead we boost the learning rates of the new layers we added, so that
% they change faster than the rest of the network. This way earlier layers
% don't change that much and we quickly learn the weights of the newer
% layer.

% fc 8 - bump up learning rate for last layers
layers(end-2).WeightLearnRateFactor = 100;
layers(end-2).WeightL2Factor = 1;
layers(end-2).BiasLearnRateFactor = 20;
layers(end-2).BiasL2Factor = 0;

%% Load Image Data
% Now we get the training data. This was collected as traffic drove into
% the MathWorks head office in Natick.
%
% Create an imageDataStore to read images
params.trainingVehiclesDirectory = strcat(params.MatlabProjectsDirectory,'coches/datosBlobs/trajectoriesWithRepresentative/kFold_data/1/train');

%location = 'selectedVehicles';
location = params.trainingVehiclesDirectory;
%imds = imageDatastore(location,'IncludeSubfolders',1,'LabelSource','foldernames');
trainingDS = imageDatastore(location);
fileID = fopen(strcat(params.trainingVehiclesDirectory,'/../train.txt'),'r');
C = textscan(fileID, '%s %d');
for i=1:160
    if C{1,2}(i) == 1
        category = 'moto';
    elseif C{1,2}(i) == 2
        category = 'car';
    elseif C{1,2}(i) == 3
        category = 'van';
    elseif C{1,2}(i) == 4
        category = 'truck';
    end
    
    trainingDS.Labels{i} = category;
end
fclose(fileID);
tbl = countEachLabel(trainingDS);


%% Equalize number of images of each class in training set
minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category
% Use splitEachLabel method to trim the set.
imds = splitEachLabel(imds, minSetCount);

% Notice that each set now has exactly the same number of images.
countEachLabel(imds)
[trainingDS, testDS] = splitEachLabel(imds,0.8,'randomize');
% [trainingDS, testDS, test2DS] = splitEachLabel(imds,0.8,0.1);
fprintf('trainingDS numel: %d \n',numel(trainingDS.Files));
fprintf('testDS numel: %d \n',numel(testDS.Files));
% fprintf('test2DS numel: %d \n',numel(test2DS.Files));
% Convert labels to categoricals
trainingDS.Labels = categorical(trainingDS.Labels);
trainingDS.ReadFcn = @readFunctionTrainCNN;

%% Setup test data for validation
testDS.Labels = categorical(testDS.Labels);
testDS.ReadFcn = @readFunctionValidationCNN;

% test2DS.Labels = categorical(test2DS.Labels);
% test2DS.ReadFcn = @readFunctionValidationCNN;

%% Fine-tune the Network

miniBatchSize = 30; % lower this if your GPU runs out of memory.
numImages = numel(trainingDS.Files);

% Run training for 5000 iterations. Convert 20000 iterations into the
% number of epochs this will be.
numIterationsPerEpoch = numImages/miniBatchSize;
%maxEpochs = round(20000/numIterationsPerEpoch);
maxEpochs = 50;
lr = 0.001;
opts = trainingOptions('sgdm', ...
    'InitialLearnRate', lr,...
    'LearnRateSchedule', 'none',...
    'L2Regularization', 0.0005, ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', miniBatchSize);

net = trainNetwork(trainingDS, layers, opts);
% Save the net
save(strcat(params.TrainedCNNDirectory,'proyectos/SOM_CutObjects/trainedNetClassifyVehiclesType.mat'),'net');

% This could take over an hour to run.

%% Test 2-class classifier on  validation set
% Now run the network on the test data set to see how well it does:

labels = classify(net, testDS, 'MiniBatchSize', 32);

confMat = confusionmat(testDS.Labels, labels);
confMat = bsxfun(@rdivide,confMat,sum(confMat,2));

fprintf('test accuracy: %.2f \n',mean(diag(confMat)));


% Second test (validation)
% labels = classify(net, test2DS, 'MiniBatchSize', 32);
% 
% confMat2 = confusionmat(test2DS.Labels, labels);
% confMat2 = bsxfun(@rdivide,confMat2,sum(confMat2,2));
% 
% fprintf('test2 accuracy: %.2f \n',mean(diag(confMat2)));


