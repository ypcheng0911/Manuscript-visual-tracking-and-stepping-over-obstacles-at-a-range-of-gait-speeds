%%% Generates a PPT file containing Cluster dipoles, PSD & ERSP
%%% Run processing pipeline V6 or V7 before this code.
%%% Precompute Scalp map, PSD, ERSP & Cluster ICs

clear
close all
clc

%% Load data & create save folder
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

filepath = 'G:\Nordin_lab_data\Processed_data\Obstacle_avoidance\wBaselineAMIVA_copy';
% filename = 'RV15.study';
% filename = 'RV15_new.study';
filename = 'RV15_new_final.study';

% savepath = fullfile(filepath,'result_fig_fooofPSD_Mar2026');
% savepath = fullfile(filepath,'result_fig_fooofPSD_holmbonf_Mar2026');
savepath = fullfile(filepath,'result_fig_fooofPSD_fdr_Mar2026');
mkdir(savepath)
cd(savepath)


exclude_outlier = 'n';
Compute_dipole = 'y';
%-- ERSP mask
sig_mask = 'y';
change_ersp_xlim = 'y';
ppt_name = [filename(1:end-6),'.pptx'];

%% Create and save figures
[STUDY ALLEEG] = pop_loadstudy('filename', filename, 'filepath', filepath);
CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];

% tar_clus = 3:length(STUDY.cluster);
tar_clus = 3:12;
if strcmp(Compute_dipole,'y')
    %-- Dipole
    clearvars clus_dipoles sub_id_list comp_id_list
    dip_cen = {}; % to store the centroid xyz (in MNI format, can change to TAL using mni2tal function)
    for c=tar_clus
        try
        cond_size = size(STUDY.cluster(c).sets,1);
        sub_id_list{c} = STUDY.cluster(c).sets(1,:)/cond_size;
        comp_id_list{c} = STUDY.cluster(c).comps;
        clearvars avg_posxyz avg_momxyz avg_rv
        l=1;
        for sub_id = unique(sub_id_list{c})
            comps_each_sub = comp_id_list{c}(find(sub_id_list{c}==sub_id));

            avg_posxyz{sub_id} = mean(vertcat(ALLEEG((sub_id-1)*cond_size+1).dipfit.model(comps_each_sub).posxyz),1);
            avg_momxyz{sub_id} = mean(vertcat(ALLEEG((sub_id-1)*cond_size+1).dipfit.model(comps_each_sub).momxyz),1);
            avg_rv{sub_id} = mean(vertcat(ALLEEG((sub_id-1)*cond_size+1).dipfit.model(comps_each_sub).rv),1);

            clus_dipoles{c}(l).posxyz = avg_posxyz{sub_id};
            clus_dipoles{c}(l).momxyz = avg_momxyz{sub_id};
            clus_dipoles{c}(l).rv = avg_rv{sub_id};
            l=l+1;
        end
        dip_cen{c} = mean(vertcat(clus_dipoles{c}(:).posxyz),1);
        abset = min(find(sub_id_list{c}==sub_id));

        figure;
        dipplot(clus_dipoles{c},'meshdata', ALLEEG(abset).dipfit.hdmfile, 'mri', ALLEEG(abset).dipfit.mrifile,'coordformat', ALLEEG(abset).dipfit.coordformat , ...
            'normlen' ,'on', 'pointout' ,'on','color', {'b'},'spheres', 'on', 'verbose', 'off',...
            'gui','off','dipolelength',0,'view',[0 -1 0]);
        saveas(gcf,sprintf('cluster%02d_dipole_cor.png',c));
        %-- [0 0 1] for horizontal, [0 -1 0] for coronal, [1 0 0] for sagittal

        %-- Default dipole figure function
        figure;
        dipplot(clus_dipoles{c},'meshdata', ALLEEG(abset).dipfit.hdmfile, 'mri', ALLEEG(abset).dipfit.mrifile,'coordformat', ALLEEG(abset).dipfit.coordformat , ...
            'normlen' ,'on', 'pointout' ,'on','color', {'b'},'spheres', 'on', 'verbose', 'off',...
            'gui','off','dipolelength',0,'view',[0 0 1]);
        saveas(gcf,sprintf('cluster%02d_dipole_hor.png',c));

        figure;
        dipplot(clus_dipoles{c},'meshdata', ALLEEG(abset).dipfit.hdmfile, 'mri', ALLEEG(abset).dipfit.mrifile,'coordformat', ALLEEG(abset).dipfit.coordformat , ...
            'normlen' ,'on', 'pointout' ,'on','color', {'b'},'spheres', 'on', 'verbose', 'off',...
            'gui','off','dipolelength',0,'view',[1 0 0]);
        saveas(gcf,sprintf('cluster%02d_dipole_sag.png',c));
        end
    end
    close all
end
%% fooof psd
%-- PSD
freqrange = [2 55];
STUDY = pop_statparams(STUDY, 'condstats','on','alpha',0.05);
STUDY = pop_specparams(STUDY, 'freqrange',freqrange);
with_band_name = 'n';
if with_band_name == 'y'
    band_xtick = [3 3.5 4 6 8 10.5 13 21.5 30 65 100];
    band_xticklabels = {' 3 ',' δ ',' 4 ',' θ ',' 8 ',' α ',' 13',' β ',' 30',' γ ','100'};
else
    band_xtick = [3 4 8 13 30 60 100];
    band_xticklabels = {'3  ','  4','  8',' 13',' 30',' 60','100'};
end
%===== Use individual IC (in all conditions / without pre-average) as input 
eglb_color = [0,0,1;0,0.6,0;1,0,0;0,1,1];
% freq_range = {[3 4],[4 8],[8 13],[13 30],[30 60],[60 100]};
freq_range = {[4 8],[8 13],[13 30],[30 55]};
% freq_ticks = [4 8 13 30 60 100];
freq_ticks = [4 8 13 30];

STUDY = pop_statparams(STUDY, 'condstats','on','alpha',0.05);
STUDY = pop_specparams(STUDY, 'plotconditions','together','freqrange',freqrange);
% band_only_labels = {' δ ',' θ ',' α ',' β ','lo γ','hi γ'};
band_only_labels = {' θ ',' α ',' β ','lo γ'};
[STUDY, specdata, specfreqs, pgroup, pcond, pinter] = std_specplot(STUDY,ALLEEG,'clusters',tar_clus(1), 'design', 1);
close all

