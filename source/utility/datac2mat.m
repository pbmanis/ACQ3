function [dfile, data, err]=datac2mat(filename, RL);
%function [nr_points,comment,channels,rate,gain,low_pass,ztime,data]=datac2mat(filename,first_rec,last_rec);
%reads datac files
%reads end-start+1 records [start,end] from the DATAC-file <filename>
%pts=number of points in record
%cha=number of channels
%com=comment
%rate[records]=sampling rate
%gain[records,8]=gain for each of 8 channels in each record
%low[records,8]=lowpass filter setting for each channel of 8 in each record
%zti[records]=cell timer
%data[records,pts*cha]=data array, channels are sequentially organized
%		[1:pts]			=channel1 (i.e. voltage command)
%		[pts+1:2*pts]	=channel2 (i.e. current)
%
%
% original C code by PK now as MATLAB code
%
% 4/30/99 P. Manis. Modified to handle modes 0 and 1 also, as well as get the timing information.
% now we should be able to read legacy files, and files with just one channel in modes 2 and 3
%
data=[];

err=1;
endian='ieee-le'; %data from little endian (i.e. PC's) => integers flipped, floats in ieee

dfile = init_dfile; % create the current version of the dfile structure.

data=zeros(length(RL),16); % just initialize to make rest of program happy - adjust later when we know

if(~isempty(RL))
    QueMessage(sprintf('Opening %s', filename), 1);
end;

ex = exist(filename);
if(ex ~= 2)
   QueMessage(sprintf('datac2mat: File %s not found', filename), 1);
   return;
end;

% decide what kind of file we are reading
[p, f, e] = fileparts(filename);
if(strmatch(e, '.mat', 'exact')) % if its a matlab file, use different routine to parse through here
   [dfile, data, err] = read_acq_mat(filename, RL);
   return;
end;
if(strmatch(e, '.abf', 'exact')) % if its a matlab file, use different routine to parse through here
   [dfile, data, err] = read_pc6_mat(filename, RL);
   return;
end;

% otherwise, we proceed normally.

%filename=lower(filename);
fid=fopen(filename,'r',endian);
if fid ==-1
   QueMessage(sprintf('datac2mat: Unable to open file: %s ',filename), 1);
   return
end
% before reading, check the length of the file
fseek(fid,0,'eof');
flen=ftell(fid);
if(flen<129)  % must have at least header and one record
   fclose(fid);
   QueMessage(sprintf('datac2mat: Empty file: %s ',filename), 1);
   err=2;
   return;
end
%read file header
fseek(fid, 0, 'bof');

[path, fname, ext, ver] = fileparts(filename);
dfile.fullfile = filename;
dfile.filename = fname;
dfile.path = path;
dfile.ext = ext;
dfile.nr_points = fread(fid,1,'int16');

n = fread(fid,27,'char');
n = fread(fid,99,'int8');
ns=n';
nn=length(ns);
%clean up the comment: not beautiful, but quite functional
clean_n=zeros(1,nn);
for i=1:nn
   if(ns(i)<=0)
     break;
   end
   if(isletter(ns(i)) | isnumeric(ns(i)) | isspace(ns(i)))
      clean_n(i)=ns(i);
   else
      clean_n(i) = ' ';
   end
   i = i + 1;
end
dfile.comment=char(clean_n);

offset=128;
fseek(fid,offset,'bof');
dfile.mode=fread(fid,1,'char');
dfile.ftime = fread(fid,1,'char');
if(dfile.mode >= 2) 
   dfile.record = fread(fid,1,'int16'); %should be 1 for first record
   dfile.nr_channel = fread(fid,1,'int16');
else
   dfile.record = 1;
   dfile.nr_channel=dfile.mode+2; % mode 0 is 2 channels; mode 1 is 3 channels
   nbytes=dfile.nr_points*8;	% original form */
   nheader = 6;		% original header was 6 bytes long */
   ndbytes = nbytes - nheader;   
end
% info on the file that was just opened.
%disp(sprintf(['Successful open for file %s.%s\n   Mode:         %5d       ftime: %6d\n' ...
%	                                   '   First Record: %5d     Channel: %6d'], ...
%   dfile.filename, dfile.ext, dfile.mode, dfile.ftime, dfile.record, dfile.nr_channel))

% check the file length now
dfile.records_in_file=floor((flen-128)/(dfile.nr_points*dfile.nr_channel*2+256));
if(dfile.records_in_file == 0) 
   err=2;
   fclose(fid);
   return
end

if(isempty(RL)) % catch when we just read the header for information
   err = 0; % this is ok...
   return;
end

if (max(RL) > dfile.records_in_file)
   QueMessage(sprintf('Last record (%i) greater than length of file (%i recs in file)',max(RL),dfile.records_in_file));
   fclose(fid);
   return
end

block_head=0; % flag for block header reading ONLY.

if(max(RL) == 0) % special mode just to read ZTIME and other header information from WHOLE FILE
	RL=[1:dfile.records_in_file];
	block_head=1; % block header read
else
	data=zeros(length(RL),2*dfile.nr_points); % go ahead and allocate memory.
end;

%read data sets according to the records in the RL vector
dfile.frec=RL(1);
dfile.lrec=RL(length(RL));
MASK = hex2dec('FFF');
for i=1:length(RL)
   rec=RL(i); %i+first_rec-1;
   if(dfile.dmode >= 2)
      offset=128+(rec-1)*dfile.nr_points*2*dfile.nr_channel+(rec-1)*256; %jump to data start
   else
      offset=128+(rec-1)*ndbytes;
   end
   s=fseek(fid,offset,'bof');	   	%skip earlier records
   %read header
   mode=fread(fid,1,'char');
   dfile.ftime(i) = fread(fid,1,'char');
   if (dfile.mode < 2 )
      dfile.gain=zeros(length(RL),8)+1; % set the gains all to 1
      offset=128+(rec-1)*ndbytes+rec*nheader;  % position it correctly...
      s=fseek(fid,offset,-1);	%skip earlier records
	if(block_head==0) % read the data, not just the block header..
	      data_in=floor(fread(fid,ndbytes,'int16')); % access the data itself
      if(dfile.mode == 0)
         d1=data_in(1:dfile.nr_points*3); % reduce the array
         d2=reshape(d1, 3, dfile.nr_points); % extract the data itself
         data(i,1:dfile.nr_points) = max(d2(2,:),0); % numbers should be positive - sometimes buggy in hardware
         data(i,dfile.nr_points+1:2*dfile.nr_points) = max(d2(3,:),0);
         dfile.rate(i) = old_time(d2(1,:));
      else
         d1=data_in(1:dfile.nr_points*4);
         d2=reshape(d1, 4, dfile.nr_points);
         data(i,1:dfile.nr_points) = max(d2(2,:),0);
         data(i,dfile.nr_points+1:2*dfile.nr_points) = max(d2(3,:),0);
         data(i,2*dfile.nr_points+1:3*dfile.nr_points) = max(d2(4,:),0);
         dfile.rate(i) = old_time(d2(1,:));
      end
	end; % of block_header==0
	      
   else
      dfile.record(i) = fread(fid,1,'int16');
      dfile.channels(i) = fread(fid,1,'int16');
      dfile.rate(i)=fread(fid,1,'float32');
      dfile.gain(i,:)=fread(fid,8,'float32')';
      dfile.low_pass(i,:)=fread(fid,8,'float32')';
      dfile.slow=fread(fid,1,'int16');
      dfile.ztime(i)=fread(fid,1,'long');
      %read data
      offset=128+(rec-1)*dfile.nr_points*2*dfile.nr_channel+rec*256; %jump to data start
      
      s=fseek(fid,offset,-1);	%skip earlier records
      if(block_head==0) % we don't actually read the data...
	  	data_in=fread(fid,dfile.nr_channel*dfile.nr_points,'int16'); % access the data itself
	      skip=dfile.nr_channel; % set the skip counter
	      % read the first entry
	      data(i,1:dfile.nr_points)=data_in(1:skip:skip*dfile.nr_points)';	% dfile.nr_points - 1 ??? %voltage
	      if(skip > 1)
	         data(i,dfile.nr_points+1:2*dfile.nr_points)=data_in(2:skip:skip*dfile.nr_points)'; %current
	      end
	      if(skip > 2)
	         data(i,2*dfile.nr_points+1:3*dfile.nr_points)=data_in(3:skip:skip*dfile.nr_points)'; %wchannel...
	      end
    	end;  % of block_head == 0
   end 
end
if(length(RL) > 0)  % we sometimes override these with the ctl structure...
   dfile.refvgain=dfile.gain(1,1);
   dfile.refigain=dfile.gain(1,2);
   dfile.refwgain=dfile.gain(1,3);
end
clear d1;
clear d2;
clear data_in;
fclose(fid);
err = 0;

return 

function [rate] = old_time(tbuf)
% compute mean rate from the old timey (mode 0 and 1) modes.
%
CTE=65536;
FTIME = 0.00061;
dt = FTIME;
tdt = dt*10;
t = tbuf(1);
ta = dt * (CTE-t);
if(ta < -tdt)
   tx = tx + CTE;
   ta = dt * (tx-t);
end
rate = ta;
disp(sprintf('Rate: %12.5f', rate));

