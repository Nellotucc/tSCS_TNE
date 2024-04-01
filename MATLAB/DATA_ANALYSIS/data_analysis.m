directories = {
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow1/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow2/', 
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/yellow3/',
    '/Users/riccardocarpineto/Documents/TNE_MA2/tSCS_TNE/MATLAB/DATA/Kelly/small_electrode/black/'
};
current_i = 20;
current_f = 65;
num_repetitions = 2;
bool_plot = true;

x = best_electrode_finder(directories,current_i,current_f,50,num_repetitions,'conventional',bool_plot);