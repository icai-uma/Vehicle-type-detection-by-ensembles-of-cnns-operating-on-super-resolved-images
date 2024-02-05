function kModel = deepLabellingVehicles_Matlab(kModel,postModel)
obj_kalman = kModel.objects;
p_root = '/home/icai21/Modelos/codigos/icae/iwinac';
kdir = '/src';

% Initialize the network using BVLC CaffeNet for image classification
% Weights (parameter) file needs to be downloaded from Model Zoo.
model_dir = [p_root kdir '/'];
data_dir = model_dir; 
net_weights = [model_dir 'net_lankershim.mat']; %%% net_sb
if ~exist(net_weights, 'file')
    error('Alexnet model not found');
end
net = load(net_weights);
net.myNet = net.net_lankershim; %%% net_sb

cont_time = 1;
tiempos = [];
for k=1:length(obj_kalman)
    if not(all(obj_kalman(k).features(end).ColorToDraw == [0.5 0.5 0.5])) % Si el objeto no está en el borde y se ve completo
        %im = obj_kalman(k).features(end).imagen;
        %im = imread('../../examples/images/cat.jpg');
        %im2=FillRegion(im,256,256);
        %figure,imshow(im);
        
        %im = normalizeImage(obj_kalman(k).features(end),postModel);
        im = obj_kalman(k).features(end).imagen;
        %im = FillRegionScaleZeros(im,256,256,1.8551); % El último valor es el escalado y se ha calculado previamente 
        im = FillRegionScaleZeros(im,256,256,1.8551,'noSR');
        %PreparedImages=prepare_image3(im,data_dir);
        %input_data = {squeeze(PreparedImages(:,:,:,5))};
        
        
        
        T = 227;
        tam_row = size(im,1);
        rango = round((tam_row - T)/2);
        ini_row = rango+1;
        ini_col = rango+1;

        input_data = im(ini_row:ini_row+T-1,ini_col:ini_col+T-1,:);
        
        %scores = net.forward({PreparedImages});
        tini = tic;
        [predicted,score] = classify(net.myNet,input_data);
        tfin = toc(tini);
        tiempos(cont_time) = tfin;
        cont_time = cont_time + 1;
        switch predicted
        case 'car'
            idxType = 1;
        case 'moto'
            idxType = 2;
        case 'truck'
            idxType = 3;
        case 'van'
            idxType = 4;
        end
        
%         %disp(scores{:});
%         scores = scores{1};
%         [~, PredictedLabel] = max(scores);
%         % PARCHE
%         PredictedLabel = PredictedLabel - 1;
%         %cont = cont + 1;
%         %disp(PredictedLabel);
%         switch PredictedLabel
%         case 1
%             type = 'car';
%         case 2
%             type = 'moto';
%         case 3
%             type = 'truck';
%         case 4
%             type = 'van';
%         end
        
        obj_kalman(k).features(end).type = predicted;   
        obj_kalman(k).features(end).idxType = idxType;
    end
end
mean(tiempos)
kModel.objects = obj_kalman;

% call caffe.reset_all() to reset caffe
%caffe.reset_all();
