function [EEG_out] = sliding_CCA(EEG_in,plot_figs)
if nargin < 2
    plot_figs = 'off';
end
%%% CCA (3s sliding window, 50% overlap)
set_L = size(EEG_in.data,2);
wind_L = 3*EEG_in.srate; % 3 second sliding window
wind_shift = 1.5*EEG_in.srate; % 1.5 second sliding step
epoch_n = floor((set_L-wind_L)/wind_shift)+1;

merged_EEG_clean = [];
for e = 1:epoch_n
    %-- Define sliding window
    if e==epoch_n
        EEG_sec = EEG_in.data(:,wind_shift*(e-1)+1:end);
        cur_wind_L = size(EEG_sec,2);
    else
        EEG_sec = EEG_in.data(:,wind_shift*(e-1)+1:wind_shift*(e-1)+wind_L);
        cur_wind_L = wind_L;
    end
    %%% Canical correaltaion calculation
    EEG_raw = EEG_sec(:,1:end-1)';
    EEG_delay = EEG_sec(:,2:end)';
    [A_EEG,B_EEG,r_EEG] = canoncorr(EEG_raw,EEG_delay);
    EEG_source = (EEG_raw - repmat(mean(EEG_raw),cur_wind_L-1,1))*A_EEG;
    EEG_source_clean = EEG_source;
    autocor_plotknee = knee_pt(r_EEG);
    low_autocor = autocor_plotknee:length(r_EEG);
    
    %%% skewness & kurtosis of power spectrum
    data_temp = EEG_source;
    L = length(data_temp);
    n = 2048;
    Y = fft(data_temp,n,1);
    P2 = abs(Y/L);
    P1 = P2(1:n/2+1,:);
    %-- Compute skewness and kurtosis
    skew = skewness(P1,1,1);
    kurt = kurtosis(P1,1,1);
    %-- finding bad channels
    neg_skew = find(skew<0);
    outlier_skew = find(abs(skew-median(skew))>2*std(skew)); % > 2SD from median
    outlier_kurt = find(abs(kurt-median(kurt))>2*std(kurt)); % > 2SD from median
    
    rm_list = unique([neg_skew,low_autocor,outlier_skew,outlier_kurt]);
    
    %-- Remove (filter) bad components
    RemoveCCs = rm_list;
    
    %     EEG_source_clean(:,RemoveCCs) = 0;
    %     EEG_clean = EEG_source_clean/A_EEG + repmat(mean(EEG_in),cur_wind_L-1,1);
    
    %-- FFT frequency domain cancellation
    sub_Y = fft(EEG_source_clean(:,RemoveCCs));
    r_coef = real(sub_Y);
    i_coef = imag(sub_Y);
    r_coef(r_coef>6*median(r_coef)) = 0; % 0, median(r_coef(:))
    i_coef(i_coef>6*median(i_coef)) = 0; % 0, median(i_coef(:))
    r_coef(r_coef<2*median(r_coef)) = 0; % 0, median(r_coef(:))
    i_coef(i_coef<2*median(i_coef)) = 0; % 0, median(i_coef(:))
    X = ifft(complex(r_coef,i_coef),'symmetric');
    
    EEG_source_clean(:,RemoveCCs) = X;
    EEG_clean = EEG_source_clean/A_EEG + repmat(mean(EEG_raw),cur_wind_L-1,1);
    
    
    %-- Put sliding window back together
    if e==1
        merged_EEG_clean = EEG_clean;
    else
        merged_EEG_clean(end-wind_shift+1:end,:) = (merged_EEG_clean(end-wind_shift+1:end,:)+EEG_clean(1:wind_shift,:))/2;
        merged_EEG_clean = [merged_EEG_clean; EEG_clean(wind_shift:end,:)];
    end
end
EEG_out = EEG_in;
EEG_out.data = merged_EEG_clean';
EEG_out = eeg_checkset(EEG_out);

% High pass filter (0.5 Hz)
EEG_out = pop_eegfiltnew(EEG_out, 0.5, []);

if strcmp(plot_figs,'on')
    %-- Verification figures
    figure
    plot(r_EEG)
    xlabel('component #')
    ylabel('autocorrelation')
    title('r\_EEG')
    hold on
    plot(knee_pt(r_EEG),r_EEG(knee_pt(r_EEG)),'ro')
    hold off
    
    figure
    subplot(221); plot(EEG_source)
    xlabel('data point')
    ylabel('amplitude')
    title('All components')
    subplot(222); plot(EEG_source(:,low_autocor))
    xlabel('data point')
    ylabel('amplitude')
    title('Low autocorrelation')
    subplot(223); plot(EEG_source(:,outlier_skew))
    xlabel('data point')
    ylabel('amplitude')
    title('Skewness outliers')
    subplot(224); plot(EEG_source(:,outlier_kurt))
    xlabel('data point')
    ylabel('amplitude')
    title('Kurtosis outliers')
    
    figure('position',[20 20 960 850])
    for i=1:length(r_EEG)
        subplot(8,8,i); plot(EEG_source(:,i))
        if ismember(i,rm_list)
            title('Bad','color','r')
        else
            title(['Component ',num2str(i)])
        end
    end
    
    figure('position',[20 20 960 850])
    for i=1:length(r_EEG)
        subplot(8,8,i); plot(P1(i,:))
        if ismember(i,rm_list)
            title('PSD - Bad','color','r')
        else
            title(['PSD - Component ',num2str(i)])
        end
    end
    
    figure('position',[20 20 960 850])
    for i=1:length(r_EEG)
        subplot(8,8,i); plot(EEG_source_clean(:,i))
        if ismember(i,rm_list)
            title('Cleaned','color','r')
        else
            title(['Component ',num2str(i)])
        end
    end
    
    figure
    subplot(211)
    plot(EEG_in.times/1000,EEG_in.data')
    title('Signal in')
    ylabel('Amplitude (mV)')
    xlabel('Time (s)')
    subplot(212)
    plot(EEG_out.times/1000,EEG_out.data')
    title('Signal out - CCA')
    ylabel('Amplitude (mV)')
    xlabel('Time (s)')
end
end