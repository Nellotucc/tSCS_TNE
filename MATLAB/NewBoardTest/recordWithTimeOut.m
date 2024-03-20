function [t,y] = recordWithTimeOut(s,timeOut)
   
   TSTART = tic;
   
   to  = max([1,min([floor(timeOut),127])]);
   A   = [252;to;170];
   fwrite(s, uint8(A'),'uint8');

   pause(0.1);
   
   [DATA,~,~] = GetStreamedData(s);
   Ts=(2048/16e6)*2;
   t = Ts*(0:size(DATA,1)-1)';
   
   TSTOP = toc(TSTART);
   disp(['fin : ',num2str(TSTOP)]);
   y=DATA(:,2);
   
%    figure; 
%    plot(t,DATA(:,2)); hold
%    plot(t,detrend(DATA(:,2)),'r');

end

