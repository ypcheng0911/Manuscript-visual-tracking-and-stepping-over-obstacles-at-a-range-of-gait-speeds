
load('G:\Nordin_lab_data\Processed_data\Obstacle_avoidance\Eye_tracking_videos\Data_alignment.mat')
SUBJ_list = {'D01','D02','D03','D04','D06','D08','D09','D10',...
    'N01','N03','N04','N05','N06','N07','N08','N09','N10'};  % N02
object_class = {'Background','Path','Obstacle'};
ersp_xlims = [-441  6441];
x0 = {}; x1 = {}; x2 = {};
for tar_cond = 1:9
    gaze = [];
    epoch_t = [];
    epoch_t4m = [];
    for s = 1:length(SUBJ_list)
        if s==1
            eval(sprintf('gaze = DATA.Gaze_summary.%s{tar_cond};',SUBJ_list{s}))
            eval(sprintf('epoch_t = DATA.Mean_epoch_t.%s{tar_cond};',SUBJ_list{s}))
            eval(sprintf('epoch_t4m = DATA.Mean_obs_4m_t.%s(tar_cond);',SUBJ_list{s}))
        end
        eval(sprintf('gaze = horzcat(gaze,DATA.Gaze_summary.%s{tar_cond});',SUBJ_list{s}))
        eval(sprintf('epoch_t = vertcat(epoch_t,DATA.Mean_epoch_t.%s{tar_cond});',SUBJ_list{s}))
        eval(sprintf('epoch_t4m = horzcat(epoch_t4m,DATA.Mean_obs_4m_t.%s(tar_cond));',SUBJ_list{s}))

        % Process individual gaze behavior
        eval(sprintf('x = (DATA.Gaze_summary.%s{tar_cond}==0);',SUBJ_list{s})); x0{tar_cond,s} = sum(x,2);
        eval(sprintf('x = (DATA.Gaze_summary.%s{tar_cond}==1);',SUBJ_list{s})); x1{tar_cond,s} = sum(x,2);
        eval(sprintf('x = (DATA.Gaze_summary.%s{tar_cond}==2);',SUBJ_list{s})); x2{tar_cond,s} = sum(x,2);
    end
    GAZE{tar_cond} = gaze;
    Epoch_t{tar_cond} = epoch_t;
    Epoch_t4m{tar_cond} = epoch_t4m;
end

for i=1:9
    t_4m(i) = mean(Epoch_t4m{i});
end
peak_dis = -[2.1682 1.8075 1.4268 1.8676 1.436 1.2164 1.537 1.2365 1.0862]./t_4m*4;
peak_t = -[2.1682 1.8075 1.4268 1.8676 1.436 1.2164 1.537 1.2365 1.0862];
rel_sp = [0.75 1 1.25 1.25*0.75 1.25 1.25*1.25 1.5*0.75 1.5 1.5*1.25];
[s_rel_sp,s_idx] = sort(rel_sp);

% 
uiopen('G:\Nordin_lab_data\Processed_data\Obstacle_avoidance\Eye_tracking_videos\ALL_exceptN02_path.fig',1)
h = gcf;
for i=1:9; Ydata(i,:) = h.Children(i).Children(2).YData; end
for i=1:9; Xdata(i,:) = h.Children(i).Children(2).XData; end

SM_max_loc_ob = [];
SM_max_loc_path = [];
fullLat = [];
halfLat = [];
return_loc_path = [];
smooth_window = 10; % 100
for tar_cond = 1:9
    for s = 1:length(SUBJ_list)
        % [~,max_loc_ob(tar_cond,s)] = max(x2{tar_cond,s});
        % [~,min_loc_path(tar_cond,s)] = min(x1{tar_cond,s});

        [~,SM_max_loc_ob(tar_cond,s)] = max(smooth(x2{tar_cond,s},smooth_window));
        [~,SM_min_loc_path(tar_cond,s)] = min(smooth(x1{tar_cond,s},smooth_window));
        
        path_gaze_temp = smooth(x1{tar_cond,s},smooth_window);
        try
            fullLat(tar_cond,s) = find(path_gaze_temp(SM_min_loc_path(tar_cond,s)+1:end)>mean(path_gaze_temp(1198*0.95:1198*0.99)),1); 
        catch
            fullLat(tar_cond,s) = nan;
        end
        try
            halfLat(tar_cond,s) = find(path_gaze_temp(SM_min_loc_path(tar_cond,s)+1:end)> (mean(path_gaze_temp(1198*0.95:1198*0.99))/2) ,1);
        catch
            halfLat(tar_cond,s) = nan;
        end
   end
end
return_loc_path = SM_min_loc_path+fullLat;

max_ob_new = [];
return_path_new = [];
for i=1:size(SM_max_loc_ob,1); for j=1:size(SM_max_loc_ob,2); max_ob_new(i,j) = Xdata(1,SM_max_loc_ob(i,j)); end; end
for i=1:size(SM_max_loc_ob,1)
    for j=1:size(SM_max_loc_ob,2)
        try
            return_path_new(i,j) = Xdata(1,return_loc_path(i,j));
        catch
            return_path_new(i,j) = nan;
        end
    end
