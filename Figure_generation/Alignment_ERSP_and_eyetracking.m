clear
close all
clc

filepath = 'G:\Nordin_lab_data\Processed_data\Obstacle_avoidance\wBaselineAMICA_obloc_copy';
filename = 'RV15_new_final.study';

%-- Load study
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
[STUDY ALLEEG] = pop_loadstudy('filename', filename, 'filepath', filepath);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
% tar_clus = 3:length(STUDY.cluster);
tar_clus = 3:12;
cond_txt = {'0.75x','1x','1.25x'};
group_txt = {'1 m/s','1.25 m/s','1.5 m/s'};
subjs = STUDY.subject;

% fig_saving_file = fullfile(filepath,'EEG_and_Eyetracking');
fig_saving_file = fullfile(filepath,'EEG_and_Eyetracking_updated_Mar_2026');
mkdir(fig_saving_file)
cd(fig_saving_file)


load('G:\Nordin_lab_data\Processed_data\Obstacle_avoidance\Eye_tracking_videos\Data_alignment.mat')
SUBJ_list = {'D01','D02','D03','D04','D06','D08','D09','D10',...
    'N01','N03','N04','N05','N06','N07','N08','N09','N10'};  % N02
object_class = {'Background','Path','Obstacle'};
ersp_xlims = [-441  6441];
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
    end
    GAZE{tar_cond} = gaze;
    Epoch_t{tar_cond} = epoch_t;
    Epoch_t4m{tar_cond} = epoch_t4m;
end

