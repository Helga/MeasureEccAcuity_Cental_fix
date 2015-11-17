% runBlock

% initialize data block
idx = find(expmnt.plan(:,1)==expmnt.thisBlock);
thisplan = expmnt.plan(idx,:);
data.eyeTracked = 0;
% each of the following has nTrial+1 entries.  The first one is the
% fixation trial (run by playTrial_prep)

data.stim.targSeq = [nan thisplan(:,4)'];
data.stim.targLet = char([nan thisplan(:,3)']);
data.stim.fixXY = nan(length(data.stim.targSeq),2);
data.stim.thFix = unique (thisplan(:,2));%fixation location for this block

PM_ind = find(cellfun(@(x) x.loc == data.stim.thFix, expmnt.adaptiveComp));%find which PM needs to be updated for this block


thisGaze = 1;
thisStim = 1;

% initial blank screen
WaitSecs(0.2);
FlushEvents('KeyDown');
Screen('FillRect',win,expmnt.bgColor);
Screen('Flip',win);

% calibrate eye tracker if needed
if expmnt.useEyeTracker == 1
    % eyetracker data file (one file per block)
    eyeTrackerFileName = [eyeTrackerBaseName num2str(expmnt.thisBlock,'%03d') '.edf'];    
    s = Eyelink('OpenFile', eyeTrackerFileName);    
    data.eyeTracked = 1; % assume eye calibration is skipped
    if expmnt.thisBlock - lastEyeCalBlk >= expmnt.eyeCalInterval
        calibrateEye;
        if ~eyeCalSkipped
            lastEyeCalBlk = expmnt.thisBlock;
            data.eyeTracked = 2; %2 means that a calibration has been ran
        end
    end
end

% provide instructions
clear instruction
instruction{1} = sprintf('    Block #%d', ...
    expmnt.thisBlock);
instruction{3} = '     1) To strat the trial, fixate on the center';
instruction{4} = '     of the green cross.';
instruction{7} = '     2) After the cross disappears, You will see';
instruction{8} = '     a letter flashed on the screen.';
instruction{9} = '     You need to select this letter from the list';
instruction{10} = '     of possible answers using the keyboard or the mouse.';
instruction{13} = '     You will proceed to the next trial after you enter';
instruction{14} = '     your answer.';

instruction{16} = '    Press spacebar to begin';
instruction{17} = '    Press "q" to quit';
giveInstruction(win,instruction,textEntry,backgroundEntry);
userQuit = ~getContinueResponse;
if userQuit
    done = 1;
    return
end

% central fixation and drift correction
if expmnt.useEyeTracker == 1
    
    %     FlushEvents('KeyDown');
    %     result=EyelinkDoDriftCorrect(elHandle);
    %     fprintf(1,'EXPMNT: eye-tracker drift-correction result=%g\n',result);
    %
    %     WaitSecs(0.1);
    %     FlushEvents('KeyDown');
else
    giveInstruction(win,{'+'},textEntry,backgroundEntry);
    getContinueResponse;
    WaitSetMouse(randi(winWidth),randi(winHeight),win); % set cursor and wait for it to take effect
end


% start recording eye-position data
if expmnt.useEyeTracker == 1
    Eyelink('StartRecording');
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == elHandle.BINOCULAR; % if both eyes are tracked
        eye_used = elHandle.LEFT_EYE; % use left eye
    end
end

%% The game
playBlockFixation;%at the beginning of each block, show the fixation cross
%%task trials 
cueRec = [winCenter(1)-expmnt.cue.radious, winCenter(2)-expmnt.cue.radious,...
    winCenter(1)+expmnt.cue.radious, winCenter(2)+expmnt.cue.radious];%Location of the target. It hints the subject where to fixate on the screen 
for  ii = 2:expmnt.nTrial+1
    playOneTrial;  
    expmnt.adaptiveComp{PM_ind}.PM = PAL_AMPM_updatePM(expmnt.adaptiveComp{PM_ind}.PM,succ);    %update PM based on response    
end



%% Store data
data.numGazeIter = thisGaze-1;
data.gazeSeq     = gazeSeq(1:thisGaze-1,:);
data.gazeTime    = gazeTime(1:thisGaze-1,:);
data.gazePupil   = gazePupil(1:thisGaze-1,:);
data.gazeStimIdx = gazeStimIdx(1:thisGaze-1);
expmnt.data{end+1} = data;
expmnt.thisBlock = expmnt.thisBlock+1;
expmnt.randState = rand('state');
expmnt.randnState = randn('state');

% Provide performance summary

Screen(win,'TextSize',expmnt.instructSize);
Screen(win,'TextFont',expmnt.instructFont);
Screen('FillRect',win,expmnt.bgColor);
Screen('Flip',win);
% timeToAcq = nanmedian(data.stim.t2(2:end)-data.stim.t0(2:end));
minSize = round(10^(min(expmnt.adaptiveComp{PM_ind}.PM.x)) * expmnt.ppd);
msg = {};
% msg{1} =     sprintf('Your time this block: %.02f seconds per item',timeToAcq);
% if ~isfield(expmnt,'bestTime') || timeToAcq < expmnt.bestTime
%     expmnt.bestTime = timeToAcq;
%     msg{2} = 'THIS IS YOUR BEST TIME!!!';
% else
%     msg{2} = sprintf('Your best time:       %.02f seconds per time',expmnt.bestTime);
% end
if ~isfield(expmnt,'smallestSize') || minSize < expmnt.smallestSize
    expmnt.smallestSize = minSize;
    msg{1} = 'Good job! You made a new record! ';
    
end
msg{2} = sprintf('You recognized letters as small as %.02f pixels.',expmnt.smallestSize);
msg{4} = sprintf('You missed %d out of %d', sum(data.succ == 0) -1, expmnt.nTrial);

% Save data while the subject is reading the score (saving data take a few
% seconds
if expmnt.thisBlock-1-lastSavedBlk > expmnt.saveInterval
    msg{5} = 'Saving data ...';
    giveInstruction(win,msg,textEntry,backgroundEntry);
    save(dataFileName, 'expmnt');
    lastSavedBlk = expmnt.thisBlock-1;
    
    % stop recording eye-position data so we can save it on the eyetracker
    % machine
    if expmnt.useEyeTracker == 1
        Eyelink('StopRecording');
        Eyelink('closefile');
        
        status=Eyelink('ReceiveFile',eyeTrackerFileName, pwd,1);        
        if status~=0
            fprintf('Failed to receive eye tracker data file. Status: %d\n', status);
        end
        if exist(eyeTrackerFileName, 'file') == 2
            fprintf('Eye tracker data file ''%s'' can be found in ''%s''\n', eyeTrackerFileName, pwd );
        else
            fprintf('Eye tracker data file location unknown!\n')
        end
    end
    
end
msg{5} = 'Saving the file. Press spacebar to continue';
giveInstruction(win,msg,textEntry,backgroundEntry);
getContinueResponse;

% % stop recording eye-position data
% if expmnt.useEyeTracker == 1
%     Eyelink('StopRecording');
%     Eyelink('closefile');
%
%     status=Eyelink('ReceiveFile',eyeTrackerFileName, pwd,1);
%     if status~=0
%         fprintf('Failed to receive eye tracker data file. Status: %d\n', status);
%     end
%     if exist(eyeTrackerFileName, 'file') == 2
%         fprintf('Eye tracker data file ''%s'' can be found in ''%s''\n', eyeTrackerFileName, pwd );
%     else
%         fprintf('Eye tracker data file location unknown!\n')
%     end
% end
