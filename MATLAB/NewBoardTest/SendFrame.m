function [frame,LOG,MISC] = SendFrame(FRAME, TrigMode, s, OPTin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Création :      nov. 2016
% Modification :  nov. 2016
% Status :        [Prototype]
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% LOG
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DESCRIPTION
%  - ...
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT (unité SI)
%  - FRAME     Une <cell array> contenant les champs pour les vibreurs
%   *.field1    ...
%  - TrigMode  true/false
%  - s         Serial objet 
%  - OPTin     Structure (optionelle) contenant une/des options avancées
%              Les champs doivent avoir le même nom et le même type que
%              ceux listés plus bas c.f. "0) Local param."
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT (unité SI)
%  - LOG          Les notifications ( afficher avec la fonction
%                 textDisplay(LOG) )
%  - MISC         Une structure contenant les champs suivants :
%     *.err       0->Si pas d'erreur détectée
%                 1->"Erreur probable"
%     *.field1      ...
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
   OPT.ValidDriverID = (1:16)'; %! numérotation commence à 1
   OPT.StratFrame    = uint8(254);
   OPT.StopFrame     = uint8(170);
   OPT.MaxEffect     = 8;
   OPT.MaxEffectID   = 127;
   OPT.MaxTime       = 2^14-1;
   OPT.MaxAmpli      = 2^7-1;
   OPT.TypeList      = {'RTP','LIB'};
   OPT.PrintOnly     = false;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1) Taches préliminaires
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   LOG      = {'#### SendFrame ####'};
   MISC.err = 0;
% Input option processing    
   if(exist('OPTin','var'))
      OPTfield = fieldnames(OPTin);
      for i=1:numel(OPTfield)
         if(isfield(OPT,OPTfield{i}))
            OPT.(OPTfield{i})=OPTin.(OPTfield{i});
         else
            LOG{end+1} = [' ! (1.1) Option : "',OPTfield{i},'" non valide. Valeur par défaut utilisée'];
         end
      end
   end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2) Fonction
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   if(TrigMode)
      frame = uint8(OPT.StratFrame-2);
   else
      frame = uint8(OPT.StratFrame);
   end
   
   n = numel(FRAME);
   if(n>max(OPT.ValidDriverID))
      n = max(OPT.ValidDriverID);
      LOG{end+1}  = [' ! (2.1) : Plus grand inder de Driver : ',num2str(n)];
      MISC.err    = 1;
   end
   
   for i=1:n
      if(isempty(FRAME{i}))
      else
         if(~any(OPT.ValidDriverID==(i)))
            LOG{end+1}  = [' ! (2.2) : Driver ID:',num2str(i),' non valide'];
            MISC.err    = 1;
         else
            if(~isfield(FRAME{i},'Type'))
               LOG{end+1}  = [' ! (2.3) : Missing message type for Driver :',num2str(i)];
               MISC.err    = 1;
            else
% ############ Mode RTP ############
               if(strcmp(FRAME{i}.Type,OPT.TypeList{1}))    %RTP
                  if(isfield(FRAME{i},'Start_ms') && isfield(FRAME{i},'Duration_ms')&& isfield(FRAME{i},'Amp'))
                     tmp = ['00000000',dec2bin(i-1),'00'];
                     frame(end+1) = uint8(bin2dec(tmp(end-7:end)));
                     if(FRAME{i}.Start_ms>OPT.MaxTime)
                        LOG{end+1}  = [' ! (2.4) : Start_ms too big for Driver :',num2str(i),'. Value replaced by :',num2str(OPT.MaxTime)];
                        FRAME{i}.Start_ms = OPT.MaxTime;
                        MISC.err    = 1;
                     elseif(FRAME{i}.Start_ms<0)
                        LOG{end+1}  = [' ! (2.4) : Start_ms too small for Driver :',num2str(i),'. Value replaced by :',num2str(0)];
                        FRAME{i}.Start_ms = 0;
                        MISC.err    = 1;                        
                     end
                     Start_ms_bin   = ['0000000000000',dec2bin(floor(FRAME{i}.Start_ms))];
                     frame(end+1)   = uint8(bin2dec(Start_ms_bin(1:end-7)));
                     frame(end+1)   = uint8(bin2dec(Start_ms_bin(end-6:end)));

                     if(FRAME{i}.Duration_ms>OPT.MaxTime)
                        LOG{end+1}  = [' ! (2.4) : Duration_ms to big for Driver :',num2str(i),'. Value replaced by :',num2str(OPT.MaxTime)];
                        FRAME{i}.Duration_ms = OPT.MaxTime;
                        MISC.err    = 1;
                     elseif(FRAME{i}.Duration_ms<0)
                        LOG{end+1}  = [' ! (2.4) : Duration_ms to small for Driver :',num2str(i),'. Value replaced by :',num2str(0)];
                        FRAME{i}.Duration_ms = 0;
                        MISC.err    = 1;                        
                     end 
                     Duration_ms_bin   = ['0000000000000',dec2bin(floor(FRAME{i}.Duration_ms))];
                     frame(end+1)   = uint8(bin2dec(Duration_ms_bin(1:end-7)));    
                     frame(end+1)   = uint8(bin2dec(Duration_ms_bin(end-6:end)));
 
                     if(FRAME{i}.Amp>OPT.MaxAmpli)
                        LOG{end+1}  = [' ! (2.4) : Amplitude to big for Driver :',num2str(i),'. Value replaced by :',num2str(OPT.MaxAmpli)];
                        FRAME{i}.Amp=OPT.MaxAmpli;
                        MISC.err    = 1;
                     elseif(FRAME{i}.Amp<0)
                        LOG{end+1}  = [' ! (2.4) : Amplitude to small for Driver :',num2str(i),'. Value replaced by :',num2str(0)];
                        FRAME{i}.Amp = 0;
                        MISC.err    = 1;     
                     end                              
                     Amp_bin        = ['0000000000000',dec2bin(floor(FRAME{i}.Amp))];
                     frame(end+1)   = uint8(bin2dec(Amp_bin(end-6:end)));
                     
                  else
                     LOG{end+1}  = [' ! (2.4) : Non valide arg. name for Driver :',num2str(i)];
                     MISC.err    = 1;
                  end
