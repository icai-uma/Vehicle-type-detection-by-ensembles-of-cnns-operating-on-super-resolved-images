function model = Smoothing(model)
% model = Smoothing(model)
% This function smooths the average frame of a sequence. The required
% information is in the parameter 'model'.

% R.M.Luque and Ezequiel Lopez-Rubio -- February 2011

% Adapt the dimensions of the model structure to the smoothingMEX.c function 
model.Mu = shiftdim(model.Mu,2);
model.C = shiftdim(model.C,3);
model.Pi = shiftdim(model.Pi,1);
img = squeeze(model.Mu(:,:,:,1));

% In order to have the luminance of the image in an specific color component, 
% a transformation of the RGB into the YCC color spaced is performed.
YCC(:,:,1) = 0.299 * img(:,:,1) + 0.587 * img(:,:,2) + 0.114 * img(:,:,3);
YCC(:,:,2) = -0.168736 * img(:,:,1) - 0.331264 * img(:,:,2) + 0.5 * img(:,:,3);
YCC(:,:,3) =  0.5 * img(:,:,1) - 0.418668 * img(:,:,2) - 0.081312 * img(:,:,3);
model.Mu = YCC;

% The gradient function on each direction (x and y) is obtained using the
% first derivative. The Sobel operator is applied.
dx = imfilter(YCC(:,:,1),fspecial('sobel') /8,'replicate');
dy = imfilter(YCC(:,:,1),fspecial('sobel')'/8,'replicate');

% A kernel-based filter is used to smooth the values of previous gradient
Ksize=3; % Odd number which regulates the size of filter mask (3 by default) 
radius = floor(Ksize / 2);
K = fspecial('disk', radius);
K = K ./ K(radius+1, radius+1);

% Function which performs the smoothing process
model2=SmoothingMEX(model,dx,dy,K);
model = model2;

% Convert the color space from YCC to RGB
output = model.Mu;
outputRGB(:,:,1) = output(:,:,1) - 0.00092460 * output(:,:,2) + 1.40168676 * output(:,:,3);
outputRGB(:,:,2) = output(:,:,1) - 0.34369538 * output(:,:,2) - 0.71416904 * output(:,:,3);
outputRGB(:,:,3) = output(:,:,1) + 1.77216042 * output(:,:,2) + 0.00099022 * output(:,:,3);

model.Mu = outputRGB; 
% Reassign the dimensions of the variables
model.Mu = shiftdim(shiftdim(model.Mu,-1),3);
model.C = shiftdim(shiftdim(model.C,-1),3);
model.Pi = shiftdim(model.Pi,2);




