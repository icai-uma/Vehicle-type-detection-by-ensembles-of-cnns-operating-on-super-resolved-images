function kModel = trackKalman(kModel, blobs, idxFrame)

kModel.LastFrame = idxFrame;

% Get the blobs
detectedObjects = blobs; 

% Predict the model
kModel = kalmanPrediction(kModel);
[m_asoc,~] = kalmanMatching(kModel.objects, detectedObjects);

% Correct the model
[kModel,detectedObjects] = kalmanCorrection(kModel, detectedObjects,m_asoc);

% Create and kill tracked objects
kModel = newKalmanObjects(kModel, detectedObjects);
kModel = releaseKalmanObjects(kModel);

