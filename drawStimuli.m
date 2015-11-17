function drawStimuli(windowPtr, targSize, targLocation, targInd, targets, crowding)
%

[Targettex, targRecSize] = readStim(targets, targInd, targSize, windowPtr);
targX = targLocation(1);
targY = targLocation(2);
w = targRecSize(3);
h = targRecSize(3);%targRecSize(4);

TargetPos = ceil([targX-w/2, targY-h/2,targX+w/2, targY+h/2]);

Screen('FillRect',windowPtr,[127 127 127]);
Screen('DrawTexture',windowPtr, Targettex,targRecSize,TargetPos);

if crowding == 1
    disScale = 1;
    disScale2 = 1.6;
    CircPos = round([targX-disScale*w,targY-disScale*h,targX+disScale*w, targY+disScale*h]);
    CircPos2 = round([targX-disScale2*w,targY-disScale2*h, targX+disScale2*w,targY+disScale2*h]);
    
    ringWidth = targSize/6;%max(.1, targSize/5);
    Screen('frameoval', windowPtr, [0 0 0], [CircPos' CircPos2'], double(ringWidth));
end
