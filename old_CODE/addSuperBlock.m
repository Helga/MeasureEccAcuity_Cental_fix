function plan = addSuperBlock(expmnt)
% Extend the existing plan by one superblock. Return the extended plan
% plan = [blk, targLet]


numRep = expmnt.nTrial;
numTargets= length( expmnt.targetPool);
locs = expmnt.locationToExamin;
nBlocks = length(locs);
plan = [];%the new superblock
for b = 1:nBlocks
    for r=1:numRep
        tInd(r) = randi(numTargets);
        tL(r) = expmnt.targetPool(tInd(r)).targLet;
    end
    
    
    blk = ones(numRep, 1) * b;
    locNum = ones(numRep, 1)*locs(b);
    temp = [blk(:) , locNum(:), double(tL(:)), tInd(:)];
    plan = [plan;temp];
end
if isfield(expmnt, 'plan')
    plan(:,1) = plan(:,1) + expmnt.plan(end, 1);
end
