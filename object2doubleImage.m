function bd = object2doubleImage(objs,tam)

bd = zeros(tam(2), tam(1),3);

for i=1:length(objs)

    region = (objs(i).ConvexImage);
    if ~isempty(region)
        limites = round(objs(i).BoundingBox);
        region3 = reshape(repmat(region.*255,1,3),size(region,1), size(region,2),[]);
        bd(limites(2):limites(2)+limites(4)-1,limites(1):limites(1)+limites(3)-1,:) = region3;

        if objs(i).posibleError
            bd(limites(2):limites(2)+limites(4)-1,limites(1):limites(1)+limites(3)-1,2:3) = 0;
        end
    end
end
