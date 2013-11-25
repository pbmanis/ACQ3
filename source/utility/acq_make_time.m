function [time] = acq_make_time(df)
nch = length(df.Channels.v);
sr = df.Sample_Rate.v;
asr = sr*nch; % actual sample rate, per point
time=[0:asr:asr*(df.Points.v-1)];
time = time/1000;
%fprintf(1, 'time: %d\n', length(time));
return
