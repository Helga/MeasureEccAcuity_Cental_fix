
function Y = get_psycho_curve(subjid)
%plots psychomoteric function for a given subject
numBins = 10;
bins = linspace(0.01,1,numBins);
dbin = diff(bins(1:2));
bins = bins(1:end-1)+dbin/2;

[targSize, succ] = readdata(subjid);
targSize = targSize/26.36; % pixels per degree


for ii=1:length(bins)
    idx = find(targSize>bins(ii)-dbin/2 & targSize<bins(ii)+dbin/2);
    Y(ii) = nanmean(succ(idx));
end
figure
plot(bins, Y, 'o');
ylabel('Percent correct');
xlabel('target size (degree)')

