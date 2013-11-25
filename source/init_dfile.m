function [dfile] = init_dfile()
%
% initialized the dfile structure
%
% initialize dfile - any arguments that are in dfile must be defined here....
RL=zeros(16,1);
dfile.filename='';
dfile.fullfile='';
dfile.path='';
dfile.ext='';
dfile.records_in_file = 0;
dfile.nr_points=0;
dfile.comment=' ';
dfile.mode=-1;
dfile.dmode = 'CC'; % default data collection mode if not otherwise defined...
dfile.rate = zeros(length(RL),1); % separate for every record!
dfile.ftime=0;
dfile.record=0;
dfile.nr_channel=0;
dfile.junctionpot = 0;
dfile.vgain=1;
dfile.wgain=1;
dfile.igain=1;
dfile.gain=zeros(length(RL),8);
dfile.low_pass=zeros(length(RL),8);
dfile.slow=zeros(length(RL),1);
dfile.ztime=zeros(length(RL),1);
dfile.refvg=1;
dfile.refig=1;
dfile.refwg=1;
dfile.frec=1;
dfile.lrec=1;
dfile.steps=0;

return;
