function [  ] = SetSingleChanSingleParam(s, ChannelID, VarID, DATA)
%Charge 1 paramètre de stimulation d'un seul canal

   MSG_ID   = uint8(221);% 0xDD 
   MSG_END  = uint8(128);% 0x80
   
   switch(VarID)
      case 1  %t1
         DATA_BIN = uint322Bin(DATA);
      case 2  %t2
         DATA_BIN = uint322Bin(DATA);
      case 3  %t3
         DATA_BIN = uint322Bin(DATA);
      case 4  %t4
         DATA_BIN = uint322Bin(DATA);
      case 5  %Nb
         DATA_BIN = uint322Bin(DATA);
      case 6  %I
         DATA_BIN = float2Bin(DATA);    
      otherwise 
         DATA_BIN = uint322Bin(0);
   end
   
   MSG      = [MSG_ID;...
               uint8(ChannelID);...
               uint8(VarID);...
               DATA_BIN];

   CCR = 0;
   for i=1:numel(MSG)
      CCR = bitxor(CCR,MSG(i));
   end
   CCR = bitand(CCR,127);
   
   fwrite(s, uint8([MSG',CCR,MSG_END]),'uint8');

end

