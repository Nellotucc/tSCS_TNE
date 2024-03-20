function [OUT,ERR] = Bin2Var(BinData,format)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DESCRIPTION
%  -  Convertis les données binaires reçues via la liaison serie (sous
%     forme d'octet avec 7 bits utile par octets) en une variable
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT (unité SI)
%  -  BinData        Un vecteur contenant 2,3, ou 5 valeurs (de 0 à 127)
%  -  format         Le format de la variable de sortie (uint/int8/16/32,
%                    single) 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT (unité SI)
%  - OUT             Variable reconstruite
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% EXEMPLE 1
%  -
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TO DO
%  - 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   OUT = [];

   if(any(BinData>127))
      ERR = 1;
      disp(' #### Bin2Var #### -> plage de valeur d entrée incorrect');
      return;
   end

   if(strcmp(format,'int32')||strcmp(format,'uint32')||strcmp(format,'single'))
      if(numel(BinData)~=5)
         ERR = 2;
         disp(' #### Bin2Var #### -> Longueur du vecteur de donnée d entrée incorecte');
         return;
      end
      A       = '00000000';
      BIN     = [[A;A;A;A;A],dec2bin(IN)];
      BIN2    = [BIN(1,end-6:end),BIN(2,end-6:end),BIN(3,end-6:end),BIN(4,end-6:end),BIN(5,end-6:end-3)];
      OUT     = typecast(uint32(bin2dec(BIN2)), 'int32');
%     
%     OUT     = typecast(uint32(bin2dec(BIN2)), 'single');
   elseif(strcmp(format,'int16')||strcmp(format,'uint16'))
   else
      ERR = 3;
      disp(' #### Bin2Var #### -> Format invalide');
      return;
   end

end

