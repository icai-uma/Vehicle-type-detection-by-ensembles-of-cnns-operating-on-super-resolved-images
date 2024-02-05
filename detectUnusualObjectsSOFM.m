function model = detectUnusualObjectsSOFM(model,Winners,Errors,idxBlobs)

NumRowsMap = model.SOFM.NumRowsMap;
NumColsMap = model.SOFM.NumColsMap;
colores = hsv(NumRowsMap * NumColsMap); 

objetos = model.blobs;

for k=1:length(objetos)
    
    idx_win = find(idxBlobs == k);
    if ~isempty(idx_win)
        if Errors(idx_win) == 1
            objetos(k).posibleError = 1;
            [f,c] = ind2sub([NumRowsMap NumColsMap],Winners(idx_win));
            objetos(k).OrientationNeuronAssociated = model.SOFM.Prototypes(6,f,c);
        else
            objetos(k).ColorToDraw = colores(Winners(idx_win),:);
        end
    else
        objetos(k).ColorToDraw = [0.5 0.5 0.5];
    end
end

model.blobs = objetos;
    
model.coloredImage = uint8(object2doubleImageColored(model.blobs, model.FrameSize));