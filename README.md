# tSCS_TNE

'real_time_processing_main' is the main file where you link to datalink, link to stimulator, set parameters and record.

first parameter *real_time_channel* : for now only channel 0 (channel 1 on datalink) is taken in realtime. If you need to change this, change the variable real_time_channel to another channel. DONT FORGET TO CHANGE ALSO IN THE SAVING SECTION AT THE END.
Ex : real_time_channel = selectedChannels{1}; and you save the emg for all the signal for the others at the end. If you change to real_time_channel = selectedChannels{2}; make sure you adapt the rest accordingly (name of data as well as selected channels)

the second parameter to change is *current_0* which determines the current at which you start the stimulation.

thirdly tune sync params like the *pause(0.920)* as well as updated_t0 for better synchronization.