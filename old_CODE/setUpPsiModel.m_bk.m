%Set up psi(marginal)

alphaOffset = rand(1)*.3 - .15; %jitter prior
betaOffset = rand(1)*.3 - .15;
num_steps = 51;

PF = @PAL_Gumbel; %generating and assumed function

priorAlphaRange = log10(linspace(0.01,1,num_steps)) + alphaOffset;
priorBetaRange = log10(linspace(0.0316,31.6228,num_steps)) + betaOffset; % -1.5 ~ 1.5 in log scale
priorLambdaRange = 0:.01:.1;
gamma = 1/expmnt.nFixLocations;

%Stimulus values the method can select from
%  stimRange = (linspace(PF([0 1 0 0],.7,'inverse'),PF([0 1 0 0],.9999,'inverse'),41));
% stimRange = (linspace(.1,3,41));
stimRange = log10(linspace(0.001,2,num_steps));


 %Initialize PM structures for all locations
 %each location has its own Psi method to find the threshold for that
 %location
for i = 1: expmnt.nFixLocations
    adaptiveComp{i}.PM = PAL_AMPM_setupPM('priorAlphaRange',single(priorAlphaRange),...
        'priorBetaRange',single(priorBetaRange),'priorGammaRange',single(gamma),...
        'priorLambdaRange',single(priorLambdaRange), 'numtrials',expmnt.nTrial, 'PF' , PF,...
        'stimRange',single(stimRange));
    adaptiveComp{i}.loc = expmnt.locationToExamin(i);
   
end