sig_mask = 'y';
close all
for c = tar_clus
    [STUDY, erspdata, ersptimes, erspfreqs] = std_erspplot(STUDY,ALLEEG,'clusters',c, 'design', 1 );
    close
    tick_freqs = [4 8 13 30];
    for i=1:length(tick_freqs)
        [~,ersp_freq_pnt(i)] = min(abs(erspfreqs - tick_freqs(i)));
    end

    clearvars SUBJ_avg_ersp temp_ersp
    for cond = 1:length(cond_txt)
        for gp = 1:length(group_txt)
            clus_subj_list = STUDY.cluster(c).sets(1,:)/size(STUDY.cluster(c).sets,1);
            n = 1;
            for s = unique(clus_subj_list)
                idx_in_clus = find(clus_subj_list==s);
                % fixed 05/22/2025
                clearvars temp_ersp
                %--
                for t = 1:length(idx_in_clus)
                    temp_ersp(:,:,t) = erspdata{cond,gp}(:,:,idx_in_clus(t));
                end
                SUBJ_avg_ersp{cond,gp}(:,:,n) = reshape(mean(temp_ersp,3),100,200);
                % WARPED_ersp{cond,gp}(:,:,n) = reshape(mean(temp_ersp,3),100,400);
                n = n+1;
            end
        end
    end
    SUBJ_avg_ersp = SUBJ_avg_ersp';


    %-- calculates CI for ERSP
    [m,n] = size(SUBJ_avg_ersp);
    if strcmp(sig_mask,'y')
        for i=1:m
            for j=1:n
                ERSPs = SUBJ_avg_ersp{i,j};
                input = mean(ERSPs,3); % average across subjects
                CI_boot{i,j} = bootstat(input,'arg1','boottype','shuffle','bootside','both','naccu',500,'alpha',0.05,'dimaccu',2);
                sig = input < CI_boot{i,j}(:,1) | input > CI_boot{i,j}(:,2);
                sig_ersp = input.*sig;
                SIG{i,j} = sig;
                SIG_ERSP{i,j} = sig_ersp; 

            end
        end
    end

    obj_text = {'background','path','obstacle'};
    % for obj = 1:3
    %     %=====================
    %     figure('Position',[500 50 950 560])
    %     iter = 1;
    %     for j = 1:length(group_txt)    % for RV15.study
    %         for i = 1:length(cond_txt)
    %             subplot(3,3,iter)
    %             if strcmp(sig_mask,'y')
    %                 plot_data = flip(SIG_ERSP{j,i});
    %                 plot_data = smoothdata2(plot_data);
    %             else
    %                 plot_data = flip(reshape(mean(SUBJ_avg_ersp{j,i},3),100,200),1);
    %             end
    % 
    %             % plot_data = smoothdata2(plot_data,'movmedian',SmoothingFactor=0.25);
    %             imagesc(ersptimes, 1:100, plot_data,'AlphaData',0.5)
    %             clims(iter,:) = get(gca,'clim');
    %             colormap jet
    %             set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs))
    %             % xlim([target_pnts(2)-10 target_pnts(end-1)+10])
    %             title([group_txt{j},'_',cond_txt{i}],'interpreter','none') % for RV15.study
    %             ylabel('Frequency (Hz)')
    %             xlabel('Time (ms)')
    % 
    %             % colororder({'m'})
    %             % hold on
    %             % yyaxis right
    %             % testhist = sum(GAZE{iter}==(obj-1),2,'omitnan'); % 2 for obj
    %             % testhist = 100*testhist/(10*length(SUBJ_list));
    %             % plot(mean(Epoch_t{iter})*1000 - mean(Epoch_t4m{iter})*1000,testhist,'LineWidth',2,'Color','m')
    %             % set(gca,'ylim',[0 100])
    %             % % title(DATA.conds{tar_cond},'Interpreter','none')
    %             % ylabel('Percent (%)')
    %             % % xlabel('Time to contact (s)')
    %             % % hold on
    %             % % line([mean(epoch_t4m) mean(epoch_t4m)]*1000,[0 10*length(SUBJ_list)],'linestyle','--')
    %             % line([0 0],[0 100],'linestyle','--','color','k','linewidth',1.5)
    %             % line([0 0]-mean(Epoch_t4m{iter})*1000,[0 100],'linestyle','--','linewidth',1.5,'color','k')
    %             iter = iter+1;
    %         end
    %     end
    %     iter = 1;
    %     for i = 1:length(cond_txt)
    %         for j = 1:length(group_txt)
    %             subplot(3,3,iter)
    %             set(gca,'clim',[-max(abs(clims(:))) max(abs(clims(:)))])
    % 
    %             colororder({'m'})
    %             hold on
    %             yyaxis right
    %             testhist = sum(GAZE{iter}==(obj-1),2,'omitnan'); % 2 for obj
    %             testhist = 100*testhist/(10*length(SUBJ_list));
    %             plot(mean(Epoch_t{iter})*1000 - mean(Epoch_t4m{iter})*1000,testhist,'LineWidth',2,'Color','m')
    %             set(gca,'ylim',[0 100])
    %             % title(DATA.conds{tar_cond},'Interpreter','none')
    %             ylabel('Percent (%)')
    %             % xlabel('Time to contact (s)')
    %             % hold on
    %             % line([mean(epoch_t4m) mean(epoch_t4m)]*1000,[0 10*length(SUBJ_list)],'linestyle','--')
    %             line([0 0],[0 100],'linestyle','--','color','k','linewidth',1.5)
    %             line([0 0]-mean(Epoch_t4m{iter})*1000,[0 100],'linestyle','--','linewidth',1.5,'color','k')
    % 
    %             iter = iter+1;
    %         end
    %     end
    %     if strcmp(sig_mask,'y')
    %         fig_name = sprintf('Cluster %d_%s_sig.png',c,obj_text{obj});
    %         saveas(gcf,fig_name)
    %         matfig_name = sprintf('Cluster %d_%s_sig.fig',c,obj_text{obj});
    %         saveas(gcf,matfig_name)
    %     else
    %         fig_name = sprintf('Cluster %d_%s.png',c,obj_text{obj});
    %         saveas(gcf,fig_name)
    %         matfig_name = sprintf('Cluster %d_%s.fig',c,obj_text{obj});
    %         saveas(gcf,matfig_name)
    %     end
    % end

    %== Figure generation and storage
    figure('Position',[500 50 950 560])
    iter = 1;
    for j = 1:length(group_txt)    % for RV15.study
        for i = 1:length(cond_txt)
            subplot(3,3,iter)
            if strcmp(sig_mask,'y')
                plot_data = flip(SIG_ERSP{j,i});
                plot_data = smoothdata2(plot_data);
            else
                plot_data = flip(reshape(mean(SUBJ_avg_ersp{j,i},3),100,200),1);
            end

            % plot_data = smoothdata2(plot_data,'movmedian',SmoothingFactor=0.25);
            imagesc(ersptimes, 1:100, plot_data,'AlphaData',1)  % changed from 0.5 to 0.8 or 1
            clims(iter,:) = get(gca,'clim');
            colormap jet
            set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs))
            % xlim([target_pnts(2)-10 target_pnts(end-1)+10])
            title([group_txt{j},'_',cond_txt{i}],'interpreter','none') % for RV15.study
            ylabel('Frequency (Hz)')
            xlabel('Time (ms)')

            iter = iter+1;
        end
    end
    iter = 1;
    for i = 1:length(cond_txt)
        for j = 1:length(group_txt)
            subplot(3,3,iter)
            set(gca,'clim',[-max(abs(clims(:))) max(abs(clims(:)))])

            colororder({'m'})
            colors = {[0.3 0 0.3],[0.6 0 0.6],[1 0 1]};
            hold on
            yyaxis right
            for obj = 1:3
                testhist = sum(GAZE{iter}==(obj-1),2,'omitnan'); % 2 for obj
                testhist = 100*testhist/(10*length(SUBJ_list));
                testhist = smooth(testhist,50); % For publication visualization - added 03/07/2026
                plot(mean(Epoch_t{iter})*1000 - mean(Epoch_t4m{iter})*1000,testhist,'LineWidth',2,'Color',colors{obj},'LineStyle','-')
            end
            set(gca,'ylim',[0 100])
            % title(DATA.conds{tar_cond},'Interpreter','none')
            ylabel('Percent (%)')
            % xlabel('Time to contact (s)')
            % hold on
            % line([mean(epoch_t4m) mean(epoch_t4m)]*1000,[0 10*length(SUBJ_list)],'linestyle','--')
            line([0 0],[0 100],'linestyle','--','color','k','linewidth',1.5,'marker','none')
            line([-mean(Epoch_t4m{iter})*1000 -mean(Epoch_t4m{iter})*1000],[0 100],'linestyle','--','linewidth',1.5,'color','k','marker','none')
            
            set(gca,'FontName','Calibri','FontSize',10)
            iter = iter+1;
        end
    end

    %-- Save figures
    if strcmp(sig_mask,'y')
        fig_name = sprintf('Cluster %d_overlap_sig.png',c);
        saveas(gcf,fig_name)
        matfig_name = sprintf('Cluster %d_overlap_sig.fig',c);
        saveas(gcf,matfig_name)
    else
        fig_name = sprintf('Cluster %d_overlap.png',c);
        saveas(gcf,fig_name)
        matfig_name = sprintf('Cluster %d_overlap.fig',c);
        saveas(gcf,matfig_name)
    end
close all
end

disp('End of figure generation.')