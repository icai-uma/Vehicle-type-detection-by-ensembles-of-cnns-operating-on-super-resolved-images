function images2video(workingDir)

imageNames = dir(fullfile(workingDir,'*NOGT.jpg'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile(workingDir,'out2.avi'));
outputVideo.FrameRate = 25;
open(outputVideo)

for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,imageNames{ii}));
   writeVideo(outputVideo,img)
   disp([num2str(ii) ' de ' num2str(length(imageNames))]);
end

close(outputVideo)

