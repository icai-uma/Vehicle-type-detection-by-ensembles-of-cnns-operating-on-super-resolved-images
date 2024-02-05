function xs = SignalSmoothing(x)

m = 2; % order of polynomial approximation
h = ceil([1 1.45.^(4:16)]); % set of scales
WMedian = [1 1 1 3 1 1 1];
%GammaICI = [0.5:0.1:3.0]; % set of Gamma parameters
GammaICI = 2.0; % set of Gamma parameters

[yN,xN] = size(x);
[kernels] = function_CreateLPAKernels1D(m,h,{'Gaussian'});

% Difference between the correlative elements
D2_X = x(1,2:length(x))-x(1,1:length(x)-1); 
sigma = median(abs(D2_X(1:length(x)-1)))/(0.6745*sqrt(2));

for s2=1:length(h),
    % the kernel
    gh = kernels{s2}';
    % the estimate
    yh(s2,1:xN)= convn(x,gh,'same')';
    % standard deviation of estimate
    stdh(s2)=sqrt(sum(sum(gh.^2)));

    % g(0) used in Cross-Validation criterion
    gh0(s2) = gh(ceil(size(gh,2)/2));

end

[xs,h_opt,std_opt] = function_ICI_1D(yh,stdh,GammaICI,sigma,WMedian);



