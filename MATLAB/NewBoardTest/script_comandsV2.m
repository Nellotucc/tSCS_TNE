% Initialisation Port Com
addpath(genpath(strcat(pwd,'\ComPortFunc')));
addpath(genpath(strcat(pwd,'\MiscFunc')));

ComPort        = 'COM5';
Baudrate       = 115200*8;   %921600

run('OpenComPort.m'); %
clc;

%% Disable everything for channel 0
SetSingleChanState(s, 1, 1, 0, 0);

%% Try buster pulses

CARRIER_FREQ = 10e3;
STIMULATION_FREQ = 30;

% this is the 
burst_single_phase_pulse_duration = uint32( 480 ); % us. Remember this is half of the duration of a bi-phasic pulse
burst_duration                    = uint32( 1000 ); % us. The total duration of a burster (made of several short bi-phasic pulses)
burst_inner_pulse_repetition = 1;     % the number of inner bi-phasic pulses in a burster. 
burst_interpulse_duration = uint32( 0); % us. This is ideally set to 0 because there is no time between two bi-phasic pulses in a burster
burst_pulse_deadtime = uint32( 20 );        % us - 20 is the minimum
burst_interframe_duration = uint32(2000000); % us  
%burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % this is the burst frequency in us
                                  %      (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
                                   %     ) ; % us. This is the time between two bursters. 
burster_pulse_amplitude =  20; % mA

%%
% set burster parameters
SetSingleChanAllParam(s, 1, ...
                        burst_single_phase_pulse_duration, ...    % pulseDurationUS
                        burst_pulse_deadtime, ...                 % deadTimeUS
                        burst_interpulse_duration, ...            % interpulseDurationUS
                        burst_interframe_duration, ...            % interframeDurationUS
                        burst_inner_pulse_repetition, ...         % numberOfPulsesPerFrame
                        burster_pulse_amplitude ...               % IAmplitude in mA
                        );

%% stop output 
SetSingleChanState(s, 1, 1, 1, 0);

%% Test with HV active all the time / Parece melhor

for j = 1: 3
    %burster_pulse_amplitude =  35 + j*5; % mA 
    %burster_pulse_amplitude = 30;
 % set current
 %SetSingleChanSingleParam(s, 0, 6, burster_pulse_amplitude)
 %burster_pulse_amplitude

    for i = 1: 5
        %SetSingleChanState(s, 0, 1, 1, 0); %HV enable
        %SetSingleChanSingleParam(s, 0, 6, burster_pulse_amplitude)
        pause(0.05);
        SetSingleChanState(s, 0, 1, 1, 1);
        i

        pause(0.05);
        SetSingleChanState(s, 0, 1, 1, 0); %HV disable
        %SetSingleChanSingleParam(s, 0, 6, 0)
        %pause(6);
    end
    %pause(5);
end

%% stop output and HV
SetSingleChanState(s, 0, 1, 0, 0);

%%  Script PRM
    burster_pulse_amplitude = 20;
    SetSingleChanSingleParam(s, 0, 6, burster_pulse_amplitude);
    burster_pulse_amplitude

    for i = 1: 3
        %SetSingleChanState(s, 0, 1, 1, 0); %HV enable
        %SetSingleChanSingleParam(s, 0, 6, burster_pulse_amplitude)
        pause(0.05);
        SetSingleChanState(s, 0, 1, 1, 1);
        i
        %pause(1);
        SetSingleChanState(s, 0, 1, 1, 0); %HV disable
        %SetSingleChanSingleParam(s, 0, 6, 0)
        %pause(1);
    end

%% stop output and HV
SetSingleChanState(s, 0, 1, 0, 0);

%% Therapeutic protocol

% Set parameters

CARRIER_FREQ = 10e3; %dont using
STIMULATION_FREQ = 30;

% this is the 
burst_single_phase_pulse_duration = uint32( 500 ); % us. Remember this is half of the duration of a bi-phasic pulse
burst_duration                    = uint32( 1000 ); % us. The total duration of a burster (made of several short bi-phasic pulses)
burst_inner_pulse_repetition = 1;     % the number of inner bi-phasic pulses in a burster. 
burst_interpulse_duration = uint32( 0 *1000); % us. This is ideally set to 0 because there is no time between two bi-phasic pulses in a burster
burst_pulse_deadtime = uint32( 20 );        % us - 20 is the minimum
burst_interframe_duration = uint32(0 *1000); % us to ms ...33ms
%burst_interframe_duration = uint32( 1e6 * 1/STIMULATION_FREQ - ...    % this is the burst frequency in us
                                  %      (burst_inner_pulse_repetition * (2 * burst_single_phase_pulse_duration + burst_pulse_deadtime) ) ... % the total duration of the bi-phasic pulses including deadtime
                                   %     ) ; % us. This is the time between two bursters. 
burster_pulse_amplitude =  30; % mA

% set burster parameters
SetSingleChanAllParam(s, 1, ...
                        burst_single_phase_pulse_duration, ...    % pulseDurationUS
                        burst_pulse_deadtime, ...                 % deadTimeUS
                        burst_interpulse_duration, ...            % interpulseDurationUS
                        burst_interframe_duration, ...            % interframeDurationUS
                        burst_inner_pulse_repetition, ...         % numberOfPulsesPerFrame
                        burster_pulse_amplitude ...               % IAmplitude in mA
                        );
%% Active HV
SetSingleChanState(s, 1, 1, 1, 0);
%% Start output
 pause(0.05);
 SetSingleChanState(s, 1, 1, 1, 1);

  %% stop output 
SetSingleChanState(s, 1, 1, 1, 0);
 
 %% stop output and HV
SetSingleChanState(s, 0, 1, 0, 0);

%%  Teste individual
%SetSingleChanSingleParam(s, 0, 6, 15)
%SetSingleChanState(s, 0, 1, 1, 0); %HV enable
SetSingleChanState(s, 0, 1, 1, 1);
%SetSingleChanSingleParam(s, 0, 6, 0)


%%
fclose(s);
delete(s);
clear s;