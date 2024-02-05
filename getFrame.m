function frame = getFrame(fInfo,k)

if isdir(fInfo.Filename)
    frame = imread(fInfo.Dir(k(1)).name);
    if length(k) > 1
        frame = zeros(size(frame,1),size(frame,2),size(frame,3),length(k));
        for i=1:length(k)
            [~,~,ext] = fileparts(fInfo.Dir(k(i)).name);
            if (strcmpi(ext,'.jpg') == 1) ||  (strcmpi(ext,'.bmp') == 1)
                frame(:,:,:,i) = imread(fInfo.Dir(k(i)).name);
            else
                disp(['Error reading the frame nº: ' num2str(k(i))]);
                break;
            end 
        end
    end
else
    d=mmread(fInfo.Filename,k);
    frame = d.frames(1).cdata;
    if length(d.frames) > 1
        frame = zeros(size(frame,1),size(frame,2),size(frame,3),length(d.frames));
        for i = 1:length(d.frames)
            frame(:,:,:,i) = [d.frames(i).cdata];
        end
    end
end

%frame = frame(1:2:end,1:2:end,:,:);