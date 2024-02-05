function kModel = createKalmanModel(frame)

kModel.objects = [];
kModel.FrameSize = [size(frame,2) size(frame,1)];
kModel.ID = 1;
kModel.LastFrame = 1;
kModel.LifeTime = 15; % number of frames
kModel.StartTracking = 100; 
kModel.MaxSavedTrayectories = 100;
kModel.SavedTrayectories = []; % variable to store the trayectories of the finished tracked objects

% Kalman filter initialization
kModel.coefR = 1;
kModel.coefQ = 0.1;
kModel.Q = kModel.coefQ*eye(4);
kModel.H=[[1,0]',[0,1]',[0,0]',[0,0]'];
kModel.R = kModel.coefR*eye(2);
kModel.P = 10*eye(4);
kModel.A=[[1,0,0,0]',[0,1,0,0]',[1,0,1,0]',[0,1,0,1]'];
kModel.I = eye(4);
