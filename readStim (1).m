function [targetTex,  targetRecsize] = readStim( targets, targInd, Imsize, win)

% original image
imT = targets(targInd).im;
ScaleFactor = Imsize/size(imT,1);

% rescale image
imScaleT = imresize(imT, ScaleFactor, 'bilinear');

% make a texture
targetTex = Screen('MakeTexture',win,uint8(imScaleT));

% object rectangle
targetRecsize = [0,0,size(imScaleT,2),size(imScaleT,1)];

