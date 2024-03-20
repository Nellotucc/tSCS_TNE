function [DATA,LOG,MISC] = GetStreamedData(s,OPTin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Cr�ation :      Jan-2017
% Modification :  Jan-2017
% Status :        [Prototype]
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% LOG
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DESCRIPTION
%  - Fonction "haut niveau" pour la r�c�ption d'un flux de donn�e � partie
%    d'un "serial obj"
%  - Les donn�es � recevoires sont cod�es sur 7bits et sont organis�es en
%    paquets. Le premier byte du packet est le seul � avoir le bit de poid le plus
%    fort � 1.(Le format des paquets est d�finis par l'option "OPT.PacketFormat"
%    (voir plus bas))
%  - La fonction de d�codage des paquets doit �tre cod�es individuellement
%    pour chaque nouveau type (voir pour rendre �a g�n�rale)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT (unit� SI)
%  - s         Serial object
%  - OPTin     Structure (optionelle) contenant une/des options avanc�es
%              Les champs doivent avoir le m�me nom et le m�me type que
%              ceux list�s plus bas c.f. "0) Local param."
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT (unit� SI)
%  - OUT          Une structure contenant les champs suivants
%     *.field1      ...
%  - LOG          Les notifications ( afficher avec la fonction
%                 textDisplay(LOG) )
%  - MISC         Une structure contenant les champs suivants :
%     *.err       0->Si pas d'erreur d�tect�e
%                 1->"Erreur probable"
%     *.field1      ...
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% EXEMPLE
%  - ...
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TO DO
%  - ...
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
persistent PK_SCRAP;

if isempty(PK_SCRAP) 
   PK_SCRAP = [];
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 0) Local param.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   OPT.Mode    = 1;        % 1-> "TimeOut mode" (r�cup�ration des donn�es pendant une dur�es d�finie)
                           % 2-> "Data mode" (attente d'un nombre donn� de paquet) 
   OPT.TimeOut = 100;      % Dur�e de r�c�ption en mode "TimeOut"(OPT.Mode=1)
   OPT.ABSTimeOut = 100;   % Dur�e de r�c�ption max en mode "Data" (OPT.Mode=2)
                           % Si "ABSTimeOut<TimeOut" prioritaire sur OPT.TimeOut en mode time out (OPT.Mode=1)
   OPT.DataLim = 1000;     % Idem que "OPT.TimeOut" mais pour le nombre de paquets
   OPT.ABSDataLim = 1000000; % Idem que "OPT.ABSTimeOut" mais pour le nombre de paquets
   OPT.MaxScrapSize = 100; % Nombre max de bytes dans la variable "PK_SCRAP" entre 2 appels de la fonction pour �viter qu'en cas d'erreur elle se remplisse en continu
   OPT.ClearScrap = false; % If true -> Les restes contenus dans la variable "PK_SCRAP" sont supprim� entre 2 appel de la fonction
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1) Taches pr�liminaires
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   LOG      = {'#### GetStreamedData ####'};
   MISC.err = 0;
% Input option processing    
   if(exist('OPTin','var'))
      OPTfield = fieldnames(OPTin);
      for i=1:numel(OPTfield)
         if(isfield(OPT,OPTfield{i}))
            OPT.(OPTfield{i})=OPTin.(OPTfield{i});
         else
            LOG{end+1} = [' ! (1.1) Option : "',OPTfield{i},'" non valide. Valeur par d�faut utilis�e'];
         end
      end
   end
   
   if(OPT.ClearScrap)
      PK_SCRAP = [];
   elseif(numel(PK_SCRAP)>OPT.MaxScrapSize)
      PK_SCRAP = PK_SCRAP(end-OPT.MaxScrapSize:end);
   end
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2) Fonction
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   %DATA        = [0,0];
   DATA        = zeros( floor(1.5*OPT.ABSDataLim), 2);
   DATA_ID     = 1;
   PK_SZ       = 1+5; %uint8(header) int32
   PK_SCRAP    = []; %Reste de la derni�re lecture du buffer (paquet incomplet)
   END         = false;
   
   tic;
   while(~END)
      [PK_NEW,~,~]   = readComBuffer(s);
      PK_ALL         = [PK_SCRAP;PK_NEW];    %Concat�nation des donn�es restantes de la derni�re lecture et des nouvelles
      BY_NUM         = numel(PK_ALL);        %Nombre de bytes re�ues au total
      if(BY_NUM>0)
         [ID0,ID]       = deal(find(PK_ALL>=128,1,'first'));       %recherche du debut du premier paquet contenu dans les donn�es brute (normalement ID=1 si il ne s'agit pas de la premi�re lecture du buffer et qu'il n'y a pas eu d'erreur)
         if(~isempty(ID0))
            PK_NUM         = floor((BY_NUM-ID+1)/PK_SZ);    %Nombre de paquet entier contenu dans le buffer (normalement si il n'y a pas d'erreur de cimmunication)
            if(PK_NUM>=1)
               for i=1:PK_NUM
                  PK_TMP   = PK_ALL(ID:ID+PK_SZ-1);
                  if(any((PK_TMP(2:end)>=128)))  %Erreur check if no Byte with first bit set inside the packet and if next bit has it
                     ID2      = find(PK_TMP(2:end)>=128,1,'first');
                     PK_SCRAP = PK_ALL(ID+ID2:end);
                     break;
                  else
                     DATA(DATA_ID,:)   = [PK_TMP(1), Bin2int32(PK_TMP(2:6))];
                     DATA_ID           = DATA_ID+1;
                     ID                = ID+PK_SZ;
                  end
                  if(i==PK_NUM)
                     PK_SCRAP = PK_ALL(ID0+PK_NUM*PK_SZ:end);
                  end
               end
            else
               PK_SCRAP=PK_ALL;
            end
         else
            PK_SCRAP=PK_ALL;
         end
      end
      
      % Test if time-out/data-out reached
      if(isempty(PK_NEW))
         END=true;
      else
%          if((toc>=OPT.ABSTimeOut) || ((size(DATA,1)-1)>=OPT.ABSDataLim))
%             END=true;
%          elseif((OPT.Mode==1) && (toc>=OPT.TimeOut))
%             END=true;
%          elseif((OPT.Mode==2) && ((size(DATA,1)-1)>=OPT.DataLim))
%             END=true;
%          end
         if((toc>=OPT.ABSTimeOut) || DATA_ID>=OPT.ABSDataLim)
            END=true;
         elseif((OPT.Mode==1) && (toc>=OPT.TimeOut))
            END=true;
         elseif((OPT.Mode==2) && DATA_ID>=OPT.DataLim)
            END=true;
         end
      end
   end
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 3) Finalisation
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   %DATA = DATA(2:end,:);
   DATA = DATA(1:DATA_ID,:);
end
