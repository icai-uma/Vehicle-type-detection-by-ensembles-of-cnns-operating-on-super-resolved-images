function Model = createAEModel(frame)
% Model = createAEModel(frame)
% The model structure is built from a frame of the analysed sequence

% R.M.Luque and Ezequiel Lopez-Rubio -- February 2011

NumImageRows = size(frame,1);
NumImageColumns = size(frame,2);
NumCompColor = size(frame,3);

% Epsilon is the step size which regulates how quick the learning process is
% Valid values are shown in the paper 
Model.Epsilon = 0.01; 

Model.NumPatterns = 100; % Number of used patterns to initilise the model
Model.H = 2; % h is a global smoothing parameter to compute the noise (by default is 2)
Model.NumCompGauss=1; % Number of Gaussian distribution (it properly works with 1)
Model.NumCompUnif=1; % Number of Gaussian distribution (it properly works with 1)
Model.Z = 250; % Maximun number of consecutive frames in which a pixel belongs to the foreground class 
               % It is assumed that it is computed offline by analising 
               % a subset of frames of the sequence (by default 250)
Model.CurrentFrame = 1; %Constant variable which indicates the current frame (at the begining 1)
Model.KernelProcesses = 4; % Number of CPU kernels to parallel the process
Model.MaxTimesForeground = 2;

Model.NumComp=Model.NumCompGauss+Model.NumCompUnif; % Total number of distributions
Model.Log = 'temp.txt'; % Name of the log file

% Allocating space for work variables
Model.Min=zeros(NumCompColor,Model.NumCompUnif,NumImageRows,NumImageColumns);
Model.Max=zeros(NumCompColor,Model.NumCompUnif,NumImageRows,NumImageColumns);
Model.Den=zeros(NumImageRows,Model.NumCompUnif,NumImageColumns);
Model.Mu=zeros(NumCompColor,Model.NumCompGauss,NumImageRows,NumImageColumns);
Model.C=zeros(NumCompColor,NumCompColor,Model.NumCompGauss,NumImageRows,NumImageColumns);
Model.InvC=Model.C;
Model.LogDetC=zeros(Model.NumCompGauss,NumImageRows,NumImageColumns);
Model.MuFore=zeros(NumCompColor,Model.NumCompGauss,NumImageRows,NumImageColumns);
Model.Counter=zeros(NumImageRows,NumImageColumns);
Model.Cov=zeros(4,NumImageRows,NumImageColumns); 
Model.Var=zeros(NumImageRows,NumImageColumns); 


Model.Pi=ones(Model.NumComp,NumImageRows,NumImageColumns); 
Model.Pi(1,:,:)=0.5*Model.Pi(1,:,:);
Model.Pi(2,:,:)=0.5*Model.Pi(2,:,:);

Model.TrackingEnabled = 1;
Model.PostprocessingEnabled = 1;


