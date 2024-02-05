function [figure1, axes1, axes2, axes3, axes4] = createfigure_representation

% Create figure
scrsz = get(0,'ScreenSize');
figure1 = figure('PaperSize',[20.98 29.68],'Position',[scrsz(1) scrsz(2) scrsz(3) scrsz(4)]);
%figure1 = figure('PaperType','a4letter','PaperSize',[20.98 29.68]);
colormap('gray');

% Create axes
axes1 = axes('Visible','off','Parent',figure1,'YDir','reverse',...
    'TickDir','out',...
    'Position',[0.0765408805031447 0.52 0.44 0.44],...
    'Layer','top',...
    'DataAspectRatio',[1 1 1]);
% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes1,[0.5 640.5]);
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes1,[0.5 480.5]);
box(axes1,'on');

% Create axes
axes2 = axes('Visible','off','Parent',figure1,'YDir','reverse',...
    'TickDir','out',...
    'Position',[0.43 0.52 0.44 0.44],...
    'Layer','top',...
    'DataAspectRatio',[1 1 1]);
% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes2,[0.5 640.5]);
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes2,[0.5 480.5]);
box(axes2,'on');


% Create axes
axes3 = axes('Visible','off','Parent',figure1,'YDir','reverse',...
    'TickDir','out',...
    'Position',[0.0765408805031447 0.04 0.44 0.44],...
    'Layer','top',...
    'DataAspectRatio',[1 1 1]);
% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes2,[0.5 640.5]);
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes2,[0.5 480.5]);
box(axes3,'on');


% Create axes
axes4 = axes('Visible','off','Parent',figure1,'YDir','reverse',...
    'TickDir','out',...
    'Position',[0.43 0.04 0.44 0.44],...
    'Layer','top',...
    'DataAspectRatio',[1 1 1]);
% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes2,[0.5 640.5]);
% Uncomment the following line to preserve the Y-limits of the axes
% ylim(axes2,[0.5 480.5]);
box(axes4,'on');
