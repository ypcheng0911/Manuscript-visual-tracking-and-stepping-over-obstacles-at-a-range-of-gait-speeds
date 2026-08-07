function EEG_out = sliding_PCA(EEG_in,plot_figs)
if nargin < 2
    plot_figs = 'off';
end
%%% PCA
set_L = size(EEG_in.data,2);
wind_L = 0.5*EEG_in.srate; % 0.5 second sliding window
wind_shift = 0.25*EEG_in.srate; % 0.25 second sliding step
epoch_n = floor((set_L-wind_L)/wind_shift)+1;
data = EEG_in.data;
data = double(data);
[m, n] = size(data);
if n > m
    dim_change = 1;
else
    dim_change = 0;
end

merged_EEG_PC = [];
for e = 1:epoch_n
    %-- Define sliding window
    if e==epoch_n
        EEG_sec = data(:,wind_shift*(e-1)+1:end);
        cur_wind_L = size(EEG_sec,2);
    else
        EEG_sec = data(:,wind_shift*(e-1)+1:wind_shift*(e-1)+wind_L);
        cur_wind_L = wind_L;
    end
    %-- Perform PCA
    if dim_change==1
        EEG_sec = EEG_sec';
    end
    [coeff,score,~,~,~,mu] = pca(EEG_sec);
    new_score = [];
    %-- Alter outliner PC score
    for i=1:size(score,2)
        subset = score(:,i);
        subset(isoutlier(subset)) = median(subset);
        new_score(:,i)=subset;
    end
    reconstructed = new_score * coeff' + repmat(mu,size(EEG_sec,1),1);
%     reconstructed = reconstructed';
    
%     sub_Y = fft(reconstructed);
%     r_coef = real(sub_Y);
%     i_coef = imag(sub_Y);
%     r_coef(r_coef>2*median(r_coef)) = 0;
%     i_coef(i_coef>2*median(i_coef)) = 0;
%     Inv_reconstructed = ifft(complex(r_coef,i_coef),'symmetric');
    
    %-- Put sliding window back together (average)
    if e==1
        merged_EEG_PC = reconstructed;
    else
        merged_EEG_PC(end-wind_shift+1:end,:) = (merged_EEG_PC(end-wind_shift+1:end,:)+reconstructed(1:wind_shift,:))/2;
        merged_EEG_PC = [merged_EEG_PC; reconstructed(wind_shift+1:end,:)];
    end
    
%     if e==1
%         merged_EEG_PC = Inv_reconstructed;
%     else
%         merged_EEG_PC(end-wind_shift+1:end,:) = (merged_EEG_PC(end-wind_shift+1:end,:)+Inv_reconstructed(1:wind_shift,:))/2;
%         merged_EEG_PC = [merged_EEG_PC; Inv_reconstructed(wind_shift+1:end,:)];
%     end

end
EEG_out = EEG_in;
EEG_out.data = merged_EEG_PC';
EEG_out = eeg_checkset(EEG_out);

% High pass filter (0.5 Hz)
EEG_out = pop_eegfiltnew(EEG_out, 0.5, []);

if strcmp(plot_figs,'on')
    figure
    subplot(211)
    plot(EEG_in.times/1000,EEG_in.data')
    title('Signal in')
    ylabel('Amplitude (mV)')
    xlabel('Time (s)')
    subplot(212)
    plot(EEG_out.times/1000,EEG_out.data')
    title('Signal out')
    ylabel('Amplitude (mV)')
    xlabel('Time (s)')
end
end