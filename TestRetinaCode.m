% test code example
% this code relies on granger lab's github repository
function [] = TestRetinaCode ()
    %% configuration
    path = ''; % replace with the path to your videos.
    vidName = ''; % replace with vid name

    %% load video
    t = tic(); % get current time
    [~,vidNameNoExt,ext] = fileparts(vidName);
    [video,frameRate] = LoadVideo(path, vidName); % video is now a uint8 matrix with dimensionality nRows x nCols x nChannels x nFrames
    % 2 main image formats in matlab - uint8 ranged 0-->255 (inclusive,inclusive) and double ranged 0-->1 (inclusive,inclusive)
    video = double(video) ./ 255; % uncomment to try the other image format - must then multiply retina output by 255
    
    
    isColor = (size(video, 3) > 1); % if more than 1 channel, this is color
    nRows   = size(video, 1);
    nCols   = size(video, 2);
    nFrames = size(video, 4);
    disp("nFrames: " + nFrames);
    elapsed = toc(t); % elapsed time since t
    disp(['video load took ',num2str(elapsed, '%.1f'),' s (',num2str(1000*elapsed/nFrames, '%.1f'),' ms/frame)']);
    disp(['video is ',num2str(nFrames),' frames (',num2str(nFrames/frameRate),' s)']);
    
    %% initialize classes
    r1 = VideoRetina(nRows, nCols, isColor); % init wrapper class
    colorSamplingMethod = []; % use default
    useRetinaLogSampling = true;
    reductionFactor = [];
    samplingStrength = [];
    r2 = Retina(size(video, 1), size(video, 2), isColor, colorSamplingMethod, useRetinaLogSampling, reductionFactor, samplingStrength); % init matlab version
    
    %% process frame by frame
    disp('processing...');
    %%%
    parvo1 = zeros(nRows, nCols, size(video, 3), nFrames, 'like', video); % initialize a 4D matrix full of 0's, same datatype as video
    magno1 = zeros(nRows, nCols, 1, nFrames, 'like', video);
    parvo2 = zeros(nRows, nCols, size(video, 3), nFrames, 'double');
    magno2 = zeros(nRows, nCols, 1, nFrames, 'double');
    
    t = tic();
    for frame = 1:size(video, 4)
        [parvo1(:,:,:,frame),magno1(:,:,:,frame)] = r1.ProcessFrame(video(:,:,:,frame)); % call method ProcessFrame of Retina
    end
    elapsed = toc(t);
    disp(['retina processing (wrapper) took ',num2str(elapsed, '%.1f'),' s (',num2str(1000*elapsed/nFrames, '%.1f'),' ms/frame)']);
    %%
    t = tic();
    for frame = 1:size(video, 4)
         r2.run(video(:,:,:,frame));
         parvo2(:,:,:,frame) = r2.getParvo(); %.*255;
         magno2(:,:,:,frame) = r2.getMagno(); %.*255;
    end
    
    elapsed = toc(t);
    disp(['retina processing (matlab) took ',num2str(elapsed, '%.1f'),' s (',num2str(1000*elapsed/nFrames, '%.1f'),' ms/frame)']);
    
    %% view a frame
    frame = 5;
    h = figure('Name', 'parvo'); % create new figure
    imshow(cat(2, parvo1(:,:,:,frame), parvo2(:,:,:,frame))); % concatenate along 2nd dimension, render image to figure
    print(h, fullfile(path, [vidNameNoExt,'_parvo.png']), '-dpng', '-r300'); % save figure to a png (resolution = 300 dpi)
    
    h = figure('Name', 'magno');
    imshow(cat(2, magno1(:,:,:,frame), magno2(:,:,:,frame)));
    print(h, fullfile(path, [vidNameNoExt,'_magno.png']), '-dpng', '-r300');
    
    %% render videos for visual comparison
    vid = VideoWriter(fullfile(path, [vidNameNoExt,'_parvoLog.mj2']), 'Motion JPEG 2000');
    vid.CompressionRatio = 5; % default = 10
    vid.FrameRate = frameRate;
    vid.open();
    % want to put both versions side-by-side, but media players hate ultra-wide videos, so make the video extra high too (16/9 ratio):
    blankFrame = zeros(nCols*2*(9/16), nCols*2, size(parvo1, 3), 'like', parvo1);
    for frame = 1:size(video, 4)
        img = blankFrame;
        img(1:nRows,1:nCols,:) = parvo1(:,:,:,frame);
        img(1:nRows,nCols+1:end,:) = parvo2(:,:,:,frame);
        vid.writeVideo(uint8(img.*255));
    end
    vid.close();
    
    vid = VideoWriter(fullfile(path, [vidNameNoExt,'_magnoLog.mj2']), 'Motion JPEG 2000');
    vid.CompressionRatio = 5; % default = 10
    vid.FrameRate = frameRate;
    vid.open();
    blankFrame = zeros(nCols*2*(9/16), nCols*2, size(magno1, 3), 'like', magno1);
    for frame = 1:size(video, 4)
        img = blankFrame;   
        img(1:nRows,1:nCols,:)     = magno1(:,:,:,frame);
        img(1:nRows,nCols+1:end,:) = magno2(:,:,:,frame);
        vid.writeVideo(uint8(img.*255));
    end
    vid.close();
    
    %% save videos to a file matlab can easily reload later
    save(fullfile(path, [vidNameNoExt,'_result.mat']), 'parvo1', 'magno1', 'parvo2', 'magno2', '-v7.3'); % matlab file format 7.3
    
    %% quantitatively compare
    parvo1 = double(parvo1); % cast to double if not already of that type (so analyses will be high-precision)
    magno1 = double(magno1);
    parvo2 = double(parvo2);
    magno2 = double(magno2);
    
    meanParvoDiff = mean(parvo1(:)-parvo2(:));
    disp(['meanParvoDiff = ',num2str(meanParvoDiff)]);
    
    meanMagnoDiff = mean(magno1(:)-magno2(:));
    disp(['meanMagnoDiff = ',num2str(meanMagnoDiff)]);
end