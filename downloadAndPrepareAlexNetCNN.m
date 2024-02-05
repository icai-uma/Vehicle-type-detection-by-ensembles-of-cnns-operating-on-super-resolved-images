% Copyright 2016 The MathWorks, Inc.

function downloadAndPrepareAlexNetCNN()
% Downloads AlexNet CNN in MatConvNet format and converts to SerialNetwork
params.MatlabProjectsDirectory = '../../../../proyectos_matlab/';
params.TrainedCNNDirectory = strcat(params.MatlabProjectsDirectory,'trained_cnn/');

mkdir(fullfile(params.TrainedCNNDirectory,'matconvnet'));
cnnMatFile = fullfile(params.TrainedCNNDirectory, 'matconvnet', 'imagenet-cnn.mat');
synsetsFile = fullfile(params.TrainedCNNDirectory, 'matconvnet', 'synsetMap.mat');

if ~exist(cnnMatFile,'file')
    
    cnnSourceMatFile  = fullfile(params.TrainedCNNDirectory, 'matconvnet', 'imagenet-caffe-alex.mat');
    cnnURL = 'http://www.vlfeat.org/matconvnet/models/beta16/imagenet-caffe-alex.mat';

    if ~exist(cnnSourceMatFile,'file') % download only once
        disp('Downloading 233MB AlexNet pre-trained CNN model. This may take several minutes...');
        websave(cnnSourceMatFile, cnnURL);
    end
    convnet = helperImportMatConvNet(cnnSourceMatFile);

    save(cnnMatFile, 'convnet');
end

if ~exist('convnet', 'var')
    imagenet_cnn = load(cnnMatFile);
    convnet = imagenet_cnn.convnet;
end

% if ~exist(synsetsFile,'file')
%     addpath(fullfile(pwd, 'WebcamClassification'));
%     synsets2words(convnet);
%     rmpath(fullfile(pwd, 'WebcamClassification'));
% end
