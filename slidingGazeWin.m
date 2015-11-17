function slidingWin = slidingGazeWin(gazeTime, gazeSeq, w)
% returns the gaze location from the period of curTime-w to curTime

curTime = gazeTime(end, 2);

slidingWinStartTime = curTime - w ;
 if slidingWinStartTime < gazeTime(1, 2)    
    slidingWin = nan;
else
    slidingWinStartInd = find(gazeTime(:,2)>slidingWinStartTime, 1 );
    slidingWin = gazeSeq(slidingWinStartInd: end, :);
 end

