function fInfo = loadSequence(sName)

if isdir(sName)
    files = dir(sName);
    files = files(3:end);
    fInfo.NumFrames = length(files);
    for i=1:fInfo.NumFrames
        files(i).name = [sName '\' files(i).name];
    end

    fInfo.Dir = files;
    fInfo.Filename = sName;
    fInfo.LastFrame = 1;
else
    fInfo = aviinfo(sName);
    
end