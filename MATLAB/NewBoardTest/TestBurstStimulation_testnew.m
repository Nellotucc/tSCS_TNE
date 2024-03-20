% Initialisation Port Com
addpath(genpath(strcat(pwd,'\ComPortFunc')));
addpath(genpath(strcat(pwd,'\MiscFunc')));

ComPort        = 'COM9';
Baudrate       = 115200*8;   %921600

run('OpenComPort.m'); %
clc;

%%
% SetSingleChanState(s, ChannelID, POWER_state, HV_state, OUTPUT_state)
% 	* @param  CHANNEL_ID 	-> The number of the channel 
%	* @param  POWER_state 	-> General power supply of the channel (ENABLE/DISABLE)
%	* @param  HV_state 		-> High voltage converter (ENABLE/DISABLE) (useless if POWER_state is not ENABLE)
%	* @param  OUTPUT_state 	-> Output relay (ENABLE/DISABLE) (useless if POWER_state and HV_state are not ENABLE)

% disable the 0th channel
SetSingleChanState(s, 0, 0, 0, 0);

pause(0.5);

% test activating the 0th channel
SetSingleChanState(s, 0, 1, 0, 0);

%%

% TIMING_OFFSET_US									9 											//Correction des periodes ~ us
% PULSE_MIN_DURATION_US 						TIMING_OFFSET_US+10			//t1 min value ~ us
% PULSE_MAX_DURATION_US 						350											//t1 max value ~ us
% DEADTIME_MIN_DURATION_US 					TIMING_OFFSET_US+10 			//t2 min value ~ us (*voir NOTE 3)
% DEADTIME_MAX_DURATION_US 					350 										//t2 max value ~ us
% INTERPULSE_MIN_DURATION_US 				TIMING_OFFSET_US+10			//t3 min value ~ us
% INTERPULSE_MAX_DURATION_US 				1000										//t3 max value ~ us
% INTERFRAME_MIN_DURATION_US 				5000										//t4 min value ~ us (granulom�trie 10us)	!!! il s'agit bien de t4 et non t4' (m�me si en principe t4 =~ t4')
% INTERFRAME_MAX_DURATION_US 				100000									//t4' max value ~ us (granulom�trie 10us) !!! il s'agit bien de t4' et non t4 (m�me si en principe t4 =~ t4')
% MIN_PULSE_REPETITION							1												//Nombre min d'impulsions sucessives dans une frame
% MAX_PULSE_REPETITION							3												//Nombre max d'impulsions sucessives dans une frame
% MAX_CURRENT_MA 										100.0f									//Intensit� max du courant ~ mA


% test sending a pulse on channel 0
% SetSingleChanAllParam takes these parameters: (serialPortHandle, ChannelID, pulseDurationUS, deadTimeUS, interpulseDurationUS, interframeDurationUS, numberOfPulsesPerFrame, IAmplitude)
SetSingleChanAllParam(s, 0, ...
                        300, ...    % pulseDurationUS
                        0, ...    % deadTimeUS
                        500, ...    % interpulseDurationUS
                        5000, ...  % interframeDurationUS
                        3, ...      % numberOfPulsesPerFrame
                        10 ...      % IAmplitude in mA?
                        );

%enable channel 0
SetSingleChanState(s, ...
                        0, ...  % CHANNEL_ID
                        1, ...  % POWER_state 	-> General power supply of the channel (ENABLE/DISABLE)
                        1, ...  %  HV_state 	-> High voltage converter (ENABLE/DISABLE) (useless if POWER_state is not ENABLE)
                        1 ...   % OUTPUT_state 	-> Output relay (ENABLE/DISABLE) (useless if POWER_state and HV_state are not ENABLE)
                        );
% ONly stimulate for 5 seconds

%% pause(5);

% Disable output for channel 0
SetSingleChanState(s, 0, 1, 1, 0);

%% Disable everything for channel 0
SetSingleChanState(s, 0, 0, 0, 0);

%% Try buster pulses

CARRIER_FREQ = 10e3;
STIMULATION_FREQ = 30;

% this is the 
burst_single_phase_pulse_duration = uint32( 50 ); % us. Remember this is half of the duration of a bi-phasic pulse
burst_duration                    = uint32( 1000 ); % us. The total duration of a burster (made of several short bi-phasic pulses)
burst_inner_pulse_repetition = 1;     % the number of inner bi-phasic pulses in a burster. 
burst_interpulse_duration = uint32( 0 ); % us. This is ideally set to 0 because there is no time between two bi-phasic pulses in a burster
burst_pulse_deadtime = uint32( 20 );        % 20us 
burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % this is the burst frequency in us
                                        (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
                                        ) ; % us. This is the time between two bursters. 
burster_pulse_amplitude =  50; % mA


%% Try so send a few bursters

% activate the 0th channel without output, and with HV active
SetSingleChanState(s, 0, 1, 1, 0);

%%
% set burster parameters
SetSingleChanAllParam(s, 0, ...
                        burst_single_phase_pulse_duration, ...    % pulseDurationUS
                        burst_pulse_deadtime, ...                 % deadTimeUS
                        burst_interpulse_duration, ...            % interpulseDurationUS
                        burst_interframe_duration, ...            % interframeDurationUS
                        burst_inner_pulse_repetition, ...         % numberOfPulsesPerFrame
                        burster_pulse_amplitude ...               % IAmplitude in mA
                        );
%%
SetSingleChanState(s, 0, 1, 1, 1);

%% stop output
SetSingleChanState(s, 0, 1, 0, 0);

%% Official
for i = 1: 6
    SetSingleChanState(s, 0, 1, 1, 1);

    pause(0.05);
    SetSingleChanState(s, 0, 1, 0, 0);
    pause(5);
end

SetSingleChanState(s, 0, 1, 1, 0);

%% Test with HV active all the time / Parece melhor
 SetSingleChanState(s, 0, 1, 1, 0); %HV enable
 pause(1);
for i = 1: 50
%     SetSingleChanState(s, 0, 1, 1, 0); %HV enable
%     pause(0.05);
    SetSingleChanState(s, 0, 1, 1, 1);

    pause(0.05);
    SetSingleChanState(s, 0, 1, 1, 0); %HV disable . Mudar o comando para corrente igual a 0
    pause(5);
end

SetSingleChanState(s, 0, 1, 0, 0);

%%
fclose(s);
delete(s);
clear s;
