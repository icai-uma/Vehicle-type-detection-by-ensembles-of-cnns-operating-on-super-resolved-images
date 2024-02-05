function postModel = createPostprocessingModel(frame)

postModel.Start = 100; 
postModel.FrameSize = [size(frame,2) size(frame,1)];
postModel.FirstMaxSizeSpuriousObjects = 10;
postModel.SecondMaxSizeSpuriousObjects = 50;
postModel.ID = 1;
postModel.LastFrame = 1;
postModel.map = [];
postModel.FrequencyAnalysis = 50;
postModel.StartModellingObjects = postModel.Start + 50;
%postModel.StartCuttingObjects = postModel.StartModellingObjects + 1000000; % no aplica el corte
postModel.StartCuttingObjects = postModel.StartModellingObjects + 100;
postModel.path = ['Results/coches_' datestr(now,30) '/'];

if ~exist(postModel.path,'dir')
    mkdir(postModel.path);
end

postModel.debug = 0;