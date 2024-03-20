function [  ] = SetSingleChanState(s, ChannelID, POWER_state, HV_state, OUTPUT_state)
%Active/désactive un cannal

   MSG_ID   = uint8(223);% 0xDF  
   MSG_END  = uint8(128);% 0x80
   
   DATA = uint8(0);
   
   if(POWER_state)
      DATA = DATA+1;
   end
   
   if(HV_state)
      DATA = DATA+2;
   end
   
   if(OUTPUT_state)
      DATA = DATA+4;
   end   
   
   CCR = 0;
   CCR = bitxor(CCR,MSG_ID);
   CCR = bitxor(CCR,ChannelID);
   CCR = bitxor(CCR,DATA);
   CCR = bitand(CCR,127);
   
   MSG   = [MSG_ID;ChannelID;DATA;CCR;MSG_END];
   
   fwrite(s, uint8(MSG'),'uint8');

   %pause(0.1);
end

