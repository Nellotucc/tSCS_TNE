
%%conversione
clear all;
close all;
clc;

% Specifica la directory di salvataggio
directory = 'DATA\Gait\50HZ';

% Ottieni la lista di tutti i file .txt nella directory
filelist = dir(fullfile(directory, '*.txt'));

% Ciclo for per attraversare tutti i file .txt nella cartella
for i = 1:length(filelist)
    % Leggi i dati dal file .txt corrente
    data = importdata(fullfile(directory, filelist(i).name));
    
    % Estrai i dati della corrente (Channel 1)
    emg_data = data.data;
    
    % Crea il nome del file .mat da salvare
    [~, filename, ~] = fileparts(filelist(i).name);
    mat_filename = fullfile(directory, [filename '.mat']);
    
    % Salva i dati in un file .mat nella stessa cartella
    save(mat_filename, 'emg_data');
end


pause(5);

%% filtraggio
clear all;
close all;
clc;


Path = 'DATA\Gait\50HZ';


files = dir(fullfile(Path, '*.mat'));  % File list

for i = 1:numel(files)
    File_name = fullfile(Path, files(i).name);% Obtain current file name
        load(File_name);  

 %Filter 
 emg_data1=(emg_data)';
 stop=uint32(length(emg_data1)*5/6);
 emg_for_training1=emg_data1(1,1:8000);
 emg_for_training2=emg_data1(1,1:stop);
 ACSR_window=200;

emg_filtered1=ACSR_filter(emg_for_training1,emg_data1,ACSR_window);
emg_filtered2=ACSR_filter(emg_for_training2,emg_data1,ACSR_window);

    [~, name, ~] = fileparts(File_name);  %extract name file
     titolo = strrep(name, '_', ' ');  % CHANGE THE UNDERSCORE WITH SPACE!

   figure;
  time=[1:1:length(emg_data1)];
   subplot(2,2,1);
    plot(time,emg_data1,'b');hold on;
     xlabel('Time [s]');ylabel('Amplitude [mV]');
    title(titolo,'fontsize',12,'fontweight','bold');
subplot(2,2,3);
    plot(time,emg_filtered1,'r');
    xlabel('Time [s]');ylabel('Amplitude [mV]');
    title('Noise-filtered','fontsize',12,'fontweight','bold');
subplot(2,2,4);
    plot(time,emg_filtered2,'r');
    xlabel('Time [s]');ylabel('Amplitude [mV]');
    title('Noise&Artifact filtered','fontsize',12,'fontweight','bold');

pos = get(subplot(2,2,1), 'Position');
pos(1) = 0.25; % move right
pos(2) = 0.6;  % Move up
pos(3) = 0.5;  % width
pos(4) = 0.35; % height 
set(subplot(2,2,1), 'Position', pos);

end



=======
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
>>>>>>> 53f70bf10cb2d95fdb1b6068a525d8679b66d1e0
