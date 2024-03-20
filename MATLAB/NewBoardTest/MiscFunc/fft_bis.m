function OUT = fft_bis(y,OPTin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Date dernière modification : 05/10/2015
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DESCRIPTION
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT (unité SI)
%  - y   Un vecteur ou un matrice y = [y1(Nx1),y2(Nx1),...]
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT (unité SI)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TO DO
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 0) Local param.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   OPT.Te               = (2048/16e6); % Péride d'échantillonnage
   OPT.DoSmooth         = 1;
   OPT.SmoothWindows    = 1;   % Largeure de la fenêtre de lissage de la réponse en Hz
   OPT.Plot             = 1;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1) Taches préliminaires
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   LOG      = {'#### fft_bis ####'};
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

    Fs      = OPT.Te^-1;
    
    [L,n] = size(y);
    if(n>L)
       y = y';
       [L,n] = size(y);
    end

    NFFT    = 2^nextpow2(L);
    OUT.f   = Fs/2*linspace(0,1,NFFT/2+1)';
    
    for i=1:n
       Y           = fft(y(:,i),NFFT)/L;
       OUT.Y(:,i)  = 2*Y(1:NFFT/2+1);
       if(OPT.DoSmooth)
           sh           = max(round(OPT.SmoothWindows/(OUT.f(2)-OUT.f(1))),2);        
           OUT.A(:,i)   = smooth(20*log10(abs(OUT.Y(:,i))),sh);
           OUT.Phi(:,i) = (180/pi).*smooth((angle(OUT.Y(:,i))),sh);
       else
           OUT.A(:,i)   = 20*log10(abs(OUT.Y(:,i)));
           OUT.Phi(:,i) = (180/pi).*angle(OUT.Y(:,i));
       end
    end
    
    if(OPT.Plot)
        figure;
        if(size(OUT.A,2)>1)
         semilogx(OUT.f,OUT.A,'linewidth',2);
        else
         semilogx(OUT.f,OUT.A,'g','linewidth',2);
        end
        xlabel('Frequency ~ Hz)');
        ylabel('|Y(f)| ~ dB');
        xlim([1 Fs/2.005]);
    end
end
