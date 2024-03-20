function [data,BAout,ERR] = readComBuffer(s,OPTin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Cr�ation :      ?
% Modification :  Jan.2017 
% Status :        [Prototype]
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% LOG
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DESCRIPTION
%  - Low level function, for reading all Serial port buffer
%  - No data processing done here (should be fast)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT (unit� SI)
%  - s         Serial object
%  - OPTin     Structure (optionelle) contenant une/des options avanc�es
%              Les champs doivent avoir le m�me nom et le m�me type que
%              ceux list�s plus bas c.f. "0) Local param."
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT (unit� SI)
%  - data      Byte(s) r�cup�r�e du buffer
%  - BAout     Nombre de bytes r�cup�r� du buffer
%  _ ERR       Erreur (0 si pas d'erreur sinon voir plus bas)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% EXEMPLE
%  - ...
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TO DO
%  - ...
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 0) Local param.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 0) Local param.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   OPT.TimeOut       = 0.5;   %Time out en seconde
   OPT.Ts            = 0.05;  %Timer increment
   OPT.MinRXByteCnt  = 1;     %Nombre minimum de byte pour lire le buffer
   OPT.MaxRXByteCnt  = 1e6;   %Nombre maximum de byte � lire (si le buffer en contient plus ils ne seront pas lus)
   OPT.TimeOutErrId  = -1;    %D�passement du d�lail max d'attente sans que l'on ait re�u au moins "OPT.MinRXByteCnt" bytes
   OPT.MaxRXTrig     = -2;    %Contenu du buffer d�passe "OPT.MaxRXByteCnt"

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1) Taches pr�liminaires
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ERR = 0;
   BAout = [];
   if(exist('OPTin','var'))
      OPTfield = fieldnames(OPTin);
      for i=1:numel(OPTfield)
         if(isfield(OPT,OPTfield{i}))
            OPT.(OPTfield{i})=OPTin.(OPTfield{i});
         end
      end
   end
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2) Fonction
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Timer = 0;
   BA    = get(s,{'BytesAvailable'});

   while(BA{1}<OPT.MinRXByteCnt)
      pause(OPT.Ts); 
      Timer = Timer + OPT.Ts;
      BA    = get(s,{'BytesAvailable'});
      if(Timer>=OPT.TimeOut)
         data = [];
         ERR  = OPT.TimeOutErrId;
         return;
      end
   end

   if(BA{1}>OPT.MaxRXByteCnt)
      data  = fread(s,OPT.MaxRXByteCnt);
      BAout = OPT.MaxRXByteCnt;
      ERR   = OPT.MaxRXTrig;
   else
      data  = fread(s,BA{1});
      BAout = BA{1};
   end
   
end

