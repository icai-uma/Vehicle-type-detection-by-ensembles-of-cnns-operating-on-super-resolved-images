function postModel = vehiclesCounter(i,GTcounter, postModel)

idx = find(GTcounter(:,1) == i);
if ~isempty(idx) && ~isempty(postModel.blobs)
    colors =reshape([postModel.blobs.ColorToDraw],3,[]);
    idxObjectsOut = (colors(1,:) == 0.5).*(colors(2,:) == 0.5).*(colors(3,:) == 0.5);
    countDetected = nnz(1 - idxObjectsOut);
    countReal = GTcounter(idx,2);
    if ~isfield(postModel,'vehicleCounter')
        postModel.vehicleCounter = [i countReal countDetected];
    else
        postModel.vehicleCounter(size(postModel.vehicleCounter,1)+1,:) = [i countReal countDetected];
    end
    
    saveas(gca, [postModel.path num2str(i-1,'%5.6d') '_image_counterGT.jpg']);
               
end

