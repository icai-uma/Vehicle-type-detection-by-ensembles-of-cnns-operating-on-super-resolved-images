function imagen = ConvexImage2Image(frame, obj)

limites = round(obj.BoundingBox);
imagen = frame(limites(2):limites(2)+limites(4)-1,limites(1):limites(1)+limites(3)-1,:);

imagen(:,:,1) = imagen(:,:,1).*uint8(obj.ConvexImage);
imagen(:,:,2) = imagen(:,:,2).*uint8(obj.ConvexImage);
imagen(:,:,3) = imagen(:,:,3).*uint8(obj.ConvexImage);