end

max_ob_new = -max_ob_new;

[p,tbl,stats] = friedman(max_ob_new(s_idx,:)');
multcompare(stats,'CType','bonferroni')
[p,tbl,stats] = friedman(return_path_new(s_idx,:)');
multcompare(stats,'CType','bonferroni')

% % Remove outlier (testing)
% max_ob_new(isoutlier(max_ob_new,2))= nan;
% return_path_new(isoutlier(return_path_new,2))= nan;

colors = {[0.3 0 0.3],[0.6 0 0.6],[1 0 1]};

close all
avg_path = mean(return_path_new,2,'omitmissing'); sem_path = std(return_path_new,[],2,'omitmissing')  / (size(return_path_new,2)^0.5);
avg_ob = mean(max_ob_new,2,'omitmissing'); sem_ob = std(max_ob_new,[],2,'omitmissing') / (size(max_ob_new,2)^0.5);
figure; errorbar(s_rel_sp,avg_path(s_idx),sem_path(s_idx),'o-','color',colors{2},'LineWidth',2); title('Latency - return to path')
xlabel('Relative approaching speed (m/s)')
ylabel('Latency (s)')
% set(gca,'ylim',[0 1.1])
Journal_ready_figure_settings
figure; errorbar(s_rel_sp,avg_ob(s_idx),sem_ob(s_idx),'o-','color',colors{3},'LineWidth',2); title('Latency - peak at obstacle')
xlabel('Relative approaching speed (m/s)')
ylabel('Latency (s)')
% set(gca,'ylim',[0.9 2.3])
Journal_ready_figure_settings

path_dis = abs(return_path_new./ (repmat(t_4m/4,17,1))' );
ob_dis = abs(max_ob_new./ (repmat(t_4m/4,17,1))' );

[p,tbl,stats] = friedman(ob_dis(s_idx,:)');
multcompare(stats,'CType','bonferroni')
[p,tbl,stats] = friedman(path_dis(s_idx,:)');
multcompare(stats,'CType','bonferroni')

% % Remove outlier (testing)
% path_dis(isoutlier(path_dis,2))= nan;
% ob_dis(isoutlier(ob_dis,2))= nan;

avg_ob_dis = mean(ob_dis,2,'omitmissing'); sem_ob_dis = std(ob_dis,[],2,'omitmissing')  / (size(ob_dis,2)^0.5);
avg_path_dis = mean(path_dis,2,'omitmissing'); sem_path_dis = std(path_dis,[],2,'omitmissing')  / (size(path_dis,2)^0.5);
figure; errorbar(s_rel_sp,avg_ob_dis(s_idx),sem_ob_dis(s_idx),'o-','color',colors{3},'LineWidth',2); title('Distance - peak at obstacle') 
xlabel('Relative approaching speed (m/s)')
ylabel('Distance (m)')
Journal_ready_figure_settings
figure; errorbar(s_rel_sp,avg_path_dis(s_idx),sem_path_dis(s_idx),'o-','color',colors{2},'LineWidth',2); title('Distance - return to path')
xlabel('Relative approaching speed (m/s)')
ylabel('Distance (m)')
Journal_ready_figure_settings


aa = max_ob_new(s_idx,:)';
cur = 1;
for i=1:8
    for j=2:9
        if j>i
            pvals(cur) = signrank(aa(:,i),aa(:,j));
            cur = cur+1;
        end
    end
end
fdr_pvals = mafdr(pvals); % FDR
hb_pvals = bonf_holm(pvals); % Holm-Bonferroni (recommended)
hb_pvals(hb_pvals>1) = 1;

%% Attempt for getting error bars, try smoothing to get individual metrics
figure
plot(smooth(x1{5,1},100))
hold on
for s=2:17
plot(smooth(x1{5,s},100))
end
figure;
plot(smooth(x2{5,1},100))
hold on
for s=2:17
plot(smooth(x2{5,s},100))
end
figure
plot(smooth(x1{5,1},200))
hold on
for s=2:17
plot(smooth(x1{5,s},200))
end
figure;
plot(smooth(x2{5,1},200))
hold on
for s=2:17
plot(smooth(x2{5,s},200))
end


%%

figure; plot(s_rel_sp,abs(peak_t(s_idx)),'o-','LineWidth',2)
xlabel('Relative approaching speed (m/s)')
ylabel('Peak latency (s)')
set(gca,'box','off','tickdir','out','fontsize',12)

figure; plot(s_rel_sp,abs(peak_dis(s_idx)),'o-','LineWidth',2)
xlabel('Relative approaching speed (m/s)')
ylabel('Distance (m)')
set(gca,'box','off','tickdir','out','fontsize',12)