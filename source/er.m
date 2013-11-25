function er()
% er:  erase the data display windows.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

%     No parameters.e

% just call and reset the plot area
%
global DFILE ONLINE

data=[];

% *** Initialize the display area
acq_plot_data(-1, 1, ONLINE, data, 0, DFILE);  % this will clear the acq_plot (-1)

