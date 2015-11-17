function plot_psi_threshold(subjid, crowding)
if crowding == 1
    subjid = [subjid, 'C'];
end
load([subjid, '.mat']);
PMs = expmnt.adaptiveComp;
for i = 1:length(PMs)
    PM = PMs{i}.PM;
    loc = PMs{i}.loc;
    
    t = 1:length(PM.x)-1;
    subplot(2,4,i)
    plot(t,10.^(PM.x(1:end-1)),'k');
    hold on
    plot(t,10.^(PM.threshold),'b-','LineWidth',2)
    
    
    plot(t(PM.response == 1 ),10.^(PM.x(PM.response == 1 )),'ko', 'MarkerFaceColor','k');
    plot(t(PM.response == 0 ),10.^(PM.x(PM.response == 0 )),'ko', 'MarkerFaceColor','w');
    xlabel('Trial','fontsize',10);
    ylabel('size(\itx\rm)','fontsize',10);
    
    plot( 1, .9, 'ko', 'markerfacecolor','k')
    text(1.5, .9, 'correct');
    plot(1, 1, 'ko', 'markerfacecolor','w')
    text( 1.5, 1, 'incorrect');
    title(['Fixation at ', num2str(round(180*loc/3.14))]);
    
   
    alphaPM(i)=PM.threshold(end);
    logBetaPM(i)=PM.slope(end);
    alphaSePM(i)=PM.seThreshold(end);%from bootstrapping
    logBetaSePM(i)=PM.seSlope(end);
end
alphaPM
logBetaPM
alphaSePM
logBetaSePM



% alpha = 10^(PM.threshold(end));
%     beta = 10^(PM.slope(end));
%     gamma = PM.guess(end);
%     lambda = PM.lapse(end);
%     for i = 1:length(PMs)
%     get_psycho_curve(subj)
%     hold on
%     a = PAL_Gumbel([alpha, beta, gamma, lambda ], 10.^(PM.stimRange));
%     plot(10.^(PM.stimRange),a, 'LineWidth',2);
%     legend('data', 'Gumble psyc\_func', 'location', 'Best')
%     title(['\alpha=',num2str(alpha,2), ', \beta=',num2str(beta, 2),...
%         ', \gamma=',num2str(gamma, 2), ', \lambda=' ,num2str(lambda, 2)]);
%     set(gca,'FontSize',12);
    