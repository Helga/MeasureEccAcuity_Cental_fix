
show_blank_page = 0;
show_grid = 0;

warningBeep_time = 0;
black_page_on_time = 0;
target_on_time = 0;


targetSize = round(10^(expmnt.adaptiveComp{PM_ind}.PM.xCurrent) * expmnt.ppd);
data.stim.targSize(ii,:) = targetSize;


% getting ready
if expmnt.useEyeTracker == 1
    Priority(1);
end

oldEyePos = winCenter;
FlushEvents('KeyDown');
Screen('FillRect',win,backgroundEntry)
WaitSecs(expmnt.iti);

% at the beginning of the next frame
succ = 0;
keyCode = [];
key_pressed = ' ';

temp = nan;
Snd('Play',expmnt.trialBeep);
targInd = data.stim.targSeq(ii);
targets = expmnt.targetPool;
targLet = data.stim.targLet(ii);
trailStartGazeInd = thisGaze;%gaze index when this trial starts

Screen('fillrect', win, backgroundEntry);
trial_start_time = Screen('Flip',win);%mark trial start time

state = 'fixation';

% trial loop: records gaze location constantly and walks through different
% states of a trial. Loop aborts when we reach the last state: "finish"
while strcmp(state, 'finish') == 0
    eyeavail = 0;
    % Get eye coordinates
    if expmnt.useEyeTracker == 1
        err=Eyelink('CheckRecording');
        if(err~=0)
            error('Eyelink not recording eye-position data');
        end
        if Eyelink('NewFloatSampleAvailable') > 0
            % get the sample in the form of an event structure
             eyeSampleTime = GetSecs;
            elEvent = Eyelink('NewestFloatSample');
            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample
                x = elEvent.gx(eye_used+1); % +1 as we're accessing MATLAB array
                y = elEvent.gy(eye_used+1);
                pupilSize = elEvent.pa(eye_used+1);
                % do we have valid data and is the pupil visible?
                if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA && elEvent.pa(eye_used+1)>0.5
                    eyeavail = 1;
                    eyePos = [x, y] ;
                else
                    eyeavail = 0;
                    Screen('FillRect',win,backgroundEntry);
                    Screen('Flip',win);
                    if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA
                        eyePos = [x, y] ;
                    else
                        eyePos = [nan, nan];
                    end
                end
            end
        end
        
    else
        % Query current mouse cursor position (our "pseudo-eyetracker")
        if GetSecs-eyeSampleTime < 0.001 % keep the millisecond rate
            eyeavail = 0;
        else
            % Query current mouse cursor position (our "pseudo-eyetracker")
            eyeavail = 1;
            [eyePos(1), eyePos(2), buttons]=GetMouse;
            pupilSize = 1;
            eyeSampleTime = GetSecs;
        end
    end
  
    gaze_changed = ~isequal(eyePos, oldEyePos);
    
    if eyeavail
        % store the eye position
        gazeSeq(thisGaze,:) = eyePos;
        gazeTime(thisGaze,:) = [nan eyeSampleTime];
        gazePupil(thisGaze,:) = pupilSize;
        gazeStimIdx(thisGaze,1) = ii;
        thisGaze = thisGaze+1;        
        
        % Keep track of last gaze position:
        oldEyePos=eyePos;
        switch state
            case 'fixation' % Local drift correction
                if gaze_changed %% draw the fixation cross and wait until fixated
                    
                   % drawCross(win, eyePos, 10,[ 1 0 0]);%TODO: for debugging purpose, need to remove it when subject performs the experiment
                    drawCross(win,[round(fixXY(1)) ,round(fixXY(2))], fixationCross_length, fixationCross_color); %draw the fixation cross                                      
                    Screen('filloval', win, expmnt.cue.color, cueRec, expmnt.cue.width);%draw the cue
                    fixationCross_on_time = Screen('Flip',win);
                    
                    gazeWin = slidingGazeWin(gazeTime(trailStartGazeInd:thisGaze-1, :) , ...
                        gazeSeq(trailStartGazeInd:thisGaze-1,:), expmnt.slidingWinWid);%sliding gaze window
                    medianGaze = median(gazeWin);% 
                    gazeWin_std = std(gazeWin);
                    %             msg{15} = ['median gaze = ', num2str(medianGaze)];
                    %             giveInstruction(win,msg,textEntry,backgroundEntry);
                    %             normD(thisGaze) =  norm(medianGaze - winCenter)
                    %             GW(thisGaze, :, :) = gazeWin;
                    if  sum(isnan(medianGaze)) ==0  && norm(gazeWin_std) < expmnt.stable_gaze_std ...%is the gaze stable?
                            && norm(medianGaze - fixXY) < expmnt.stable_gaze_thresh %is the subject actually looking at the fixation?                        
                        state = 'blank';
                        est_drift = double(medianGaze- fixXY);                        
                        
                    end
                end
            case 'blank'
                if black_page_on_time == 0 %show the blank page if this is the first time we hit here
                    Screen('fillrect', win, backgroundEntry);
                    black_page_on_time = Screen('Flip',win);
                elseif (GetSecs - black_page_on_time > expmnt.blank_page_display_time) && (warningBeep_time == 0)
                    Snd('Play', expmnt.targetDisplayBeep);% warning beep goes off after a delay
                    warningBeep_time = GetSecs;
                    state ='show_target';                    
                end
            case 'show_target'
                if target_on_time == 0 || (GetSecs - target_on_time <expmnt.target_display_time) %if this is the first time we are in state or we still need to show the target
                    
                    corrected_eyePos = eyePos - est_drift;%correct for the drit
                    targetXYGazeCont = corrected_eyePos - fixXY + winCenter;%coordinates of target on the gaze-contingent display
                    drawStimuli(win, targetSize, targetXYGazeCont, targInd, targets, expmnt.crowding);% draw the target on the screen
                    temp = Screen('Flip',win);
                    if target_on_time == 0
                        target_on_time = temp;
                    end
                else
                    Screen('fillrect', win, backgroundEntry);
                    Screen('Flip',win);
                    state = 'show_grid';
                end
            case 'show_grid'
                grid_page_on_time = GetSecs;
                key_pressed = getSubjectResponse(expmnt.targetPool, expmnt.screenRect, win, expmnt.instructColor, expmnt.bgColor);
                if key_pressed == targLet
                    succ = 1;
                    Snd('Play',expmnt.acquiredBeep);
                else
                    Snd('Play',expmnt.missedBeep);
                end
                trial_end_time = GetSecs;%mark the subject reponse time
                state = 'finish';                
                
            otherwise
                error('Unknown state!');
        end
    end
    
end

data.est_drift(ii,:) = est_drift;
data.std(ii,:) = gazeWin_std;
if isempty(key_pressed)
    key_pressed = ' ';
end
data.ans(ii) = key_pressed;
data.succ(ii) = succ;
data.timing.target_on_time(ii) = target_on_time;
data.timing.black_page_on_time(ii) = black_page_on_time;
data.timing.warningBeep_timer(ii) = warningBeep_time;
data.timing.trial_start_time(ii) = trial_start_time;
data.timing.trial_end_time(ii) = trial_end_time;
data.timing.fixationCross_on_time(ii) = fixationCross_on_time;
data.timing.grid_page_on_time(ii) = grid_page_on_time;
Priority(0);


