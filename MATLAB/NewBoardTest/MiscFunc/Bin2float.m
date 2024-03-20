function [ OUT ] = Bin2float( IN )
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DESCRIPTION
%  - Convertis les données binaire (5 char avec 7 bits utile) en float
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT (unité SI)
%  - IN         Un vecteur contenant 5 nombre entier 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT (unité SI)
%  - 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% EXEMPLE 1
%     VALfloat    = 153.843;
%     CHARtab     = float2Bin(VALfloat);
%     VALfloat2   = Bin2float(CHARtab);
%
% EXEMPLE 2 (old)
%     VALfloat    = single(153.843);
%     VALbin      = dec2bin(typecast(VALfloat, 'uint32'),32);
%     VALbin2     = [ ['0',VALbin(1:7)];...
%                     ['0',VALbin(8:8+6)];...
%                     ['0',VALbin(15:15+6)];...
%                     ['0',VALbin(22:22+6)];...
%                     ['0',VALbin(29:end),'000']];
%     VALbytes    = bin2dec(VALbin2);
% 
%     Bin2float(VALbytes);
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TO DO
%  - 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    A       = '00000000';
    BIN     = [[A;A;A;A;A],dec2bin(IN)];
    BIN2    = [BIN(1,end-6:end),BIN(2,end-6:end),BIN(3,end-6:end),BIN(4,end-6:end),BIN(5,end-6:end-3)];
%     BIN2    = [BIN(1,end-9:end),BIN(2,end-6:end),BIN(3,end-6:end),BIN(4,end-6:end),BIN(5,end-6:end)];
    OUT     = typecast(uint32(bin2dec(BIN2)), 'single');

end

