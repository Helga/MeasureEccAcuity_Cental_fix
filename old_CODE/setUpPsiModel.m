%Set up psi(marginal)


num_steps = 31;

PF = @PAL_Gumbel; %generating and assumed function
priorAlphaRange = log10(linspace(0.01,1,num_steps));
% priorAlphaRange = linspace(0.2,3,num_steps) ;
priorBetaRange = log10(linspace(0.0316,31.6228,num_steps)) ; % -1.5 ~ 1.5 in log scale
priorLambdaRange = 0:.01:.1;
gamma = 1/8;

%define possible stimulus levels, in degrees. Not yet in log units.
stimRange = linspace(0.001,2,num_steps);

 %Initialize PM structures for all locations
 %each location has its own Psi method to find the threshold for that
 %location
for i = 1: expmnt.nFixLocations
    expmnt.adaptiveComp{i}.PM = PAL_AMPM_setupPM('priorAlphaRange',single(priorAlphaRange),...
        'priorBetaRange',single(priorBetaRange),'priorGammaRange',single(gamma),...
        'priorLambdaRange',single(priorLambdaRange), 'numtrials',expmnt.nTrial, 'PF' , PF,...
        'stimRange',single(log10(stimRange)));
    expmnt.adaptiveComp{i}.loc = expmnt.locationToExamin(i);
   
end