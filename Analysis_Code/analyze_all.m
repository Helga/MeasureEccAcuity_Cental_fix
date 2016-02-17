%plot RMSE for all subjects
clear
close all
pre = [1 0]; %pre or post measurement plots
subjs = { 'MF', 'SK'}%'TF', 'NA', 'PM'};
clr = [ 'b', 'r'];
crowding_exp = 1;
% if crowding_exp == 1
max_range = 1;
skip_ind = 3;
% else
%     max_range = 0.5;
% end
for i = 1:length(subjs)
    figure;
    %% fake date. Forcing matlab use the same plot range for all the subjects
    entro = max_range* ones(1,9);%fake data.
    fake_phi=0:pi/4:2*pi;
    h_fake = polar(fake_phi, entro);hold on
    set(h_fake,'Visible','off');
    for r=1:2
        if pre(r) == 1
            test = '(pre)';
            subj = subjs{i};
        else
            test = '(post)';
            subj = [subjs{i}, 'P'];
        end
        
        if crowding_exp == 1
            inpFileName =  [subj 'C.mat'];
            fname = ['Crowding', subjs{i}];
            
        else
            inpFileName =  [subj '.mat'];
            fname = ['Acuity', subjs{i}];
            
            
        end
        
        
        load(['../data/' inpFileName]);
        adaptiveComp = expmnt.adaptiveComp;
        for p=1:numel(adaptiveComp)
            t(p) = adaptiveComp{p}.PM.threshold(end);
            se_t(p) = adaptiveComp{p}.PM.seThreshold(end);
            s(p) = adaptiveComp{p}.PM.slope(end);
            se_s(p) = adaptiveComp{p}.PM.seSlope(end);
            phi(p) = adaptiveComp{p}.loc;
        end
        phi = to_testing_lcation_coordinates(phi);
        [sorted_phi, I]= sort(phi);
        sorted_t = 10.^t(I);
        thresh(:,i,r)= sorted_t;
        seThresh(:,i,r) = se_t(I);
        slope(:,i,r) = 10.^s(I);
        seSlope(:,i,r) = se_s(I);
        
        sorted_phi(end+1)= sorted_phi(1);%for plotting. Make sure the curve is a closed loop
        sorted_t(end+1) = sorted_t(1);
        h(r) = polar(sorted_phi, sorted_t, [clr(r), '--o']);hold on
        set(h(r), 'lineWidth', 3);
        
        
    end
    %     if crowding_exp == 1
    %         title(['Threshold estimates for crowding-', subjs{i}]);
    %     else
    %         title(['Threshold estimates for acuity-', subjs{i}]);
    %     end
    fig=gcf;
    set(findall(fig,'-property','FontSize'),'FontSize',20)
    % legend([h(1), h(2)], {'pre', 'post'})
    print('-depsc','-r300',['../EPS/' fname, '.eps'])
end
temp = thresh(:,:,2);
temp(skip_ind, :) = [];
acuity = temp(:);
if crowding_exp == 1
    save('../../VSS_res/CrowdedAcuity.mat', 'acuity', 'subjs');%pre data will be used in GLM analysis
    
else
    save('../../VSS_res/Acuity.mat', 'acuity', 'subjs');%pre data will be used in GLM analysis
end

% subplot(2,1,1);barweb(10.^thresh', seThresh');
% ylabel('Estimated threshold')
% set(gca, 'xTick', 1:length(phi(1,:)), 'XTickLabel', sorted_phi/pi)
% subplot(2,1,2);barweb(10.^(slope)', 10.^(seSlope)');
% ylabel('Estimated slope')
% set(gca, 'xTick', 1:length(phi(1,:)), 'XTickLabel', sorted_phi/pi)
% xlabel('Testing location (in \pi radian)')

