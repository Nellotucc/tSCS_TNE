directories = {
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow1/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow2/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow3/',
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/black/'
};
directories = {
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/20march/yellow2/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/20march/black2/'
};
current_i = 25;
current_f = 50;
num_repetitions = 2;
bool_plot = true;
interpulse_duration = 100;

x = best_electrode_finder(directories,current_i,current_f,interpulse_duration,num_repetitions,'conventional',bool_plot);