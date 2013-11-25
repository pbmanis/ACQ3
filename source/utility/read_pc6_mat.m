function [dfile, data, err] = read_pc6_mat(filename, RL)
% read_pc6_mat: convert a pclamp version 1.5 file to a format that we can read in matlab.
%
% We use getpc6header to get the base information to populate dfile.
% We then use readepisode to actually access the data, according to RL
%
dfile = init_dfile;
err = 1;
data = [];
if(nargin  < 2 | nargin > 2)
   fprintf(1, 'read_acq_mat: requires exactly 2 arguments\n');
   return;
end;

[path, fname, ext, ver] = fileparts(filename);
dfile.fullfile = filename;
dfile.filename = fname;
dfile.path = path;
dfile.ext = ext;

fid = fopen(filename, 'r');
if(isempty(fid))
   return;
end;

pc6h = getpc6header(fid); % read the header

% now copy from the header into our datac structure
dfile.records_in_file = pc6h.lActualEpisodes;
dfile.nr_points = pc6h.lActualAcqLength;
dfile.comment = pc6h.sFileComment';
dfile.mode = 6; % corresponds to ABF file...
switch(pc6h.nExperimentType)
case 1
   dfile.dmode = 'VC';
case 2
   dfile.dmode = 'CC';
otherwise
   dfile.dmode='CC';
end;
dfile.rate = pc6h.fADCSampleInterval*ones(1,dfile.records_in_file);
if(~isempty(RL))
   dfile.record=1;
else
   dfile.record = 1;
end;


dfile.nr_channel=pc6h.nADCNumChannels;
dfile.vgain=pc6h.fInstrumentScaleFactor(1);
dfile.ztime(1) = pc6h.lFileStartTime;

if(~isempty(RL))
   for i = 1:length(RL)
      data=readepisode(fid, pc6h, RL(i));
   end;
end;
fclose(fid);
err = 0; % success!
return;