clearvars Detrend_psd Detrend_psd_linear avg_specdata fooof_results_all no_offset_psd psd_no_offset_T
for c= tar_clus
    try
        clearvars c_detrend_psd new_specdata m_temp_mean m_temp c_detrend_psd_linear
        sub_id_list{c} = STUDY.cluster(c).sets(1,:)/size(STUDY.cluster(3).sets,1);  %8, 14

        %============ Data selection
        [STUDY, specdata, allfreqs] = std_readspec(STUDY, ALLEEG, 'clusters',c, 'design', 1); % All
        % [STUDY, specdata, allfreqs] = std_readspec(STUDY, ALLEEG, 'clusters',c, 'design', 2); % Static Obj
        %------------
        [m, n] = size(specdata);
        for i=1:m
            for j=1:n
                l = 1;
                for sub_id = unique(sub_id_list{c})
                    m_temp = specdata{i,j}(:,find(sub_id_list{c}==sub_id));
                    m_temp_mean = mean(specdata{i,j}(:,find(sub_id_list{c}==sub_id)),2);
                    new_specdata{i,j}(:,l) = m_temp_mean;
                    l=l+1;
                end
            end
        end
        avg_specdata{c} = new_specdata;

        %-- FOOOF detrend & settings
        settings = struct();  % Use defaults

        %-- FOOOF parameter
        % settings.aperiodic_mode = 'knee';
        f_range = freqrange;
        freqs = allfreqs; %2:101';
        for i=1:m
            for j=1:n
                psd_temp = new_specdata{i,j};
                for k=1:size(psd_temp,2)
                    %-- Transpose, to make inputs row vectors
                    psd = psd_temp(:,k)';
                    %-- Run FOOOF, also returning the model
                    clearvars fooof_results
                    fooof_results = fooof(freqs, psd, f_range, settings, true);
                    %-- Detrend: psd - ap_fit
                    % %                 c_detrend_psd{i,j}(:,k) = fooof_results.power_spectrum - fooof_results.ap_fit;
                    detrended_temp = 10.^fooof_results.power_spectrum - 10.^fooof_results.ap_fit;
                    % detrended_temp = fooof_results.power_spectrum - fooof_results.ap_fit;
                    %==
                    c_detrend_psd{i,j}(:,k) = detrended_temp;
                    psd_no_offset_T{i,j}(:,k) = 10.^fooof_results.power_spectrum;
                    % psd_no_offset_T{i,j}(:,k) = fooof_results.power_spectrum;
                    fooof_results_all(c,i,j,k) = fooof_results;
                end
            end
        end
        Detrend_psd{c} = c_detrend_psd;
        no_offset_psd{c} = psd_no_offset_T;
    catch
        continue
    end
end

%-- Parameter setting
stats_psd.effect = 'main';
stats_psd.groupstats = 'on';
stats_psd.condstats = 'on';
stats_psd.singletrials = 'off';
stats_psd.mode = 'eeglab';
stats_psd.eeglab.naccu = 5000; % 1000, 50
stats_psd.eeglab.alpha = 0.05; 
stats_psd.eeglab.method = 'bootstrap'; % param, bootstrap
stats_psd.eeglab.mcorrect = 'none';  %'none', 'fdr'
stats_psd.paired = {'on','on'};

%-- Speed effect, Design 1: effect on column, averaging the row
%-- Added multiple comparison 01/16/2024
% freq_ticks = [4 8 13 30 60 100];
eglb_color = [0,0,1 ; 0.4,0.4,0.4 ; 1,0,0 ; 0,1,0];
% eglb_color_objspeed = [0,0,1; 0,1,0; 1,0,1; 0,1,1; 1,0,0; 0,0,0; 1,1,0];
band_name_C = {'Theta','Alpha','Beta','Gamma'};
band_name = {'theta','alpha','beta','gamma'};

