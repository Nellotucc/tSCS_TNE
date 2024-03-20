%filePath = "C:\Users\ricca\OneDrive\Documenti\TNE_MA2\tSCS_Autumn2023\3.Experiments\RecordedExperiments\Chris\Conv_DP_T3_55mA.txt";
%filePath = "C:\Users\ricca\OneDrive\Documenti\TNE_MA2\tSCS_Autumn2023\3.Experiments\RecordedExperiments\Riccardo\Conv_DP_t11-T12_T3_45mA";
filePath = "C:\Users\local_B216353\Documents\RICCARDO_tSCS\MATLAB\DATA\Ahmed2802\Elec2.txt";
data = readmatrix(filePath);




disp("begin");
disp(size(data));

sf = 1000;
plot_chs = false;
bool_plot_PSD = false;
selected_filters = 3;
paper_nb = 1;
selectedChannels = {0,1};
muscle_loc = {'distal','proximal'};
interpulse_duration = 100000;
bool_plot_MEP = false;
bool_colour_response = false;
numberOfValues = 5000; 


emg = data(:,1:1);

disp(selectedChannels{1});


[norm_factor_afterfilter1, EMG_preprocessed1] = EMG_preprocessing(emg, sf, selected_filters, 0, plot_chs, selectedChannels, bool_plot_PSD, paper_nb); %preprocess
plot(EMG_preprocessed1);

%response = ActionPotDetectDoublePulseAC(100,muscle_loc, EMG_preprocessed1,sf, interpulse_duration,norm_factor_afterfilter1,bool_plot_MEP,bool_colour_response,numberOfValues); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'

%%
numberOfcurrents = 2;
numberOfrepetitions = 2;
n_channels = min(size(emg));

all_responses = cell(1, numberOfcurrents); % 1x2 array of responses
interpulse_duration = 50000;

for j = 0:numberOfcurrents-1
    rep_response = cell(n_channels, numberOfrepetitions);  % Initialize response cell array for each i. It will be channelsXrepetitions
    current = 5 + j*5;
    
    for i = 0:numberOfrepetitions-1
        t_0 = 146000 + 5000*i + j;
        emg = EMG_preprocessed1(t_0-100:t_0+4899, :);
        response = ActionPotDetectDoublePulseAC(100, muscle_loc, emg, sf, interpulse_duration, norm_factor_afterfilter1, false, bool_colour_response, numberOfValues);
        
        % Assign each element of response to corresponding cell in rep_response
        for k = 1:numel(response)
            rep_response{k, i+1} = response{k};
        end
        
        plot_response(rep_response, current);

        %pause(0);
        
        disp(i);
    end
    
    all_responses{j+1} = rep_response;
end

disp(all_responses)
disp(rep_response)
%%


%%
% PRESUMED M WAVE for t_0 = 7100+140000, I wanted to know if its maybe too
% hard the suppression threshold value.
% qlso it looks like the interpulse interval changes from 50 to 100

t_0 = 161000;
emg = EMG_preprocessed1(t_0-100:t_0+4899,1);

plot(emg);
interpulse_duration = 50;
response = ActionPotDetectDoublePulse3(50,muscle_loc{1},emg,sf, interpulse_duration,norm_factor_afterfilter1,true,true,numberOfValues); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'
%plot_response(rep_response,current);

fprintf('Response : %s\n', response);

%%
all_responses = {}; % jxi array of responses
interpulse_duration = 50000;
for j=0:0
    rep_response = {};  % Initialize response cell array for each i
    current = 5+j*5;
    for i=0:0
        t_0 = 146000+5000*i+j;
        emg = EMG_preprocessed1(t_0-100:t_0+4899,1);
        response = ActionPotDetectDoublePulse3(100,muscle_loc{1},emg,sf, interpulse_duration,norm_factor_afterfilter1,true,bool_colour_response,numberOfValues); %find response 'no response', 'MEP reflex', 'M-wave', 'invalid'
        rep_response = [rep_response,response];
        %plot_response(rep_response,current);
        plot(emg)
        pause(0);    
    end
    all_responses = [all_responses; response];

end

disp(rep_response)