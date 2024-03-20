% Initialisation Port Com
addpath(genpath(strcat(pwd,'\ComPortFunc')));
addpath(genpath(strcat(pwd,'\MiscFunc')));

ComPort        = 'COM9';
Baudrate       = 115200*8;   %921600

run('OpenComPort.m'); %
clc;

%% 
Channel = 0; 
MaxCurrent_mA = 50;

% Ramp 
% for i=1:3 % era 3
% matrix_current(i) = 15+i*5; %20...50
% end


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

% TIMING_OFFSET_US									9 					//Correction des periodes ~ us
% PULSE_MIN_DURATION_US 						TIMING_OFFSET_US+10		//t1 min value ~ us
% PULSE_MAX_DURATION_US 						350						//t1 max value ~ us
% DEADTIME_MIN_DURATION_US 					TIMING_OFFSET_US+10 		//t2 min value ~ us (*voir NOTE 3)
% DEADTIME_MAX_DURATION_US 					350 						//t2 max value ~ us
% INTERPULSE_MIN_DURATION_US 				TIMING_OFFSET_US+10			//t3 min value ~ us
% INTERPULSE_MAX_DURATION_US 				1000						//t3 max value ~ us
% INTERFRAME_MIN_DURATION_US 				5000						//t4 min value ~ us (granulom�trie 10us)	!!! il s'agit bien de t4 et non t4' (m�me si en principe t4 =~ t4')
% INTERFRAME_MAX_DURATION_US 				100000						//t4' max value ~ us (granulom�trie 10us) !!! il s'agit bien de t4' et non t4 (m�me si en principe t4 =~ t4')
% MIN_PULSE_REPETITION							1						//Nombre min d'impulsions sucessives dans une frame
% MAX_PULSE_REPETITION							3						//Nombre max d'impulsions sucessives dans une frame
% MAX_CURRENT_MA 										100.0f			//Intensit� max du courant ~ mA

%%

% test sending a pulse on channel 0
% SetSingleChanAllParam takes these parameters: (serialPortHandle, ChannelID, pulseDurationUS, deadTimeUS, interpulseDurationUS, interframeDurationUS, numberOfPulsesPerFrame, IAmplitude)
SetSingleChanAllParam(s, ...
                       0, ...      % channel
                        150, ...    % Pulse Width -  pulseDurationUS (pulse width) - 1mS = 1000uS
                        100, ...    % deadTimeUS (tempo entre as ondas bifasicas)
                        500, ...    % interpulseDurationUS
                        5000, ...  % interframeDurationUS 
                        1, ...      % numberOfPulsesPerFrame (numero de repeticoes por pulso)
                        40 ...      % Amplitude in mA? - to check
                        );

%enable channel 0
SetSingleChanState(s, ...
                        0, ...  % CHANNEL_ID
                        1, ...  % POWER_state 	-> General power supply of the channel (ENABLE/DISABLE)
                        1, ...  %  HV_state 	-> High voltage converter (ENABLE/DISABLE) (useless if POWER_state is not ENABLE)
                        1 ...   % OUTPUT_state 	-> Output relay (ENABLE/DISABLE) (useless if POWER_state and HV_state are not ENABLE)
                        );
% ONly stimulate for 5 seconds

%% Test sem condicao

MaxCurrent_mA = 5;

% Ramp - check if its necessary
% for i=1:3 % era 3
% matrix_current(i) = 15+i*5; %20...50
% end

% disable the 0th channel
SetSingleChanState(s, 0, 0, 0, 0);
pause(0.5);
% test activating the 0th channel
SetSingleChanState(s, 0, 1, 0, 0);

% 2:channel, 3-Pulse Width, 4-deadTimeUS, 5-interpulseDurationUS, 6-interframeDurationUS, 7-numberOfPulsesPerFrame, Amplitude in mA
 

for j=1:10000
    % test activating the 0th channel
    %SetSingleChanAllParam(s,0, 150, 100, 500, 1000, 1, MaxCurrent_mA);
    SetSingleChanState(s, 0, 1, 0, 0);
    pause(0.5)

    SetSingleChanAllParam(s,0, 150, 100, 500, 5000, 2, MaxCurrent_mA);
    SetSingleChanState(s, 0, 1, 1, 1); %enable
    pause(0.5)
    SetSingleChanState(s, 0, 1, 1, 0);% Disable
end

% Disable output for channel 0
%SetSingleChanState(s, 0, 1, 1, 0);

%% Test for FES

MaxCurrent_mA = 50;

% Ramp - check if its necessary
% for i=1:3 % era 3
% matrix_current(i) = 15+i*5; %20...50
% end

% disable the 0th channel
SetSingleChanState(s, 0, 0, 0, 0);
pause(0.5);
% test activating the 0th channel
SetSingleChanState(s, 0, 1, 0, 0);

%channel, Pulse Width, deadTimeUS, interpulseDurationUS, %interframeDurationUS, numberOfPulsesPerFrame, Amplitude in mA
SetSingleChanAllParam(s,0,300, 19, 500, 5000, 3, MaxCurrent_mA); 

for j=1:5
    if MaxCurrent_mA <50  %is not MaxCurrent - how to receive the current? "status"
        SetSingleChanState(s, 0, 1, 1, 1); %enable
    elseif MaxCurrent_mA >= 50  
        SetSingleChanState(s, 0, 1, 1, 0); %Disable
    end
    pause(0.5);
end


%% Test for FES - Diferents parameters

% disable the 0th channel
SetSingleChanState(s, 0, 0, 0, 0);
pause(0.5);
% test activating the 0th channel
SetSingleChanState(s, 0, 1, 0, 0);

for j=1:5
    if MaxCurrent_mA <50  %is not MaxCurrent - how to receive the current? "status"
        SetSingleChanAllParam(s,0,300, 19, 500, 5000, 2, 10);
        SetSingleChanState(s, 0, 1, 1, 1); %enable
        pause(0.5);

        SetSingleChanAllParam(s,0,600, 19, 500, 5000, 4, 30);
        SetSingleChanState(s, 0, 1, 1, 1); %enable

    elseif MaxCurrent_mA >= 50  
        SetSingleChanState(s, 0, 1, 1, 0); %Disable
    end
    pause(0.5);
end

%% pause(5);

% Disable output for channel 0
SetSingleChanState(s, 0, 1, 1, 0);

%% Disable everything for channel 0
SetSingleChanState(s, 0, 0, 0, 0);

%%
fclose(s);
delete(s);
clear s;
