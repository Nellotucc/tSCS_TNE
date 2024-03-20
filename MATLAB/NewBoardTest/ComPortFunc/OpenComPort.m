if exist('s')
    fclose(s);
    delete(s);
    clear s;
end

if exist('s1')
    fclose(s1);
    delete(s1);
    clear s1;
end

if exist('s2')
    fclose(s2);
    delete(s2);
    clear s2;
end


if(iscell(ComPort))
   delete(instrfind);
   s1 = serial(ComPort{1});
   set(s1,'BaudRate', Baudrate, ...
         'Timeout',  1, ...
         'InputBufferSize', 100000);
   fopen(s1);
   flushinput(s1);
   if(numel(ComPort)>1)
      s2 = serial(ComPort{2});
      set(s1,'BaudRate', Baudrate, ...
            'Timeout',  1, ...
            'InputBufferSize', 10000);
      fopen(s2);
      flushinput(s2);
   end
else
   delete(instrfind);
   s = serial(ComPort);
   set(s,'BaudRate', Baudrate, ...
         'Timeout',  1, ...
         'InputBufferSize', 10000);
   fopen(s);
   flushinput(s);
end
