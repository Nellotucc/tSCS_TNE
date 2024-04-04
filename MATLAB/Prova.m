clear all
close all
clc



% Specifica il percorso della cartella contenente i file .mat
Path = 'C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\DOME\30Hz\L1-L2';

% Ottieni la lista di tutti i file nella cartella
files = dir(fullfile(Path, '*.mat'));

% Ciclo for per caricare i file
for i = 1:numel(files)
    nome_file = fullfile(Path, files(i).name); % Ottieni il nome del file corrente
    load(nome_file); % Carica il file corrente

 emg_for_training=emg_data(1,1:4000);
 ACSR_window=200;

emg_filtered=ACSR_filter(emg_for_training,emg_data,ACSR_window);

figure;
  time=[1:1:length(emg_data)];
   subplot(2,1,1);
    plot(time,emg_data,'b');hold on;
    xlabel('Time [s]');ylabel('Amplitude [mV]');
    title('Raw','fontsize',12,'fontweight','bold');
subplot(2,1,2);
    plot(time,emg_filtered,'r');
    xlabel('Time [s]');ylabel('Amplitude [mV]');
    title('Filtered','fontsize',12,'fontweight','bold');




    % % Fai qualcosa con i dati caricati
    % % Ad esempio, se i tuoi file contengono una variabile chiamata 'dati', puoi usarla qui
    % % Esempio:
    % fprintf('Dati caricati da %s:\n', nome_file);
    % % disp(dati);
    % 
    % % Ora puoi lavorare con 'dati' come desideri
    % 
    % % Pulizia dopo aver lavorato con i dati, se necessario
    % clear dati;
end