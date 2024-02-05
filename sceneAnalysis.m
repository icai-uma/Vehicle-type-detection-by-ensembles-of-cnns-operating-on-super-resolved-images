function postModel = sceneAnalysis(postModel, objects)

tam = postModel.FrameSize;
map = zeros(postModel.FrameSize(2), postModel.FrameSize(1));

dim = []; 

for k=1:length(objects)

    v = round(objects(k).x(:,1:2));
%    validos = (sum(v > 0,2) == size(v,2));
%    v = [nonzeros(v(:,1).*validos) nonzeros(v(:,2).*validos)];
    
    n = length(v(:,1));
    t=1:.01:n;
    x=interp1(1:n,v(:,1),t,'spline');
    y=interp1(1:n,v(:,2),t,'spline');
    
    validos = (round(y) > 0).*(round(x) > 0).*(round(x) <= tam(2)).*(round(y) <= tam(1));
    x = nonzeros(round(x).*validos);
    y = nonzeros(round(y).*validos);
%    figure,plot(v(:,1),v(:,2),'or',x,y,'b');

%     dif1 = v(end,1) - v(1,1);
%     dif2 = v(end,2) - v(1,2);
%     
%     if abs(dif1) > abs(dif2)
%         xi = v(:,1):sign(dif1):v(end,1);
%         yi = interp1(v(:,1),v(:,2),xi);
%     else
%         yi = v(:,2):sign(dif2):v(end,2);
%         xi = interp1(v(:,2),v(:,1),yi);
%     end
    idx = sub2ind(size(map),y,x);
    map(idx) = map(idx) + 1;
    dim(k,:) = objects(k).dim;
end

postModel.map.trayectories = double(map/max(max(map)));
postModel.map.mean_dim = mean(dim);
postModel.map.std_dim = std(dim);
postModel.map.mean_prop = mean(dim(:,1) ./ dim(:,2));
postModel.map.std_prop = std(dim(:,1) ./ dim(:,2));