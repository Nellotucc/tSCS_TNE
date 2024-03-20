% Initialisation Port Com
addpath(genpath(strcat(pwd,'\ComPortFunc')));
addpath(genpath(strcat(pwd,'\MiscFunc')));

ComPort        = 'COM9';
Baudrate       = 115200*8;   %921600

run('OpenComPort.m'); %
clc;

%%
% Initialisation du canal
Channel = 14; %10..19
Do_ask_software_version(s,Channel);

Do_send_wakeup(s,Channel); %enable high voltage converter

MaxCurrent_mA = 10; %5..100
Do_send_maxAmpl(s,Channel,MaxCurrent_mA);


%%
SetSingleChanState(s, 0, 0, 0, 0); 
SetSingleChanState(s, 1, 0, 0, 0);
%% 
SetSingleChanState(s, 0, 1, 0, 0);
%%
SetSingleChanAllParam(s,0,150,100,500,15000,1,10);
SetSingleChanState(s, 0, 1, 1, 0);
pause(1);
for i=1:2
   SetSingleChanState(s, 0, 1, 1, 1);
   pause(0.4);
   SetSingleChanState(s, 0, 1, 0, 1);
   pause(0.7);
end
SetSingleChanState(s, 0, 1, 0, 0);
%%
%SetSingleChanSingleParam(s,0,6,100);
SetAllChanAllParam(s,50,50,500,10000,1,80);
%%
n=0;
SetSingleChanState(s, 0, 1, 1, 1);
while(1)
   SetSingleChanSingleParam(s,0,6,round(20*(sin(n/20)+1)+10));
   pause(0.1);
   n=n+1;
end
%%
SetSingleChanState(s, 0, 1, 0, 1);
SetSingleChanAllParam(s,0,300,50,500,10000,3,100);
pause(1);
SetSingleChanAllParam(s,0,100,50,500,10000,1,1);
SetSingleChanState(s, 0, 1, 0, 0)
;
%%
% SetSingleChanAllParam(s,0,100,100,500,10000,1,20);
% pause(1);
% SetSingleChanAllParam(s,0,100,100,500,10000,1,0.1);
% 
% %%
% SetSingleChanAllParam(s,0,120,100,500,10000,1,0);
% SetSingleChanState(s, 0, 1, 1, 0);
% pause(0.1);
% SetSingleChanState(s, 0, 1, 0, 1);
% pause(0.1);
% SetSingleChanAllParam(s,0,200,100,500,10000,1,2.8);
% pause(1);
% SetSingleChanState(s, 0, 1, 0, 0);
% pause(0.1);
% SetSingleChanAllParam(s,0,120,100,500,10000,1,0);


%%
fclose(s);
delete(s);
clear s;
