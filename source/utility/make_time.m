function [time] = make_time(df)
nch = length(df.Channels.v);
sr = df.Sample_Rate.v;
time=0:sr*nch:(df.Points.v-1)*sr*nch;
time = time/1000;
return
