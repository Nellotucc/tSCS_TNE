function [ OUT ] = Bin2int32( IN )
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% DESCRIPTION
%  - Convertis les données binaire (5 char avec 7 bits utile) en int32
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% INPUT (unité SI)
%  - IN         Un vecteur contenant 5 nombre entier 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% OUTPUT (unité SI)
%  - 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% EXEMPLE 1
%  -
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% TO DO
%  - 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    A       = '00000000';
    BIN     = [[A;A;A;A;A],dec2bin(IN)];
    BIN2    = [BIN(1,end-6:end),BIN(2,end-6:end),BIN(3,end-6:end),BIN(4,end-6:end),BIN(5,end-6:end-3)];
%     BIN2    = [BIN(1,end-9:end),BIN(2,end-6:end),BIN(3,end-6:end),BIN(4,end-6:end),BIN(5,end-6:end)];
    OUT     = typecast(uint32(bin2dec(BIN2)), 'int32');

end

