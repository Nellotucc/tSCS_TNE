function [] = textDisplay(str,dispWorkerID,spaceCnt)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DESCRIPTION
%  - Display text notification 
%  - Usefull if parallel computing to identifie worker ID
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT (unit� SI)
%  - str          	Un <cell array> contenant les lignes de texte � afficher
%  - dispWorkerID    1-> Affiche l'identifiant du 'Worker' 
%                    (optionnel, d�faut : 1)
%  - spaceCnt        Le nombre d'espace � ajouter au d�but de chaques lignes
%                    (optionnel, d�faut : 0)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT (unit� SI)
%  - 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% EXEMPLE 1
%  str = {'a','b'};
%  textDisplay(str);
%
%  Main worker 
%   a
%   b
%
% EXEMPLE 2
%  textDisplay(str,0,5);
%
%        a
%        b
%
% EXEMPLE 3
%  matlabpool 2;
%  parfor j=1:2
%    textDisplay(str);
%  end
%
%  Worker ID 1
%   a
%   b
%
%  Worker ID 2 
%   a
%   b
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TO DO
%  - 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


   if(~exist('dispWorkerID','var'))
      dispWorkerID = true;
   end   
   
   if(~exist('spaceCnt','var'))
      space = '';
   else
      space = repmat([' '],1,spaceCnt);
   end

   fprintf('\n');   

   if(dispWorkerID)
      T = getCurrentTask(); 
      if(~isempty(T))
         fprintf([space,'Worker ID ',num2str(T.ID),'\n']);
      else
         fprintf([space,'Main worker \n']);
      end
   end
   
   if(ischar(str))
      fprintf([space,' ',str,'\n']);
   else
      for i=1:numel(str)
         fprintf([space,' ',str{i},'\n']);
      end
   end
   fprintf(['\n']);
end