% ############ Mode LIB ############                  
               elseif(strcmp(FRAME{i}.Type,OPT.TypeList{2}))%LIB
                  if(isfield(FRAME{i},'Start_ms') && isfield(FRAME{i},'Effect_ID'))
                     tmp = ['00000000',dec2bin(i-1),'10'];
                     frame(end+1) = uint8(bin2dec(tmp(end-7:end)));
                     if(FRAME{i}.Start_ms>OPT.MaxTime)
                        LOG{end+1}  = [' ! (2.4) : Start_ms too big for Driver :',num2str(i),'. Value replaced by :',num2str(OPT.MaxTime)];
                        FRAME{i}.Start_ms = OPT.MaxTime;
                        MISC.err    = 1;
                     elseif(FRAME{i}.Start_ms<0)
                        LOG{end+1}  = [' ! (2.4) : Start_ms too small for Driver :',num2str(i),'. Value replaced by :',num2str(0)];
                        FRAME{i}.Start_ms = 0;
                        MISC.err    = 1;                        
                     end
                     Start_ms_bin   = ['0000000000000',dec2bin(floor(FRAME{i}.Start_ms))];
                     frame(end+1)   = uint8(bin2dec(Start_ms_bin(1:end-7)));
                     frame(end+1)   = uint8(bin2dec(Start_ms_bin(end-6:end)));
% #######################################################################
% ####################################################################### 
                     if(numel(FRAME{i}.Effect_ID)>OPT.MaxEffect)
                        LOG{end+1}  = [' ! (2.4) : Effect list to long for Driver :',num2str(i),'. Value replaced by :',num2str(OPT.MaxEffect)];
                        FRAME{i}.Effect_ID = FRAME{i}.Effect_ID(1:OPT.MaxEffect);
                        MISC.err    = 1;
                     end
                     Effect_Count_bin  = ['0000000000000',dec2bin(numel(FRAME{i}.Effect_ID))];
                     frame(end+1)   = uint8(bin2dec(Effect_Count_bin(end-6:end)));
                     for(j=1:numel(FRAME{i}.Effect_ID))
                        if(FRAME{i}.Effect_ID(j)>OPT.MaxEffectID || FRAME{i}.Effect_ID(j)<0)
                           LOG{end+1}  = [' ! (2.4) : Non existing Effect_ID for Driver :',num2str(i),' replaced by effect 1'];
                           MISC.err    = 1;
                           FRAME{i}.Effect_ID(j) = 1;
                        end
                           Effect_ID_bin  = ['0000000000000',dec2bin(floor(FRAME{i}.Effect_ID(j)))];
                           frame(end+1)   = uint8(bin2dec(Effect_ID_bin(end-6:end)));
                     end
% #######################################################################
% #######################################################################
                  else
                     LOG{end+1}  = [' ! (2.4) : Non valide arg. name for Driver :',num2str(i)];
                     MISC.err    = 1;
                  end
% ####################################                     
               else
                  LOG{end+1}  = [' ! (2.4) : ',FRAME{i}.Type,' non valide type for Driver :',num2str(i)];
                  MISC.err    = 1;
               end
            end
         end
      end
   end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 3) Fin
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   frame(end+1) = uint8(OPT.StopFrame);
   
   if(OPT.PrintOnly)
      disp(frame);
   else
      fwrite(s, frame,'uint8');
   end
   
   if(MISC.err)
      textDisplay(LOG);
   end
end
