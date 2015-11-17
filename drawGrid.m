function [grid_xy , vblTS] = drawGrid(win, winWidth, winHeight, numRow, numCol, targetPool, textEntry, backgroundEntry, candInd)
%Draws all the candidate letters on the screen in a grid
%candInd : Index of the letter subject chose (single Enter or single mouse
%click) in the array of targets (targetPool). We display it with a
%rectangle around it, if any

% History: July 10, 2014 created by HM

if nargin < 9 
    candInd = [];%
end

cell_width_x = winWidth/2/numCol; %pixels per cell
cell_width_y = cell_width_x;
margine = 20;%distance from the letter to the rectangle around it
offset = [winWidth/4 winHeight/4 winWidth/4 winHeight/4]; %show the letters on the 75% central part of the screen

Screen('FillRect',win,backgroundEntry);
cnt = 1;
for ii = 1:numRow
    targY = (ii-1) * cell_width_y;
    for jj = 1:numCol
        targX = (jj-1) * cell_width_x;
        [targTex, targRecSize] = readStim(targetPool,cnt, cell_width_x - margine*2, win);
        
        w = targRecSize(3);
        h = targRecSize(3);
        
        
        targPos = ceil([targX, targY,targX+w, targY+h])+ offset;%location of the letter on the screen
        Screen('DrawTexture',win, targTex,targRecSize,targPos);%draw the letter on the screen
        borderPos = targPos + [-margine, -margine, margine, margine];%location of the rectangle around the selected letter
        
        if ii == 1 && jj == 1
            grid_xy = borderPos(1:2);
        elseif ii == numRow && jj ==numCol
            grid_xy = [grid_xy , borderPos(3:4)];
        end
         %draw a rectangle around the selected letter
        if ~isempty(candInd) && cnt == candInd
            Screen('FrameRect', win, [1 1 0], borderPos, 4);
        end
        cnt = cnt + 1;
        
    end
end


msg1 = 'You can use the kayboard or the mouse to enter your answer.';
Screen(win,'DrawText',msg1, 50,50,textEntry)
msg2 = 'your answer.';
Screen(win,'DrawText',msg2, 50 ,100,textEntry)
% if ~isempty(candInd)
%     msg3 = 'To confirm your answer, press Enter.';
%     Screen(win,'DrawText',msg3, 50,3*winHeight/4,textEntry)
% end
vblTS = Screen('Flip',win);