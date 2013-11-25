function acq_calculate()
%
% recalculate some parameters after each stimulus update.
%
global DFILE

% fprintf(1, 'Calling acq_calculate\n');

ca = configure_acquisition; % get acquisition configuration - interaction between hardware and the DFILE acquisition settings

DFILE.Channels.v = [ca.chan];
update_current_field('DFILE', 'DFILE.Channels', DFILE.Channels.f);
ra = number_arg(DFILE.Sample_Rate.v);
pts = number_arg(DFILE.Points.v);
nch = length([ca.chan]);
DFILE.TraceDur.v = ra*pts*nch/1000; % convert to msec
update_current_field('DFILE', 'DFILE.TraceDur', DFILE.TraceDur.f);
DFILE.Actual_Rate.v = 1000000/(ra*nch);
update_current_field('DFILE', 'DFILE.Actual_Rate', DFILE.Actual_Rate.f);

return;

