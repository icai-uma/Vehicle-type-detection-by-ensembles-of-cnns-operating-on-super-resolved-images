function bd = object2doubleImageColored(objs,tam)

bd = zeros(tam(2), tam(1),3);

for i=1:length(objs)

    if ~isempty(objs(i).ID)
        region = (objs(i).ConvexImage);
        region3 = zeros(size(region,1),size(region,2),3);
        limites = round(objs(i).BoundingBox);
        if ~objs(i).posibleError
            regionR = 255*(region*objs(i).ColorToDraw(1));
            regionG = 255*(region*objs(i).ColorToDraw(2));
            regionB = 255*(region*objs(i).ColorToDraw(3));
            region3(:,:,1) = regionR;
            region3(:,:,2) = regionG;
            region3(:,:,3) = regionB;
        else
            region3 = reshape(repmat(region.*255,1,3),size(region,1), size(region,2),[]);
        end
        temp = bd(limites(2):limites(2)+limites(4)-1,limites(1):limites(1)+limites(3)-1,:);
        bd(limites(2):limites(2)+limites(4)-1,limites(1):limites(1)+limites(3)-1,:) = temp.*(1-region3) + (1-temp).*region3;
    end
end
