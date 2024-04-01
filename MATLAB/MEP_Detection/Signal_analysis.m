function [response,p2p_amplitude] = Signal_analysis(t_0,emg_data,fs, verbose2, show_Welch, plot_chs, channels, plot_PSD, paper_nb,interpulse_duration,bool_plot_MEP,window_size)
%SIGNAL_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here

[norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing(double(emg_data), fs, verbose2, show_Welch, plot_chs, channels, plot_PSD, paper_nb); %preprocess

[response,top_location] = ActionPotDetectDoublePulse3(t_0,EMG_preprocessed, interpulse_duration/1000,norm_factor_afterfilter,bool_plot_MEP,window_size); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'

if strcmp(response, 'reflex response')    
    p2p_amplitude = peak2peak(emg_data(top_location-20:top_location+15));
else
    p2p_amplitude = 0;
end

