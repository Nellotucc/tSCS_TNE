function [normalization_factor, EMG_preprocessed] = EMG_preprocessing(data, fs, verbose2, show_Welch, plot_chs, channels, plot_PSD, paper_nb)
%returns preprocessed data (filtering, rectification, lowpass)

% verbose : 1 to plot the preprocessed data
% verbose2 : select filter type
% normalization_factor is lp_normalization_factor

%check that the data is in the form samplesXchannels
[x, y] = size(data);
if y>10 %we don't have more than 8 channels and there will never be less than 10 samples in a valid recording
    data= data'; %take the transposed version (using ' operator)
end



% remove median
data = data - median(data);


n = 2;  %filter order
% fc_low = 50;
% fc_low = 120:5:180;
% fc_high = 490;
if paper_nb == 1
    fc_low = 43;
    fc_high = 47;
    ftype = 'stop';
end
if paper_nb == 2
fc_low = 20;
fc_high = 499;
ftype = 'bandpass';
end
nb_channels = width(data);
numberOfValues = length(data);

%Zero-Pole-Gain design
% zero-phase IIR Butterworth bandpass filter using second-order sections.
% We can use a zero phase filter as we have offline data
% It allows to have 0 delay in the filtered signal.
bandpass = zeros(length(data),width(data));
bandpass_for_all_fcl = [];
for i = 1:nb_channels
    for j = 1:length(fc_low)
        Wn = [fc_low(j) fc_high]/(fs/2);
        %[z,p,k] = butter(n,Wn,ftype);
        [b,a] = butter(n,Wn,ftype);
        %sos = zp2sos(z,p,k);
        %bandpass_for_all_fcl(:,j) = sosfilt(sos,data(:,i));
        bandpass_for_all_fcl(:,j) = filtfilt(b,a,data(:,i));
    end
    %[~,idx] = max(max(bandpass_for_all_fcl) - max(std(bandpass_for_all_fcl(500:1500,:))));              % 1-1000 DEPENDS ON DATA, SHOULD BE ONLY NOISY THERE
    [~,idx] = max(max(bandpass_for_all_fcl) - max(std(bandpass_for_all_fcl(numberOfValues-500:numberOfValues,:))));              % Only gets the last 500 samples which should be noise only

    bandpass(:,i) = bandpass_for_all_fcl(:,idx);
end

%rectifying data
rec_bef_norm = detrend(bandpass);
normalization_factor = max(max(abs(rec_bef_norm)))/10; 
rec = rec_bef_norm/normalization_factor;
%peak envolope

%env = envelope(rec,2,'peak'); %Length of Hilbert filter, increase to obtain smoother
order_lowpass = 1;
cutoff_low = 300;
[b_lowpass, a_lowpass] = butter(order_lowpass, cutoff_low/(fs/2), 'low');
lp = filtfilt(b_lowpass, a_lowpass, rec_bef_norm);
% lp = lowpass(rec,300,fs);
normalization_factor = max(max(abs(lp)))/10; 
lp = lp/normalization_factor;

%SMOOTHING
% window_size = 1000;  % Adjust window size as needed
% smoothed_emg = zeros(numberOfValues,nb_channels);
% for i=1:nb_channels
%     smoothed_emg(:,i) = movmean(lp(:,i), window_size);
% end
% 
% figure;
% tiledlayout(1,1)
% ax = nexttile;
% plot(smoothed_emg(:,1))
% ax.XAxis.Exponent = 3;
% title('smoothed')
% 

[Pxx_all,F] = periodogram(data,[],length(data),fs);
[Pxx_filt,F] = periodogram(rec,[],length(rec),fs);
[Pxx_low,F] = periodogram(lp,[],length(lp),fs);
if show_Welch
    length_window = 20;
    nfft = (height(data)-length_window/2)/(length_window/2);
    [X_100, f_Welch] = pwelch(data, hamming(length_window), 0, nfft, fs);
end

if plot_PSD
    figure;
    tiledlayout(3+show_Welch,1)
    nexttile
    plot(F,10*log10(Pxx_all))
    title("PSD of raw signal")
    if show_Welch
        nexttile
        plot(f_Welch,10*log10(X_100))
        title("Welch of raw signal")
    end
    nexttile
    plot(F,10*log10(Pxx_filt))
    title("PSD after bandpass")
    nexttile
    plot(F,10*log10(Pxx_low))
    title("PSD after bandpass and lowpass")
end



if plot_chs
    for i = plot_chs
        figure;
        tiledlayout(4,1)
    
        ax = nexttile;
        plot(data(:,i))
        ax.XAxis.Exponent = 3;
        title(['Unfiltered - channel ', char(channels{i})])
    
        ax = nexttile;
        plot(bandpass(:,i))
        ax.XAxis.Exponent = 3;
        title('After bandpass')
    
        ax = nexttile;
        plot(rec(:,i))
        ax.XAxis.Exponent = 3;
        title('After rectification')
         
    
        ax = nexttile;
        %plot(env(:,i))
        plot(lp(:,i))
        ax.XAxis.Exponent = 3;
        title('After lowpass')
    end
end



% plot filtered signals of all channels
% figure; 
% tiledlayout(nb_channels,1)
% for i = 1:nb_channels
%     ax = nexttile;
%     plot(rec(:,i))
%     ax.XAxis.Exponent = 3;
%     title(['Filtered channel ', char(channels{i})]);
% end


switch verbose2
    case 0
        EMG_preprocessed = data;
        if (paper_nb == 2), disp('unfiltered selected'); end
    case 1
        EMG_preprocessed = bandpass;
        if (paper_nb == 2), disp('bandpass selected'); end
    case 2
        EMG_preprocessed = rec;
        if (paper_nb == 2), disp('bandpass + rectified selected'); end
    case 3
        EMG_preprocessed = lp;
        if (paper_nb == 2), disp('bandpass + rectified + lowpass selected'); end
    otherwise
        EMG_preprocessed = 0;
        if (paper_nb == 2), disp('ERROR, nothing returned'); end
end



end