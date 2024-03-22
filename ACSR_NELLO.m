clear all;
clc;
close all;

load 'Riccardo''s DATA'\15march\emg_current20_repetition2_5.0swindow_100interpulse.mat;
emg_for_training=emg_data(1:(length(emg_data)/3));
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