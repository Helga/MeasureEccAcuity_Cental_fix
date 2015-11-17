function [targSize, succ] = readdata(sid)
load([sid, '.mat']);
nBlocks = length(expmnt.data);
targSize = [];
succ = [];
for i = 1:nBlocks
    curBlock = expmnt.data{i};
    succ = [succ ;curBlock.succ'];
    targSize = [targSize; curBlock.stim.targSize];
end
    