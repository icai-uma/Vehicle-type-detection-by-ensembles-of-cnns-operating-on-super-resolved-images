function noise = estimateNoise(model)
% noise = estimateNoise(model)
% This function compute the noise of a sequence from the structure 
% previously computed 'model'.  

% R.M.Luque and Ezequiel Lopez-Rubio -- February 2011

% The mean of the scene is used as the raw frame
temp = shiftdim(model.Mu,2);
frame = double(squeeze(temp(:,:,:,1)));

% The smoothing approach is applied. The smooth image is in the field 'Mu'.
model2 = Smoothing(model); 

temp = shiftdim(model2.Mu,2);
smooth = double(squeeze(temp(:,:,:,1)));

% The difference between the two images is obtained
dif = (frame - smooth).^2;

% A 0.001-winsorized mean is applied instead of the standard mean because
% the first measure is more robust and certain extreme values are removed
dif2 = reshape(dif,size(dif,1)*size(dif,2),3);
dif3 = sort(dif2);
idx = round(length(dif3)*0.99);
dif3(idx:end,1) = dif3(idx-1,1);
dif3(idx:end,2) = dif3(idx-1,2);
dif3(idx:end,3) = dif3(idx-1,3);

noise = mean(dif3);