clearvars STATS
%-- Figure creation
for c=tar_clus
    % c=3;
    data = Detrend_psd{c};
    data = data'; % for RV15.study
    [m, n] = size(data);
    if m==0 | n==0
        continue
    end
    
    %-- Obstacle conditions
    clearvars cond_avg psd_avg cond_all_sub cond_avg band_m_all_sub
    for j=1:n
        psd_temp = zeros(size(data{1,1}));
        for i=1:m
            psd_temp = psd_temp + data{i,j};
        end
        psd_avg = psd_temp/m;
        band_mean = [];
        for fr=1:length(freq_range)
            stat_f_range = find(round(specfreqs) == freq_range{fr}(1)): find(round(specfreqs) == freq_range{fr}(2));
            band_mean(fr,:) = mean(psd_avg(stat_f_range,:),1);
        end
        band_m_all_sub{j} = band_mean;
        cond_all_sub{j,1} = psd_avg;
        cond_avg{j} = mean(psd_avg,2);
    end
    
    %---
    [pcond, pgroup, pinter] = std_stat(cond_all_sub, stats_psd);
    % std_plotcurve(allfreqs,cond_all_sub,'condstats',pcond,'groupstats',pgroup,'interstats',pinter,'plotconditions','together','plotgroups','apart','threshold',0.05,'datatype','spec','unitx','Hz','effect','main')
    std_plotcurve(allfreqs,cond_all_sub,'plotconditions','together','plotgroups','apart','threshold',0.05,'datatype','spec','unitx','Hz','effect','main')
    set(gca,'box','off','tickdir','out')
    H = gcf;
    % H.Position = [100 100 540 400];
    
    Lines = H.Children.Children;
    for l = 1:length(Lines)
        Lines(l).LineWidth = 2;
        Lines(l).YData = smooth(Lines(l).YData,10);  % publication visualization - added 03/07/2026
        Lines(l).Color = eglb_color(end-l+1,:);
    end
    % set(gca,'box','off','linewidth',1.5,'fontsize',16)
    set(gca,'xtick',[1 4 8 13 30 50])
    set(gca,'box','off','linewidth',1.5)
    % H.Children(2).LineWidth = 1.5;
    % H.Children(2).FontSize = 16;
    ylabel('Power (dB)') %-- update the unit if possible
    % title(sprintf('Cluster %02d',c))
    legend('0.75x','1.0x','1.25x','unobstructed','box','off','Location','southoutside')
    set(gcf,'position',[100 100 400 560])
    yticks = get(gca,'ytick');
    contain_neg = 0;
    if sum(yticks<0)>0
        contain_neg = 1;
        yticklabels = get(gca,'yticklabel');
        neg_ticks = find(yticks<0);
        for nnn = 1:length(neg_ticks)
            yticklabels{nnn}(1) = '−';
        end
        set(gca,'yticklabel',yticklabels)
    end
    saveas(gcf,sprintf('cluster%02d_fooof_PSD_obstacle.png',c));
    saveas(gcf,sprintf('cluster%02d_fooof_PSD_obstacle.fig',c));

    % legend('obstacle\_075x','obstacle\_1x','obstacle\_125x','unobstructed','location','eastoutside')
    %---
    
    eval(sprintf('STATS.c%02d.RawData = data;',c))
    for bnd = 1:4
        eval(sprintf('%s_data = cell2mat(cellfun(@(x) x(%d,:)'',band_m_all_sub,''UniformOutput'',false));',band_name{bnd},bnd))
        if strcmp(exclude_outlier,'y')
            eval(sprintf('%s_data(isoutlier(%s_data,1)) = nan;',band_name{bnd},band_name{bnd}))
        end
        eval(sprintf('STATS.c%02d.OBS.%s.Data = %s_data;',c,band_name_C{bnd},band_name{bnd}))
        %--- Friedman
        eval(sprintf('[STATS.c%02d.OBS.%s.Friedman.p,STATS.c%02d.OBS.%s.Friedman.tbl,STATS.c%02d.OBS.%s.Friedman.stats]= friedman(%s_data);',c,band_name_C{bnd},c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd}))
        %--- Anova1 with outlier removed
        eval(sprintf('anova_%s_data = %s_data;',band_name{bnd},band_name{bnd}))
        eval(sprintf('anova_%s_data(isoutlier(anova_%s_data)) = nan;',band_name{bnd},band_name{bnd}))
        eval(sprintf('[STATS.c%02d.OBS.%s.ANOVA.p,STATS.c%02d.OBS.%s.ANOVA.tbl,STATS.c%02d.OBS.%s.ANOVA.stats]= anova1(anova_%s_data);',c,band_name_C{bnd},c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd}))
        eval(sprintf('STATS.c%02d.OBS.%s.ANOVA.multcompare = multcompare(STATS.c%02d.OBS.%s.ANOVA.stats);',c,band_name_C{bnd},c,band_name_C{bnd}))
        %--- Pairwise signed rank test
        eval(sprintf('[STATS.c%02d.OBS.%s.SignRank.p_1v2, STATS.c%02d.OBS.%s.SignRank.h_1v2] = signrank(%s_data(:,1),%s_data(:,2));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
        try
            eval(sprintf('[STATS.c%02d.OBS.%s.SignRank.p_1v3, STATS.c%02d.OBS.%s.SignRank.h_1v3] = signrank(%s_data(:,1),%s_data(:,3));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
            eval(sprintf('[STATS.c%02d.OBS.%s.SignRank.p_2v3, STATS.c%02d.OBS.%s.SignRank.h_2v3] = signrank(%s_data(:,2),%s_data(:,3));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
        end
        try
            eval(sprintf('[STATS.c%02d.OBS.%s.SignRank.p_1v4, STATS.c%02d.OBS.%s.SignRank.h_1v4] = signrank(%s_data(:,1),%s_data(:,4));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
            eval(sprintf('[STATS.c%02d.OBS.%s.SignRank.p_2v4, STATS.c%02d.OBS.%s.SignRank.h_2v4] = signrank(%s_data(:,2),%s_data(:,4));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
            eval(sprintf('[STATS.c%02d.OBS.%s.SignRank.p_3v4, STATS.c%02d.OBS.%s.SignRank.h_3v4] = signrank(%s_data(:,3),%s_data(:,4));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
        end
    end

    eval(sprintf('pvals = [STATS.c%02d.OBS.%s.SignRank.p_1v2 STATS.c%02d.OBS.%s.SignRank.p_1v3 STATS.c%02d.OBS.%s.SignRank.p_1v4 STATS.c%02d.OBS.%s.SignRank.p_2v3 STATS.c%02d.OBS.%s.SignRank.p_2v4 STATS.c%02d.OBS.%s.SignRank.p_3v4];',c,band_name_C{bnd},c,band_name_C{bnd},c,band_name_C{bnd},c,band_name_C{bnd},c,band_name_C{bnd},c,band_name_C{bnd}))
    % hb_pvals = bonf_holm(pvals); % Holm-Bonferroni (recommended)
    % hb_pvals(hb_pvals>1) = 1;
    % adj_pvals = hb_pvals;

    fdr_pvals = mafdr(pvals); % FDR, try out, not recommended
    fdr_pvals(fdr_pvals>1) = 1;
    adj_pvals = fdr_pvals;
    

    figure('Position',[300 300 1000 330])
    tiledlayout(1,4);
    for bnd = 1:4
        nexttile
        % eval(sprintf('subplot(1,4,%d); bar(mean(%s_data)); hold on; errorbar(1:4,mean(%s_data),std(%s_data),''k.'')',bnd,band_name{bnd},band_name{bnd},band_name{bnd}))
        % eval(sprintf('boxplot(%s_data); hold on;',band_name{bnd}))

        eval(sprintf('boxplot(%s_data,''Symbol'',''''); hold on;',band_name{bnd}))
        h = findobj(gca,'Tag','Box');
        for j=1:length(h)
            patch(get(h(j),'XData'),get(h(j),'YData'),eglb_color(length(h)+1-j,:),'FaceAlpha',.5);
        end
        set(gca,'XTickLabel',{'0.75x','1.0x','1.25x','unobstructed'},'box','off','tickdir','out','linewidth',1.5,'fontsize',12); ylabel('Power (dB)'); xlabel('Obstacle speed')
        title(band_name_C{bnd})
        ys = get(gca,'ylim');
        % if eval(sprintf('STATS.c%02d.OBS.%s.SignRank.p_1v2 < (0.05/6)  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd},c,band_name_C{bnd}))
        %     hold on; line([1 2],[max(ys) max(ys)]*1.1,'linewidth',2,'color','k')
        %     set(gca,'ylim',[min(ys) max(ys)*1.4])
        % end
        % if eval(sprintf('STATS.c%02d.OBS.%s.SignRank.p_1v3 < (0.05/6)  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd},c,band_name_C{bnd}))
        %     hold on; line([1 3],[max(ys) max(ys)]*1.25,'linewidth',2,'color','k')
        %     set(gca,'ylim',[min(ys) max(ys)*1.4])
        % end
        % if eval(sprintf('STATS.c%02d.OBS.%s.SignRank.p_2v3 < (0.05/6)  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd},c,band_name_C{bnd}))
        %     hold on; line([2 3],[max(ys) max(ys)]*1.15,'linewidth',2,'color','k')
        %     set(gca,'ylim',[min(ys) max(ys)*1.4])
        % end
        % if eval(sprintf('STATS.c%02d.OBS.%s.SignRank.p_1v4 < (0.05/6)  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd},c,band_name_C{bnd}))
        %     hold on; line([1 4],[max(ys) max(ys)]*1.35,'linewidth',2,'color','k')
        %     set(gca,'ylim',[min(ys) max(ys)*1.4])
        % end
        % if eval(sprintf('STATS.c%02d.OBS.%s.SignRank.p_2v4 < (0.05/6)  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd},c,band_name_C{bnd}))
        %     hold on; line([2 4],[max(ys) max(ys)]*1.3,'linewidth',2,'color','k')
        %     set(gca,'ylim',[min(ys) max(ys)*1.4])
        % end
        % if eval(sprintf('STATS.c%02d.OBS.%s.SignRank.p_3v4 < (0.05/6)  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd},c,band_name_C{bnd}))
        %     hold on; line([3 4],[max(ys) max(ys)]*1.2,'linewidth',2,'color','k')
        %     set(gca,'ylim',[min(ys) max(ys)*1.4])
        % end

        if eval(sprintf('adj_pvals(1) < 0.05  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd}))
            hold on; line([1 2],[max(ys) max(ys)]*1.1,'linewidth',2,'color','k')
            set(gca,'ylim',[min(ys) max(ys)*1.4])
        end
        if eval(sprintf('adj_pvals(2) < 0.05  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd}))
            hold on; line([1 3],[max(ys) max(ys)]*1.25,'linewidth',2,'color','k')
            set(gca,'ylim',[min(ys) max(ys)*1.4])
        end
        if eval(sprintf('adj_pvals(4) < 0.05  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd}))
            hold on; line([2 3],[max(ys) max(ys)]*1.15,'linewidth',2,'color','k')
            set(gca,'ylim',[min(ys) max(ys)*1.4])
        end
        if eval(sprintf('adj_pvals(3) < 0.05  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd}))
            hold on; line([1 4],[max(ys) max(ys)]*1.35,'linewidth',2,'color','k')
            set(gca,'ylim',[min(ys) max(ys)*1.4])
        end
        if eval(sprintf('adj_pvals(5) < 0.05  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd}))
            hold on; line([2 4],[max(ys) max(ys)]*1.3,'linewidth',2,'color','k')
            set(gca,'ylim',[min(ys) max(ys)*1.4])
        end
        if eval(sprintf('adj_pvals(6) < 0.05  && STATS.c%02d.OBS.%s.Friedman.p<0.05',c,band_name_C{bnd}))
            hold on; line([3 4],[max(ys) max(ys)]*1.2,'linewidth',2,'color','k')
            set(gca,'ylim',[min(ys) max(ys)*1.4])
        end

    end
    % saveas(gcf,sprintf('cluster%02d_fooof_bandmean_obstacle_stats.png',c));
    if strcmp(exclude_outlier,'y')
        saveas(gcf,sprintf('cluster%02d_fooof_boxplot_obstacle_stats_NoOutlier.png',c));
    else
        saveas(gcf,sprintf('cluster%02d_fooof_boxplot_obstacle_stats.png',c));
        saveas(gcf,sprintf('cluster%02d_fooof_boxplot_obstacle_stats.fig',c));
    end

    %--- Gait speed
    clearvars cond_avg psd_avg cond_all_sub cond_avg band_m_all_sub
    for i=1:m
        psd_temp = zeros(size(data{1,1}));
        for j=1:n
            psd_temp = psd_temp + data{i,j};
        end
        psd_avg = psd_temp/n;
        band_mean = [];
        for fr=1:length(freq_range)
            stat_f_range = find(round(specfreqs) == freq_range{fr}(1)): find(round(specfreqs) == freq_range{fr}(2));
            band_mean(fr,:) = mean(psd_avg(stat_f_range,:),1);
        end
        band_m_all_sub{i} = band_mean;
        cond_all_sub{i,1} = psd_avg;
        cond_avg{i} = mean(psd_avg,2);
    end
    
    %---
    [pcond, pgroup, pinter] = std_stat(cond_all_sub, stats_psd);
    % std_plotcurve(allfreqs,cond_all_sub,'condstats',pcond,'groupstats',pgroup,'interstats',pinter,'plotconditions','together','plotgroups','apart','threshold',0.05,'datatype','spec','unitx','Hz','effect','main')
    std_plotcurve(allfreqs,cond_all_sub,'plotconditions','together','plotgroups','apart','threshold',0.05,'datatype','spec','unitx','Hz','effect','main')
    set(gca,'box','off','tickdir','out')
    H = gcf;
    % H.Position = [100 100 540 400];
    Lines = H.Children.Children;
    for l = 1:length(Lines)
        Lines(l).LineWidth = 2;
        Lines(l).YData = smooth(Lines(l).YData,10);  % publication visualization - added 03/07/2026
        Lines(l).Color = eglb_color(end-l,:);
    end
    set(gca,'xtick',[1 4 8 13 30 50])
    set(gca,'box','off','linewidth',1.5)
    % H.Children(2).LineWidth = 1.5;
    % H.Children(2).FontSize = 16;
    ylabel('Power (dB)') %-- update the unit if possible
    % title(sprintf('Cluster %02d',c))
    legend('1.0 m/s','1.25 m/s','1.5 m/s','box','off','Location','southoutside')
    set(gcf,'position',[100 100 400 490])
    yticks = get(gca,'ytick');
    contain_neg = 0;
    if sum(yticks<0)>0
        contain_neg = 1;
        yticklabels = get(gca,'yticklabel');
        neg_ticks = find(yticks<0);
        for nnn = 1:length(neg_ticks)
            yticklabels{nnn}(1) = '−';
        end
        set(gca,'yticklabel',yticklabels)
    end
    saveas(gcf,sprintf('cluster%02d_fooof_PSD_speed.png',c));
    saveas(gcf,sprintf('cluster%02d_fooof_PSD_speed.fig',c));
    %---
    
    for bnd = 1:4
        eval(sprintf('%s_data = cell2mat(cellfun(@(x) x(%d,:)'',band_m_all_sub,''UniformOutput'',false));',band_name{bnd},bnd))
        if strcmp(exclude_outlier,'y')
            eval(sprintf('%s_data(isoutlier(%s_data,1)) = nan;',band_name{bnd},band_name{bnd}))
        end
        eval(sprintf('STATS.c%02d.GAIT.%s.Data = %s_data;',c,band_name_C{bnd},band_name{bnd}))
        %--- Friedman
        eval(sprintf('[STATS.c%02d.GAIT.%s.Friedman.p,STATS.c%02d.GAIT.%s.Friedman.tbl,STATS.c%02d.GAIT.%s.Friedman.stats]= friedman(%s_data);',c,band_name_C{bnd},c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd}))
        %--- Anova1 with outlier removed
        eval(sprintf('anova_%s_data = %s_data;',band_name{bnd},band_name{bnd}))
        eval(sprintf('anova_%s_data(isoutlier(anova_%s_data)) = nan;',band_name{bnd},band_name{bnd}))
        eval(sprintf('[STATS.c%02d.GAIT.%s.ANOVA.p,STATS.c%02d.GAIT.%s.ANOVA.tbl,STATS.c%02d.GAIT.%s.ANOVA.stats]= anova1(anova_%s_data);',c,band_name_C{bnd},c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd}))
        eval(sprintf('STATS.c%02d.GAIT.%s.ANOVA.multcompare = multcompare(STATS.c%02d.GAIT.%s.ANOVA.stats);',c,band_name_C{bnd},c,band_name_C{bnd}))
        %--- Pairwise signed rank test
        eval(sprintf('[STATS.c%02d.GAIT.%s.SignRank.p_1v2, STATS.c%02d.GAIT.%s.SignRank.h_1v2] = signrank(%s_data(:,1),%s_data(:,2));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
        try
            eval(sprintf('[STATS.c%02d.GAIT.%s.SignRank.p_1v3, STATS.c%02d.GAIT.%s.SignRank.h_1v3] = signrank(%s_data(:,1),%s_data(:,3));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
            eval(sprintf('[STATS.c%02d.GAIT.%s.SignRank.p_2v3, STATS.c%02d.GAIT.%s.SignRank.h_2v3] = signrank(%s_data(:,2),%s_data(:,3));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
        end
        try
            eval(sprintf('[STATS.c%02d.GAIT.%s.SignRank.p_1v4, STATS.c%02d.GAIT.%s.SignRank.h_1v4] = signrank(%s_data(:,1),%s_data(:,4));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
            eval(sprintf('[STATS.c%02d.GAIT.%s.SignRank.p_2v4, STATS.c%02d.GAIT.%s.SignRank.h_2v4] = signrank(%s_data(:,2),%s_data(:,4));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
            eval(sprintf('[STATS.c%02d.GAIT.%s.SignRank.p_3v4, STATS.c%02d.GAIT.%s.SignRank.h_3v4] = signrank(%s_data(:,3),%s_data(:,4));',c,band_name_C{bnd},c,band_name_C{bnd},band_name{bnd},band_name{bnd}))
        end
    end
    
    eval(sprintf('pvals = [STATS.c%02d.GAIT.%s.SignRank.p_1v2 STATS.c%02d.GAIT.%s.SignRank.p_1v3 STATS.c%02d.GAIT.%s.SignRank.p_2v3];',c,band_name_C{bnd},c,band_name_C{bnd},c,band_name_C{bnd}))
    % hb_pvals = bonf_holm(pvals); % Holm-Bonferroni (recommended)
    % hb_pvals(hb_pvals>1) = 1;
    % adj_pvals = hb_pvals;

    fdr_pvals = mafdr(pvals); % FDR, try out, not recommended
    fdr_pvals(fdr_pvals>1) = 1;
    adj_pvals = fdr_pvals;


    figure('Position',[300 300 1000 330])
    tiledlayout(1,4);
    for bnd = 1:4
        nexttile
        % eval(sprintf('subplot(1,4,%d); bar(mean(%s_data)); hold on; errorbar(1:3,mean(%s_data),std(%s_data),''k.'')',bnd,band_name{bnd},band_name{bnd},band_name{bnd}))
        % eval(sprintf('boxplot(%s_data); hold on;',band_name{bnd}))

        eval(sprintf('boxplot(%s_data,''Symbol'',''''); hold on;',band_name{bnd}))
        h = findobj(gca,'Tag','Box');
        for j=1:length(h)
            patch(get(h(j),'XData'),get(h(j),'YData'),eglb_color(length(h)+1-j,:),'FaceAlpha',.5);
        end
        set(gca,'XTickLabel',{'1.0','1.25','1.5'},'box','off','tickdir','out','linewidth',1.5,'fontsize',12); ylabel('Power (dB)'); xlabel('Gait speed (m/s)')
        title(band_name_C{bnd})
        ys = get(gca,'ylim');
        % if eval(sprintf('STATS.c%02d.GAIT.%s.SignRank.p_1v2 < (0.05/3)  && STATS.c%02d.GAIT.%s.Friedman.p<0.05',c,band_name_C{bnd},c,band_name_C{bnd}))
        %     hold on; line([1 2],[max(ys) max(ys)]*1.1,'linewidth',2,'color','k')
        %     set(gca,'ylim',[min(ys) max(ys)*1.4])
        % end
        % if eval(sprintf('STATS.c%02d.GAIT.%s.SignRank.p_1v3 < (0.05/3)  && STATS.c%02d.GAIT.%s.Friedman.p<0.05',c,band_name_C{bnd},c,band_name_C{bnd}))
        %     hold on; line([1 3],[max(ys) max(ys)]*1.25,'linewidth',2,'color','k')
        %     set(gca,'ylim',[min(ys) max(ys)*1.4])
        % end
        % if eval(sprintf('STATS.c%02d.GAIT.%s.SignRank.p_2v3 < (0.05/3)  && STATS.c%02d.GAIT.%s.Friedman.p<0.05',c,band_name_C{bnd},c,band_name_C{bnd}))
        %     hold on; line([2 3],[max(ys) max(ys)]*1.15,'linewidth',2,'color','k')
        %     set(gca,'ylim',[min(ys) max(ys)*1.4])
        % end

        if eval(sprintf('adj_pvals(1) < 0.05  && STATS.c%02d.GAIT.%s.Friedman.p<0.05',c,band_name_C{bnd}))
            hold on; line([1 2],[max(ys) max(ys)]*1.1,'linewidth',2,'color','k')
            set(gca,'ylim',[min(ys) max(ys)*1.4])
        end
        if eval(sprintf('adj_pvals(2) < 0.05  && STATS.c%02d.GAIT.%s.Friedman.p<0.05',c,band_name_C{bnd}))
            hold on; line([1 3],[max(ys) max(ys)]*1.25,'linewidth',2,'color','k')
            set(gca,'ylim',[min(ys) max(ys)*1.4])
        end
        if eval(sprintf('adj_pvals(3) < 0.05  && STATS.c%02d.GAIT.%s.Friedman.p<0.05',c,band_name_C{bnd}))
            hold on; line([2 3],[max(ys) max(ys)]*1.15,'linewidth',2,'color','k')
            set(gca,'ylim',[min(ys) max(ys)*1.4])
        end
    end
    % saveas(gcf,sprintf('cluster%02d_fooof_bandmean_speed_stats.png',c));
    if strcmp(exclude_outlier,'y')
        saveas(gcf,sprintf('cluster%02d_fooof_boxplot_speed_stats_NoOutlier.png',c));
    else
        saveas(gcf,sprintf('cluster%02d_fooof_boxplot_speed_stats.png',c));
    end
    close all
end
close all

%% ERSP
yticks = [    1.0986    1.6094    1.9459    2.1972    2.3979    2.5649    2.7081    2.8332    2.9957    3.1781 ...
    3.3322    3.4657    3.6376    3.7842    3.9318    4.1589    4.3175    4.5433    4.7005];
yticklabels = {'  3','  5','  7','  9',' 11',' 13',' 15',' 17',' 20',' 24',' 28',' 32',' 38',' 44',' 51',' 64',' 75',' 94','110'};
%-- frequency band applied
band_ytick = [3 4 8 13 30 100];
band_yticklabels = {'    3','δ    ','    4','θ    ','    8','α    ','   13','β    ','   30','γ    ','  100'};
band_ytick_log = log(band_ytick);
band_label_tick = diff(band_ytick_log)/2 + band_ytick_log(1:end-1);
band_ytick_all = unique([band_ytick_log,band_label_tick]);
STUDY = pop_statparams(STUDY, 'condstats','off','groupstats','off');
[STUDY, erspdata, ersptimes, erspfreqs, pgroup, pcond, pinter] = std_erspplot(STUDY,ALLEEG,'clusters',3, 'design', 1 );

% %======
% cond_txt = {'10','125','15'};
% group_txt = {'075','10','125','unobstructed'};
cond_txt = {'0.75x','1x','1.25x','unobstructed'};
group_txt = {'1 m/s','1.25 m/s','1.5 m/s'};
%=======

subjs = STUDY.subject;
%-- Process gait event timing
clearvars ersp_ge_pnt ersp_freq_pnt GE_t ERSP_GE_pnt 
for subj = 1:length(subjs)
    for cond = 1:length(cond_txt)
        for gp = 1:length(group_txt)
            % eval(sprintf(' EEG = pop_loadset(''filename'',''S01_TM_%s_PCA_CCA_AMICA_DIPFIT_epoch.set'',''filepath'',''D:\\ARL_data\\Processed\\STUDY_pcacca\\epoch\\''); ',cond_txt{cond}))
            EEG = eeg_retrieve(ALLEEG,find(strcmp({ALLEEG(:).subject},subjs{subj}) & strcmp({ALLEEG(:).condition},cond_txt(cond)) ...
                & strcmp({ALLEEG(:).group},group_txt(gp))));

            clearvars gait_event_t
            for i = 2:length(EEG.epoch)-1 % avoid first and last trial, may have missing events
                find_zero = find([EEG.epoch(i).eventlatency{:}]==0);
                try
                    gait_event_t(i-1,:) = [EEG.epoch(i).eventlatency{find_zero-1:find_zero+4}]; % only get RTO RHS(0) to next RHS
                catch
                    gait_event_t(i-1,:) = nan;
                end
            end
            avg_gait_event_t = round(mean(gait_event_t,'omitnan'));

            for i=1:length(avg_gait_event_t)
                [~,ersp_ge_pnt{cond,gp}(i)] = min(abs(ersptimes - avg_gait_event_t(i)));
            end
            %-- store variables
            GE_t{subj,cond,gp} = gait_event_t;
            ERSP_GE_pnt{subj} = ersp_ge_pnt;

            %-- process freq. ticks
            if subj==1
                tick_freqs = [4 8 13 30];
                for i=1:length(tick_freqs)
                    [~,ersp_freq_pnt(i)] = min(abs(erspfreqs - tick_freqs(i)));
                end
            end

        end
    end
end
%-- Progress figure
%{
for s = 1:18 % 20
    avg_ge_t(s,:) = round(mean(GE_t{s,3,3},1));
end
figure
plot(avg_ge_t,1:6,'linewidth',2)
xlabel('Time (ms)')
ylabel('Gait event')
title('Gait event timing for each subject')
set(gca,'ytick',1:6,'yticklabel',{'RTO','RHS','LTO','LHS','RTO','RHS'},'fontsize',16)
%}

%-- Compile gait event latencies for further processing
clearvars GE_stacked m_GE target_pnts_all
for s=1:length(subjs)
    for cond = 1:length(cond_txt)
        for gp = 1:length(group_txt)
            GE_stacked{cond,gp}(s,:) = ERSP_GE_pnt{s}{cond,gp}; 
        end
    end
end
m_GE = cellfun(@(x) round(mean(x,1)),GE_stacked,'UniformOutput',false);
n = 1;
for cond = 1:length(cond_txt)
    for gp = 1:length(group_txt)
        target_pnts_all(n,:) = [1 round(mean(GE_stacked{cond,gp},1)) 200];
        n = n+1;
    end
end
target_pnts = round(mean(target_pnts_all));

%-- Timewarping ERSPs & figure creation
for c = tar_clus  % [3 4 5 9 12 17] % 
    % c = 16; % [3 4 7 9 10 11 15 16]
    [STUDY, erspdata, ersptimes, erspfreqs, pgroup, pcond, pinter] = std_erspplot(STUDY,ALLEEG,'clusters',c, 'design', 1 );
    close
    clearvars WARPED_ersp_temp WARPED_ersp temp_ersp
    for cond = 1:length(cond_txt)
        for gp = 1:length(group_txt)
            clus_subj_list = STUDY.cluster(c).sets(1,:)/size(STUDY.cluster(c).sets,1);
            clearvars data_pnts_collect
            for s = unique(clus_subj_list)
                data_pnts_collect(s,:) = [1 GE_stacked{cond,gp}(s,:) 200];
            end

            % target_pnts = [1 round(mean(GE_stacked{cond,gp},1)) 200];
            % data_pnts = [1 GE_stacked{1}(1,:) 200];
            for i=1:size(erspdata{cond,gp},3)
                data = reshape(erspdata{cond,gp}(:,:,i),100,200)'; % transverse before running timewarp
                warpmat = timewarp(data_pnts_collect(clus_subj_list(i),:), target_pnts);
                warped_data = warpmat*data;
                warped_data = warped_data'; % transverse back to the same size
                WARPED_ersp_temp{i} = warped_data;
            end
            n = 1;
            for s = unique(clus_subj_list)
                idx_in_clus = find(clus_subj_list==s);

                % fixed 05/22/2025
                clearvars temp_ersp
                %--

                for t = 1:length(idx_in_clus)
                    temp_ersp(:,:,t) = WARPED_ersp_temp{idx_in_clus(t)};
                end
                WARPED_ersp{cond,gp}(:,:,n) = reshape(mean(temp_ersp,3),100,200);
                n = n+1;
            end
        end
    end
    ALL_warped_ersp{c} = WARPED_ersp;

    WARPED_ersp = WARPED_ersp'; % for RV15.study
    %======================= Significance (developing 03/13/2025)
    % [pcond,pgroup,pinter] = std_stat(WARPED_ersp,'groupstats','on','condstats','on','paired',{'on','on','on'});
    % [pcond,pgroup,pinter] = std_stat(WARPED_ersp,'method','permutation','naccu',2000,'groupstats','on','condstats','on','paired',{'on','on','on'});
    

    [m,n] = size(WARPED_ersp);
    %-- calculates CI for ERSP
    if strcmp(sig_mask,'y')
        for i=1:m
            for j=1:n
                ERSPs = WARPED_ersp{i,j};
                input = mean(ERSPs,3); % average across subjects
                CI_boot{i,j} = bootstat(input,'arg1','boottype','shuffle','bootside','both','naccu',500,'alpha',0.05,'dimaccu',2);
                %     sig_decrease = input < CI_boot{i}(:,1);
                %     sig_increase = input > CI_boot{i}(:,2);
                sig = input < CI_boot{i,j}(:,1) | input > CI_boot{i,j}(:,2);
                %     de_ersp = input.*sig_decrease;
                %     in_ersp = input.*sig_increase;
                sig_ersp = input.*sig;
                SIG{i,j} = sig;
                SIG_ERSP{i,j} = sig_ersp; 
                
            end
        end
    end
    
    %{
    % [pcond,pgroup,pinter] = std_stat(WARPED_ersp,'groupstats','on','condstats','on','paired',{'on','on','on'});
    ERSP_to_compare = WARPED_ersp;
    %-- Comparing ERSPs and figure creation
    % [pcond,pgroup,pinter] = std_stat(ERSP_to_compare,'groupstats','on','condstats','on','paired',{'on','on','on'});
    alpha = 0.01;  % 0.05, 0.01, 0.001
    
    %-- gait speed >>> main effect
    cond_compare = {'1.0m/s','1.25m/s','1.5m/s'};
    tickrotation = 45;
    for ob_cond = 1:4
        clims = [];
        figure('position',[100 100 600 600]); subplot(421);imagesc(flip(mean(ERSP_to_compare{1,ob_cond},3))); % VRwalking_ersp_figsetting(group_id); %title('')
        subplot(423);imagesc(flip(mean(ERSP_to_compare{2,ob_cond},3))); % VRwalking_ersp_figsetting(group_id); %title('')
        subplot(425);imagesc(flip(mean(ERSP_to_compare{3,ob_cond},3))); % VRwalking_ersp_figsetting(group_id); title('')
        subplot(427); imagesc(flip(pcond{ob_cond})<alpha); % VRwalking_ersp_figsetting(group_id); set(gca,'Clim',[-1 1])
        % Set color limits to the same
        subplot(421); clims(1,:) = get(gca,'clim'); colorbar
        subplot(423); clims(2,:) = get(gca,'clim'); colorbar
        subplot(425); clims(3,:) = get(gca,'clim'); colorbar
        new_clim = round([min(clims(:)) max(clims(:))],2);
        subplot(421); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        title(cond_compare{1})
        subplot(423); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        title(cond_compare{2})
        subplot(425); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        title(cond_compare{3})
        subplot(427); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',[-1 1],'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        title(['Significance Map, p=',num2str(alpha)]); colorbar; xlabel('Gait Event'); ylabel('Frequency (Hz)')
        colormap jet
        % Apply significance mask
        clims = [];
        subplot(422);imagesc(flip(mean(ERSP_to_compare{1,ob_cond},3).*(pcond{ob_cond}<alpha))); %VRwalking_ersp_figsetting(group_id); %title(sprintf('Clus%d %0.2fm/s %0.2fx',c,group_info(group_id),0.75))
        title([cond_compare{1},'\_sig.'])
        subplot(424);imagesc(flip(mean(ERSP_to_compare{2,ob_cond},3).*(pcond{ob_cond}<alpha))); %VRwalking_ersp_figsetting(group_id); %title(sprintf('Clus%d %0.2fm/s %0.2fx',c,group_info(group_id),1))
        title([cond_compare{2},'\_sig.'])
        subplot(426);imagesc(flip(mean(ERSP_to_compare{3,ob_cond},3).*(pcond{ob_cond}<alpha))); %VRwalking_ersp_figsetting(group_id); %title(sprintf('Clus%d %0.2fm/s %0.2fx',c,group_info(group_id),1.25))
        title([cond_compare{3},'\_sig.'])
        % Set color limits to the same
        subplot(422); clims(1,:) = get(gca,'clim'); colorbar
        subplot(424); clims(2,:) = get(gca,'clim'); colorbar
        subplot(426); clims(3,:) = get(gca,'clim'); colorbar
        colormap jet
        new_clim = round([-max(abs(clims(:))) max(abs(clims(:)))],2);
        subplot(422); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        subplot(424); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        subplot(426); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        saveas(gcf,sprintf('cluster%02d_ERSP_comp_obstacleCond%d.png',c,ob_cond));
    end

    %-- obstacle speed >>> main effect
    cond_compare = {'0.75x','1.0x','1.25x','unobstructed'};
    tickrotation = 45;
    for gait_group=1:3
        clims = [];
        figure('position',[100 100 600 600]); subplot(521);imagesc(flip(mean(ERSP_to_compare{gait_group,1},3))); % VRwalking_ersp_figsetting(group_id); %title('')
        subplot(523);imagesc(flip(mean(ERSP_to_compare{gait_group,2},3))); % VRwalking_ersp_figsetting(group_id); %title('')
        subplot(525);imagesc(flip(mean(ERSP_to_compare{gait_group,3},3))); % VRwalking_ersp_figsetting(group_id); title('')
        subplot(527);imagesc(flip(mean(ERSP_to_compare{gait_group,4},3))); % VRwalking_ersp_figsetting(group_id); title('')
        subplot(529); imagesc(flip(pgroup{gait_group})<alpha); % VRwalking_ersp_figsetting(group_id); set(gca,'Clim',[-1 1])
        % Set color limits to the same
        subplot(521); clims(1,:) = get(gca,'clim'); colorbar
        subplot(523); clims(2,:) = get(gca,'clim'); colorbar
        subplot(525); clims(3,:) = get(gca,'clim'); colorbar
        subplot(527); clims(4,:) = get(gca,'clim'); colorbar
        new_clim = round([min(clims(:)) max(clims(:))],2);
        subplot(521); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        title(cond_compare{1})
        subplot(523); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        title(cond_compare{2})
        subplot(525); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        title(cond_compare{3})
        subplot(527); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        title(cond_compare{4})
        subplot(529); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',[-1 1],'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        title(['Significance Map, p=',num2str(alpha)]); colorbar; xlabel('Gait Event'); ylabel('Frequency (Hz)')
        colormap jet
        % Apply significance mask
        clims = [];
        subplot(522);imagesc(flip(mean(ERSP_to_compare{gait_group,1},3).*(pgroup{gait_group}<alpha))); %VRwalking_ersp_figsetting(group_id); %title(sprintf('Clus%d %0.2fm/s %0.2fx',c,group_info(group_id),0.75))
        title([cond_compare{1},'\_sig.'])
        subplot(524);imagesc(flip(mean(ERSP_to_compare{gait_group,2},3).*(pgroup{gait_group}<alpha))); %VRwalking_ersp_figsetting(group_id); %title(sprintf('Clus%d %0.2fm/s %0.2fx',c,group_info(group_id),1))
        title([cond_compare{2},'\_sig.'])
        subplot(526);imagesc(flip(mean(ERSP_to_compare{gait_group,3},3).*(pgroup{gait_group}<alpha))); %VRwalking_ersp_figsetting(group_id); %title(sprintf('Clus%d %0.2fm/s %0.2fx',c,group_info(group_id),1.25))
        title([cond_compare{3},'\_sig.'])
        subplot(528);imagesc(flip(mean(ERSP_to_compare{gait_group,4},3).*(pgroup{gait_group}<alpha))); %VRwalking_ersp_figsetting(group_id); %title(sprintf('Clus%d %0.2fm/s %0.2fx',c,group_info(group_id),1.25))
        title([cond_compare{4},'\_sig.'])
        % Set color limits to the same
        subplot(522); clims(1,:) = get(gca,'clim'); colorbar
        subplot(524); clims(2,:) = get(gca,'clim'); colorbar
        subplot(526); clims(3,:) = get(gca,'clim'); colorbar
        subplot(528); clims(4,:) = get(gca,'clim'); colorbar
        colormap jet
        new_clim = round([-max(abs(clims(:))) max(abs(clims(:)))],2);
        subplot(522); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        subplot(524); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        subplot(526); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        subplot(528); set(gca,'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'clim',new_clim,'xtick',target_pnts(3:7),'xticklabel',{'RHS','LTO','LHS','RTO','RHS'},'xticklabelrotation',tickrotation); xlim([target_pnts(3)-10 target_pnts(end-1)+10])
        saveas(gcf,sprintf('cluster%02d_ERSP_comp_gaitspeed%d.png',c,gait_group));
    end
    %}
    %=======================

    %-- ERSP result figure, with timewarpping applied to each subject, averaged
    %-- ICs from the same subject within cluster.
    % WARPED_ersp = WARPED_ersp';
    figure('Position',[500 50 950 560])
    iter = 1;
    % for i = 1:length(cond_txt) 
    %     for j = 1:length(group_txt)
    for j = 1:length(group_txt)    % for RV15.study
        for i = 1:length(cond_txt)
            subplot(3,4,iter)
            % imagesc(flip(reshape(mean(WARPED_ersp{i,j},3),100,200),1))
            imagesc(flip(reshape(SIG_ERSP{j,i},100,200),1))
            % imagesc(flip(SIG_ERSP{i,j},1))
            clims(iter,:) = get(gca,'clim');
            colormap jet
            set(gca,'xtick',target_pnts(3:7),'XTickLabel',{'RHS','LTO','LHS','RTO','RHS'},'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'XTickLabelRotation',40)
            xlim([target_pnts(3) target_pnts(end-1)])
                       
            title([group_txt{j},'_',cond_txt{i}],'interpreter','none') % for RV15.study
            ylabel('Frequency (Hz)')
            xlabel('Gait event')
            iter = iter+1;
        end
    end
    iter = 1;
    for i = 1:length(cond_txt)
        for j = 1:length(group_txt)
            subplot(3,4,iter)
            set(gca,'clim',[min(clims(:)) max(clims(:))],'ticklength',[.03;.03])
            iter = iter+1;
        end
    end
    saveas(gcf,sprintf('cluster%02d_ERSP_gaitcycle_sig.png',c));
    saveas(gcf,sprintf('cluster%02d_ERSP_gaitcycle_sig.fig',c));

    
    figure('Position',[500 50 950 560])
    iter = 1;
    % for i = 1:length(cond_txt) 
    %     for j = 1:length(group_txt)
    for j = 1:length(group_txt)    % for RV15.study
        for i = 1:length(cond_txt)
            subplot(3,4,iter)
            imagesc(flip(reshape(mean(WARPED_ersp{j,i},3),100,200),1))
            % imagesc(flip(reshape(SIG_ERSP{j,i},100,200),1))
            % imagesc(flip(SIG_ERSP{i,j},1))
            clims(iter,:) = get(gca,'clim');
            colormap jet
            set(gca,'xtick',target_pnts(3:7),'XTickLabel',{'RHS','LTO','LHS','RTO','RHS'},'ytick',flip(length(erspfreqs)-ersp_freq_pnt),'yticklabel',flip(tick_freqs),'XTickLabelRotation',40)
            xlim([target_pnts(3) target_pnts(end-1)])
            title([group_txt{j},'_',cond_txt{i}],'interpreter','none') % for RV15.study
            ylabel('Frequency (Hz)')
            xlabel('Gait event')
            iter = iter+1;
        end
    end
    iter = 1;
    for i = 1:length(cond_txt)
        for j = 1:length(group_txt)
            subplot(3,4,iter)
            set(gca,'clim',[min(clims(:)) max(clims(:))],'ticklength',[.03;.03])
            iter = iter+1;
        end
    end
    saveas(gcf,sprintf('cluster%02d_ERSP_gaitcycle.png',c));
    saveas(gcf,sprintf('cluster%02d_ERSP_gaitcycle.fig',c));

    close all
end
close all
%^^^ Added timewarp function ( 03/09/2025) ^^^

%% Save as a PPT

%% Create PowerPoint file
import mlreportgen.ppt.*
ppt = Presentation(ppt_name);
%--
titleSlide = add(ppt,'Title Slide');
replace(titleSlide,'Title','PipelineV11 result figs');

%--
for c = tar_clus
    pictureSlide = add(ppt,'Title Only');
    plot1 = Picture(sprintf('cluster%02d_dipole_cor.png',c));
    plot1.X = '15cm';
    plot1.Y = '1cm';
    plot1.Width = '4cm';
    plot1.Height = '4cm';
    plot2 = Picture(sprintf('cluster%02d_dipole_hor.png',c));
    plot2.X = '19cm';
    plot2.Y = '1cm';
    plot2.Width = '4cm';
    plot2.Height = '4cm';
    plot3 = Picture(sprintf('cluster%02d_dipole_sag.png',c));
    plot3.X = '23cm';
    plot3.Y = '1cm';
    plot3.Width = '4cm';
    plot3.Height = '4cm';
%     plot3 = Picture(sprintf('cluster%02d_PSD_speed.png',c));
%     plot3.X = '27.15cm';
%     plot3.Y = '5.36cm';
%     plot3.Width = '6.5cm';
%     plot3.Height = '6.5cm';
%     plot4 = Picture(sprintf('cluster%02d_PSD_scene.png',c));
%     plot4.X = '27.15cm';
%     plot4.Y = '11.25cm';
%     plot4.Width = '6.5cm';
%     plot4.Height = '6.5cm';
    plot5 = Picture(sprintf('cluster%02d_ERSP_gaitcycle.png',c));
    plot5.X = '12.66cm';
    plot5.Y = '5.5cm';
    plot5.Width = '21.21cm';
    plot5.Height = '12.09cm';
    try
        plot6 = Picture(sprintf('cluster%02d_fooof_PSD_speed.png',c));
        plot6.X = '0cm';
        plot6.Y = '3.5cm';
        plot6.Width = '4cm';
        plot6.Height = '4cm';
        % plot7 = Picture(sprintf('cluster%02d_fooof_bandmean_speed.png',c));
        plot7 = Picture(sprintf('cluster%02d_fooof_boxplot_speed_stats.png',c));
        plot7.X = '0cm';
        plot7.Y = '7cm';
        plot7.Width = '15cm';
        plot7.Height = '4cm';
        plot8 = Picture(sprintf('cluster%02d_fooof_PSD_obstacle.png',c));
        plot8.X = '0cm';
        plot8.Y = '11.5cm';
        plot8.Width = '4cm';
        plot8.Height = '4cm';
        % plot9 = Picture(sprintf('cluster%02d_fooof_bandmean_obstacle.png',c));
        plot9 = Picture(sprintf('cluster%02d_fooof_boxplot_obstacle_stats.png',c));
        plot9.X = '0cm';
        plot9.Y = '15cm';
        plot9.Width = '15cm';
        plot9.Height = '4cm';
    catch
    end
    
    cluster_title{c} = ['Cls ',num2str(c),' (',num2str(length(unique(sub_id_list{c}))),' Ss & ICs)'];
    replace(pictureSlide,'Title',cluster_title{c});
    add(pictureSlide,plot1);
    add(pictureSlide,plot2);
    add(pictureSlide,plot3);
%     add(pictureSlide,plot4);
    add(pictureSlide,plot5);
    try        
        add(pictureSlide,plot6);
        add(pictureSlide,plot7); 
        add(pictureSlide,plot8);
        add(pictureSlide,plot9);
    catch
        continue
    end
end
%% Save and review the PPT
close(ppt);
% rptview(ppt);


save('PPT_w_fooofPSD_v4_final','-v7.3')


