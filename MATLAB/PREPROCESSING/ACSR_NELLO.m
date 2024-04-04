clear all;
clc;
close all;

% selectedChannels = {1};
% sf = 1000;
% interpulse_duration = 100; % us - ms --- for Double pulse. 
% current = 65;
% numberOfValues = 5000;
% % EMG preprocessing
% plot_chs = true;
% bool_plot_PSD = false;
% selected_filters = 3;
% paper_nb = 1;

% 
% emg_1 = load ('C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\22march\emg_current20_repetition1_5.0swindow_100interpulse.mat');
% emg_1 = emg_1.emg_data;
% 
% emg_2 = load ('C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\22march\emg_current20_repetition2_5.0swindow_100interpulse.mat');
% emg_2 = emg_2.emg_data;
% 
% emg_3 = load ('C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\22march\emg_current20_repetition3_5.0swindow_100interpulse.mat');
% emg_3 = emg_3.emg_data;
% 
% emg_data = [double(emg_1), double(emg_2),double(emg_3) ];
% 
% [norm_factor_afterfilter, EMG_preprocessed] = EMG_preprocessing((double(emg_data))', sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
% 
% emg_data = EMG_preprocessed;


emg_data = load('C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\DOME\30Hz\L1-L2\full_emg_TA_R_15-20.mat');

emg_data = emg_data.emg_data;
emg_for_training=emg_data(1,1:10000);
ACSR_window=200;

emg_filtered=ACSR_filter(emg_for_training,emg_data,ACSR_window);
time=[1:1:length(emg_data)];
subplot(2,1,1);
    plot(time,emg_data,'b');hold on;
    xlabel('Time [s]');ylabel('Amplitude [mV]');
    title('Raw','fontsize',12,'fontweight','bold');
subplot(2,1,2);
    plot(time,emg_filtered,'r');
    xlabel('Time [s]');ylabel('Amplitude [mV]');
    title('Filtered','fontsize',12,'fontweight','bold');

% %%
% interpulse_duration = 50; % us - ms --- for Double pulse. 
% 
% bool_plot_MEP = true;
% bool_colour_response = true;
% updated_t_0 = 11200;
% muscleLocations = {'distal'};
% 
% response = ActionPotDetectDoublePulse3(updated_t_0,muscleLocations{1},emg_filtered',sf, interpulse_duration,1,bool_plot_MEP,bool_colour_response,numberOfValues); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'
% disp(response)
