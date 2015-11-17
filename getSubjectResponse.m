function key_pressed = getSubjectResponse(targetPool, winSize, win, textEntry, backgroundEntry)

%Draws all the candidate letters on the screen in a grid. The letter
%that subject selected, (key_pressed), is marked by a rectangle around it

% History: July 10, 2014 created by HM


winWidth = winSize(3);
winHeight = winSize(4);

%grid properties
numRow = 2;
numCol = length(targetPool)/numRow;


% ShowCursor('Hand');
% WaitSetMouse(winWidth/2,winHeight/2,	win); % set cursor and wait for it to take effect
return_is_pressed = 0;


interClickSecs = .5;%500 msec
clicks = 0;
candInd = [];
key_pressed = [];
[grid_xy, ~] = drawGrid(win, winWidth, winHeight, numRow, numCol, targetPool, textEntry, backgroundEntry, candInd);

while ~return_is_pressed
    
    keydown = 0;
    buttons = 0;
    while ~keydown && ~any(buttons)
        %do nothing
        [keydown, ~, keyCode] = KbCheck;
        
        [x,y,buttons] = GetMouse;
    end
    
    if keydown %keyboard is used to select the target letter
        
        if keyCode(KbName('Escape'))
            cleanup;
            break
        end
        if keyCode(KbName('Space'))
            return_is_pressed = 1;
            break;
        else
            key_pressed = char(find(keyCode));
            for k=1:numel(targetPool)
                if targetPool(k).targLet == key_pressed
                    candInd = k;
                end
            end
            drawGrid(win, winWidth, winHeight, numRow, numCol, targetPool, textEntry, backgroundEntry, candInd);
            
        end
    else %mouse is used to select the target letter
        candInd = find_clicked_letter(grid_xy, numCol, numRow, x,y);
        drawGrid(win, winWidth, winHeight, numRow, numCol, targetPool, textEntry, backgroundEntry, candInd);
        clicks = clicks + 1;
        
        % Wait for further click in the timeout interval.
        tend=GetSecs + interClickSecs;
        while GetSecs < tend
            % If already down, wait for release...
            while any(buttons) && GetSecs < tend
                [x,y,buttons] = GetMouse;
                
            end;
            
            % Wait for a press or timeout:
            while ~any(buttons) && GetSecs < tend
                [x,y,buttons] = GetMouse;
                
            end;
            
            % Mouse click or timeout?
            if any(buttons) && GetSecs < tend
                % Mouse click. Count it.
                clicks=clicks+1;
                if  clicks == 2
                    return_is_pressed = 1;
                    key_pressed = targetPool(candInd).targLet;
                    break;
                end;
            else
                clicks = 0;
            end
            
        end;
    end
    
    FlushEvents('KeyDown');
    
end
HideCursor;

