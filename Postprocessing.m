function postModel = Postprocessing(postModel, imMask)

% Extract the objects from the mask and remove spurious pixels
L = bwlabel(imMask);
[L,num_blobs] = removeSpuriousBlobs(L, postModel.FirstMaxSizeSpuriousObjects);

% Joint the objects which are very closed
L = blobUnion(L, num_blobs);
L = removeSpuriousBlobs(L, postModel.SecondMaxSizeSpuriousObjects);
postModel.cleanMask = L;

% Extract the features required
postModel.blobs = extractObjects(L); 

% Check if the objects are similar to other objects
% postModel = analyzeBlobs(postModel);
% if ~isempty(kModel.SavedTrayectories)
%     if mod(length(kModel.SavedTrayectories), postModel.FrequencyAnalysis) == 0
%         postModel = sceneAnalysis(postModel, kModel.SavedTrayectories);
%     end
% end

postModel.coloredImage = object2doubleImage(postModel.blobs, postModel.FrameSize);
