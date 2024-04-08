%% USING OLD DATA
directories = {
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow1/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow2/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow3/',
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/black/'
};
directories = {
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/20march/yellow2/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/20march/black2/'
};
current_i = 25;
current_f = 50;
num_repetitions = 2;
bool_plot = true;
interpulse_duration = 100;

% dont forget to check in find_emg_filename that the right data format is
% uncommented !
x = best_electrode_finder(directories,current_i,current_f,interpulse_duration,num_repetitions,'conventional',bool_plot,false);

%% USING NEW DATA 
close all;
clear;
% format ex :
% emg_channelRF_L_current20_repetition1_window5s_interpulse50.mat
% emg_channelRF_L_current15_repetition2_window5s_interpulse50_t03987.mat
directories = {'C:\Users\local_B216353\Documents\tSCS\tSCS_TNE\MATLAB\DATA\DOME\Double_Pulse'};

current_i = 25;
current_f = 60;
num_repetitions = 2;
bool_plot = true;
interpulse_duration = 50;
control = false;

%muscles = {'RF_L','RF_R','SO_L','SO_R','TA_L','TA_R'};
muscles = {'SO_L'};
dataHarvester(directories,current_i,current_f,interpulse_duration,num_repetitions,muscles,bool_plot,control);

%%
emg_struct = load('/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/tbd/nm/emg_channelSO_R_current15_repetition3_window5s_interpulse50.mat');
emg = emg_struct.emg;
plot(emg)