clear all;
clc;
close all;
load example;

emg_for_training=emg(1:2*Fs);
ACSR_window=0.2 * Fs; % 200 ms

emg_filtered=ACSR_filter(emg_for_training,emg,ACSR_window);

subplot(2,1,1);
    plot(time,emg,'b');hold on;
    xlabel('Time [s]');ylabel('Amplitude [mV]');
    title('Raw','fontsize',12,'fontweight','bold');
subplot(2,1,2);
    plot(time,emg_filtered,'r');
    xlabel('Time [s]');ylabel('Amplitude [mV]');
    title('Filtered','fontsize',12,'fontweight','bold');

