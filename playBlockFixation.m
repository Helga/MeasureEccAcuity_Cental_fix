%Fixate on the central cross to begin the block
% set the fixation
fixationCross_color = expmnt.fixationCross.color;
fixationCross_length = round(expmnt.fixationCross.length *expmnt.ppd);%TODO: add to main
fixationCross_on_time = 0;
% set the stimulus rects
stimIdx = 1;

% set reference point and tolerance
[refPt_x, refPt_y] = RectCenter(winRect);

% getting ready
if expmnt.useEyeTracker == 1
    Priority(1);
end
oldEyePos_x = nan;
oldEyePos_y = nan;
FlushEvents('KeyDown');
Screen('FillRect',win,backgroundEntry)
WaitSecs(expmnt.iti);
% at the beginning of the next frame
eyeSampleTime = nan;

trial_start_time = Screen('Flip',win);
Snd('Play',expmnt.trialBeep);
% Infinite display loop: Loop aborts when fixation exceed the minimum required time.

%fixation properties which are the same for all trials in this block
thFix = data.stim.thFix;
R = expmnt.fix.ecc;
[ecc(1),ecc(2)] = pol2cart(thFix,R);
ecc = round(ecc*expmnt.ppd);
data.stim.ecc = ecc;  % eccentricity in periphery, in pixel units
fixXY = winCenter + ecc;%fixation location in screen coordinates
data.stim.fixXY = fixXY;

while 1
    eyeavail = 0;
    % eye tracker
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
                    eyePos_x = x;
                    eyePos_y = y;
                else
                    eyeavail = 0;
                    Screen('FillRect',win,backgroundEntry);
                    Screen('Flip',win);
                    if x~=elHandle.MISSING_DATA && y~=elHandle.MISSING_DATA
                        eyePos_x = x;
                        eyePos_y = y;
                    else
                        eyePos_x = nan;
                        eyePos_y = nan;
                    end
                end
            end
        end
        
    else
        % Query current mouse cursor position (our "pseudo-eyetracker")
        if GetSecs-eyeSampleTime < 0.001 % keep the millisecond rate
            eyeavail = 0;
        else
            eyeavail = 1;
            [eyePos_x, eyePos_y, buttons]=GetMouse;
            pupilSize = 1;
            eyeSampleTime = GetSecs;
        end
    end
    
    %% %draw the fixation cross
    if eyeavail %&& fixationCross_on_time==0
        Screen('fillrect', win, backgroundEntry);
        drawCross(win,[round(fixXY(1)) ,round(fixXY(2))], fixationCross_length, fixationCross_color);
        fixationCross_on_time = Screen('Flip',win);
    end
    
    %% Save gaze data
    if eyeavail && (eyePos_x~=oldEyePos_x || eyePos_y~=oldEyePos_y)
        
        % store the eye position
        gazeSeq(thisGaze,:) = [eyePos_x eyePos_y];
        gazeTime(thisGaze,:) = [nan eyeSampleTime];%putting nan just to be consistant in data structure with preciuos versions/experiments
        gazePupil(thisGaze,:) = pupilSize;
        gazeStimIdx(thisGaze,1) = stimIdx;
        thisGaze = thisGaze+1;
      
        % Keep track of last gaze position:
        oldEyePos_x=eyePos_x;
        oldEyePos_y=eyePos_y;
    end
    %% end of fixation
    if fixationCross_on_time > 0 && eyeSampleTime-trial_start_time > expmnt.blockFixation_duration
       % Snd('Play',expmnt.trialBeep);
        trial_end_time = GetSecs;
        break
    end
    
end


% store the timing data for this trial
data.timing.trial_start_time(1) = trial_start_time;
data.timing.trial_end_time(1) = trial_end_time;
data.timing.fixationCross_on_time(1) = fixationCross_on_time;
mean(gazeSeq(thisGaze,:))

