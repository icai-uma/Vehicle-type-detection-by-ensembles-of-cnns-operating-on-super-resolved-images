function frameT = deepLabellingVehicles(obj_kalman,ax,frame)
p_root = '/home/icai21/Modelos/codigos/icae/iwinac';
kdir = '/trainedModel';

if exist('/home/icai21/Modelos/caffe-master/matlab/+caffe', 'dir')
    addpath('/home/icai21/Modelos/caffe-master/matlab');
else
    error('Please run this demo from caffe/matlab/demo');
end

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

%hold(ax,'on');
grosor = 1;
posVehicle = [];
for k=1:length(obj_kalman)
        im = obj_kalman(k).features(end).imagen;
        %im = imread('../../examples/images/cat.jpg');
        %im2=FillRegion(im,256,256);
        %figure,imshow(im);
        im = FillRegionScaleZeros(im,256,256,1.8551); % El último valor es el escalado y se ha calculado previamente 
        PreparedImages=prepare_image3(im,data_dir);
        input_data = {squeeze(PreparedImages(:,:,:,5))};
        
        %scores = net.forward({PreparedImages});
        tic;
        scores = net.forward(input_data);
        toc;
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
            colorS = 'yellow';
        case 2
            type = 'moto';
            colorS = 'green';
        case 3
            type = 'truck';
            colorS = 'cyan';
        case 4
            type = 'van';
            colorS = 'red';
        
        end
        %text(obj_kalman(k).x(end,1),obj_kalman(k).x(end,2),num2str(obj_kalman(k).ID),'BackgroundColor',[.7 .7 .7],'Color', [1 1 1], 'FontSize',8,'Parent',ax);
        c = [obj_kalman(k).x(end,1)-(obj_kalman(k).dim(1)/2) obj_kalman(k).x(end,2)-(obj_kalman(k).dim(2)/2) obj_kalman(k).dim];
        posVehicle = [posVehicle; c(1), c(2), c(3), c(4)];
        %label_str{k} = [type ' ' num2str(obj_kalman(k).ID)];
        label_str{k} = type;
        color_str{k} = colorS;
        %rectangle('Position', [], 'EdgeColor',obj_kalman(k).color, 'LineWidth',grosor, 'Parent',ax); 

        
end

frameT = insertObjectAnnotation(frame,'rectangle',posVehicle,label_str,'TextBoxOpacity',0.9,'FontSize',12,'Color',color_str);


%hold(ax,'off');

% call caffe.reset_all() to reset caffe
caffe.reset_all();
