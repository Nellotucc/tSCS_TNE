function [  ] = SetSingleChanAllParam_v2(s, ChannelID, t1, t2, t3, t4, Nb, I, mode)
%Charge tous les paramètres de stimulation d'un seul canal

   MSG_ID   = uint8(220);% 0xDC 
   MSG_END  = uint8(128);% 0x80
   
   t1_BIN   = uint322Bin(t1);
   t2_BIN   = uint322Bin(t2);
   t3_BIN   = uint322Bin(t3);
   t4_BIN   = uint322Bin(t4);
   
   Nb_BIN   = uint8(Nb);
   I_BIN    = float2Bin(I);   
   mode_BIN = uint8(mode);
   
   MSG      = [MSG_ID;...
               uint8(ChannelID);...
               t1_BIN;...
               t2_BIN;...
               t3_BIN;...
               t4_BIN;...
               Nb_BIN;...
               I_BIN;...
               mode_BIN];

   CCR = 0;
   for i=1:numel(MSG)
      CCR = bitxor(CCR,MSG(i));
   end
   CCR = bitand(CCR,127);
   
   fwrite(s, uint8([MSG',CCR,MSG_END]),'uint8');

end

