function kModel = deepLabellingVehicles(kModel,postModel)
obj_kalman = kModel.objects;
p_root = '/home/icai21/Modelos/codigos/icae/iwinac';
kdir = '/trainedModel';

if exist('/home/icai21/Modelos/caffe-master/matlab/+caffe', 'dir')
    addpath('/home/icai21/Modelos/caffe-master/matlab');
else
    error('Please run this demo from caffe/matlab/demo');
end
use_gpu = 1;
% Set caffe mode
if exist('use_gpu', 'var') && use_gpu
    caffe.set_mode_gpu();
    gpu_id = 0;  % we will use the first gpu in this demo
    caffe.set_device(gpu_id);
else
    caffe.set_mode_cpu();
end

% Initialize the network using BVLC CaffeNet for image classification
% Weights (parameter) file needs to be downloaded from Model Zoo.
model_dir = [p_root kdir '/'];
data_dir = model_dir; 
net_model = [model_dir 'deploy.prototxt'];
%net_model = [model_dir 'train_val.prototxt'];
%net_weights = ['../../models/bvlc_reference_caffenet/' 'bvlc_reference_caffenet.caffemodel'];
net_weights = [model_dir 'snapshot_iter_1000.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
    error('Caffe model not found');
end

% Initialize a network
net = caffe.Net(net_model, net_weights, phase);

cont_time = 1;
tiempos = [];

areasNeurons = postModel.SOFM.Prototypes(3,:,:) * postModel.SOFM.GlobalDesv(3) + postModel.SOFM.GlobalMu(3);
areasNeurons = areasNeurons(:);
K = sqrt( median (areasNeurons));

for k=1:length(obj_kalman)
    if not(all(obj_kalman(k).features(end).ColorToDraw == [0.5 0.5 0.5])) % Si el objeto no está en el borde y se ve completo
        
        im = obj_kalman(k).features(end).imagen;
        %im = imread('../../examples/images/cat.jpg');
        %im2=FillRegion(im,256,256);
        %figure,imshow(im);
        
        %%%%% normalization - start
        % calculate distance from object to each neuron
        objPos = obj_kalman(k).xreal(end,:);
        objRow = objPos(1);
        objCol = objPos(2);
        distObjNeurons = zeros(4,4);
        
%         h4 = subplot(2,2,4); 
%         fondo = zeros(480,640,3);
%         imshow(fondo, 'parent', h4);
%         hold(h4,'on');
        for i=1:4
            for j=1:4
                xp = postModel.SOFM.Prototypes(1,i,j); % xp equivale a Col
                yp = postModel.SOFM.Prototypes(2,i,j); % yp equivale a Row
                area = postModel.SOFM.Prototypes(3,i,j) * postModel.SOFM.GlobalDesv(3) + postModel.SOFM.GlobalMu(3);
                radio = sqrt(area / pi);
                distObjNeurons(i,j) = sqrt((xp-objRow)^2 + (yp-objCol)^2);
                %circle([xp,yp], radio, 100, '-', [0 1 0], h4);
            end
        end
        
        pause(0.001);
        
        % select the closest neuron        
        [neuronRow , neuronCol] = find(distObjNeurons==min(min(distObjNeurons)));
        
        xp = postModel.SOFM.Prototypes(1,neuronRow,neuronCol); % xp equivale a Col
        yp = postModel.SOFM.Prototypes(2,neuronRow,neuronCol); % yp equivale a Row
        %area = postModel.SOFM.Prototypes(3,neuronRow,neuronCol) * postModel.SOFM.GlobalDesv(3) + postModel.SOFM.GlobalMu(3);
        %radio = sqrt(area / pi);
        %circle([xp,yp], radio, 100, '-', [0 0 1],h4);
        
        %circle([objRow,objCol], radio, 100, '-', [1 0 0],h4);
        %obj_kalman(k).ID      
       
        
        % select the learned area from the selected neuron
        neuronArea = postModel.SOFM.Prototypes(3,neuronRow,neuronCol) * postModel.SOFM.GlobalDesv(3) + postModel.SOFM.GlobalMu(3);
        %neuronArea = postModel.SOFM.Prototypes(6,neuronRow,neuronCol);
        
        % apply the normalization to the image
        im = imresize(im, K/sqrt(neuronArea), 'bicubic');        
        obj_kalman(k).features(end).imagen_normalizada = im;
        
        
        
        
        %%%%% normalization - end
        
        %%%%% superresolution - start
        
        %%%%% superresolution - end
        
        im = FillRegionScaleZeros(im,256,256,1.8551); % El último valor es el escalado y se ha calculado previamente 
        PreparedImages=prepare_image3(im,data_dir);
        input_data = {squeeze(PreparedImages(:,:,:,5))};
        
        %scores = net.forward({PreparedImages});
        tini = tic;
        scores = net.forward(input_data);
        tfin = toc(tini);
        tiempos(cont_time) = tfin;
        cont_time = cont_time + 1;
        %disp(scores{:});
        scores = scores{1};
        [~, PredictedLabel] = max(scores);
        % PARCHE
        PredictedLabel = PredictedLabel - 1;
        %cont = cont + 1;
        %disp(PredictedLabel);
        switch PredictedLabel
        case 1
            type = 'car';
        case 2
            type = 'moto';
        case 3
            type = 'truck';
        case 4
            type = 'van';
        end
        
        obj_kalman(k).features(end).type = type;   
        obj_kalman(k).features(end).idxType = PredictedLabel;
    end
end
mean(tiempos)
kModel.objects = obj_kalman;

% call caffe.reset_all() to reset caffe
caffe.reset_all();
