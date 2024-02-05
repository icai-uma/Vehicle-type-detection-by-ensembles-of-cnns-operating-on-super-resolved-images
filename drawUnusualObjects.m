function drawUnusualObjects(model,h)

objetos = model.blobs;

if ~isempty(objetos)
    idxs = find([objetos.posibleError]);
    idxs_split = find([objetos.splitted]);
    %idxs_split = setdiff(idxs,idxs_split);

    hold(h,'on');

    for k=1:length(idxs_split)
        ob = objetos(idxs_split(k));

        c = ob.BoundingBox;
        if all(c > 0)
            rectangle('Position', [c(1)+1, c(2)+1, c(3), c(4)], 'EdgeColor',[1 1 1], 'LineWidth',2, 'Parent',h); 
        end
    end

    for k=1:length(idxs)
        ob = objetos(idxs(k));

        c = ob.BoundingBox;
        rectangle('Position', [c(1)+1, c(2)+1, c(3), c(4)], 'EdgeColor',[0.5 0.5 0.5], 'LineWidth',2, 'Parent',h); 

        Centroid = ob.Centroid;
        Orientation = ob.OrientationNeuronAssociated;

        rot = [cos(deg2rad(Orientation)) -sin(deg2rad(Orientation)); sin(deg2rad(Orientation)) cos(deg2rad(Orientation))];
        des = [0 40]*rot;
        extr = [Centroid(1)+des(2) Centroid(1)-des(2); Centroid(2)-des(1) Centroid(2)+des(1)];
        plot(Centroid(1), Centroid(2), '*', 'Color' , [0.5 0.5 0.5], 'Parent',h);
        plot(extr(1,:), extr(2,:), '-g', 'Parent',h);

    end



    hold(h,'off');
end