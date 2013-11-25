function varargout = Gapfree(varargin)
% GAPFREE Application M-file for Gapfree.fig
%    FIG = GAPFREE launch Gapfree GUI.
%    GAPFREE('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 28-Apr-2004 12:37:46
% No longer a GUIDE program - 
% 2/4/02.
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
%
% This routine performs simple, single channel, "gapfree" data acquisition
% for a specified period of time at a specified sample rate.
% The incoming data is displayed as it is acquired (successful only if
% the rate is slow enough).
% 
% The routine is self-contained except for an external call to
% telegraph.m to read the telegraph outputs of the axopatch200
% No telegraph information is available for other sources.
% 
if nargin == 0  % LAUNCH GUI
   fig = findobj('tag', 'gapfree');
   if(isempty(fig))
      open('gapfree.fig');
   end;
   fig = findobj('tag', 'gapfree');
   % Use system color scheme for figure:
   set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
   
   % Generate a structure of handles to pass to callbacks, and store it. 
   handles = get(fig, 'children');
   set(fig, 'UserData', handles);
   
   if nargout > 0
      varargout{1} = fig;
   end
   
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
   
   try
      if (nargout)
         [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
      else
         feval(varargin{:}); % FEVAL switchyard
      end
   catch
      disp(lasterr);
   end
   
end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = Start_Callback(h, eventdata, handles, varargin)

hsr = findobj('tag', 'Gapfree_rate');
sampleRate = 1000000/str2num(get(hsr, 'string'));

hdur = findobj('tag', 'Gapfree_duration');
secs = str2num(get(hdur, 'string'));

hchan = findobj('tag', 'Gapfree_channel');
chanID = get(hchan, 'value'); % list is linear, just map it straight
%chanID

%fprintf(1, 'Starting\n');
[data, fs] = daqrecord(secs, sampleRate, chanID);
%fprintf(1, 'Finished\n');
%fprintf(1, 'Data length: %d,  at %7.2f kHz\n', length(data), fs);

% --------------------------------------------------------------------
function varargout = Stop_Callback(h, eventdata, handles, varargin)
global GAPFREE_AI
% GAPFREE_AI
if(~exist('GAPFREE_AI') | isempty(GAPFREE_AI))
   disp 'No Acq Object to stop'
   return;
end;
if(strcmp(GAPFREE_AI.Running, 'On'))
   stop(GAPFREE_AI)
   disp 'STOPPED'
   return;
end;




% --------------------------------------------------------------------
function varargout = ExitButton_Callback(h, eventdata, handles, varargin)
eventdata
handles
varargin
h=findobj('tag', 'GapFree');
close(h);
return;

% --------------------------------------------------------------------
function varargout = Gapfree_rate_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = Gapfree_duration_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = Channel_Callback(h, eventdata, handles, varargin)

hchan = findobj('tag', 'Gapfree_channel');
chanID = get(hchan, 'Value'); % list is linear, just map it straight

% just use daqrecord to get the data into the buffer. We try to keep up with peekdata.....
function [data, Fs] = daqrecord(varargin)
%DAQRECORD Record data from the specified adaptor.
%
%    [Y, FS] = DAQRECORD('ADAPTORNAME', ID, SECONDS) creates an analog input
%    object associated with adaptor, ADAPTORNAME, and device identification
%    ID.  Data is recorded from channel 1 for the specified number of seconds, 
%    SECONDS, and returned to Y.  The sample rate used is returned to FS.
%
%    [Y, FS] = DAQRECORD('ADAPTORNAME', ID, SECONDS, SAMPLERATE) records data 
%    for the specified number of seconds, SECONDS, at the specified sample
%    rate, SAMPLERATE.  If the specified sampling rate does not match one of 
%    the valid device values, then the data acquisition engine will choose 
%    the closest supported sampling rate that is greater than the specified
%    value. If a higher value does not exist, then an error is returned.
%
%    [Y, FS] = DAQRECORD('ADAPTORNAME', ID, SECONDS, SAMPLERATE, CHANID) records 
%    the data from the specified channels, CHANID.
%
%    If ADAPTORNAME and ID are not defined, the winsound adaptor and id 0 are
%    used.
%
%    [Y, FS] = DAQRECORD(SECONDS) records a monophonic sound for SECONDS
%    number of seconds at 8000 Hz.  
%
%    [Y, FS] = DAQRECORD(SECONDS, SAMPLERATE) records a sound at the specified
%    sampling rate. If the specified sampling rate does not match one of 
%    the valid device values, then the data acquisition engine will choose 
%    the closest supported sampling rate that is greater than the specified
%    value. If a higher value does not exist, then an error is returned.
%
%    [Y, FS] = DAQRECORD(SECONDS, SAMPLERATE, CHANID) records a sound at the 
%    specified sampling rate and with the specified channel ids, CHANID,
%   (either 1 or [1 2]);
%
%    Examples:
%       [y, Fs] = daqrecord('nidaq', 1, 10)
%       [y, Fs] = daqrecord(5, 22050)
%       [y, Fs] = daqrecord('winsound', 0, 5, 44100, [1 2])
%
%    See also DAQPLAY.
%

%    MP 11-16-98
%    Copyright (c) 1998-1999 by The MathWorks, Inc.
%    $Revision: 1.1 $  $Date: 1999/01/07 15:04:07 $

% modified for use here, P. Manis 2/3/02.

global GAPFREE_AI GAPFREE_CTR ACQ_FILENAME
global DFILE DISPLIM

% Initialize variables.
% check the available adaptors and use what's there.
if(~exist('daqregister')) % make sure toolbox and drivers are installed
   QueMessage('Unable to register DAQ drivers/toolbox', 1);
   return;
end;
testing = 0;

if(testing)
   hw = daqhwinfo;
   if(strmatch('nidaq', hw.InstalledAdaptors, 'exact'))
      adaptor = {'mwnidaq.dll'}; % preferred adaptor if available.
      chanID = 1;
   elseif strmatch('winsound', hw.InstalledAdaptors, 'exact')
      adaptor = {'mwwinsound.dll'};
      chanID = 0;
   else
      error('No valid adaptor found on this computer')
      return;
   end;
   
   olddaq = daqfind;
   if(~isempty(olddaq))
      for i = 1:length(olddaq)
         delete(olddaq{i});
      end;
   end;
   daqregister(adaptor);
else
   adaptor = 'nidaq';
end;

id = 1;
sampleRate = 8000;
filename = '';

hg = findobj('tag', 'GapFree_graph');


% Error if an input was not provided.
if nargin == 0
   error('SECONDS must be defined');
end

% Switch on the number of input arguments based on whether the
% first input is numeric (seconds) or is a string (adaptor).
if isnumeric(varargin{1})
   switch nargin
   case 1
      seconds = varargin{1};
   case 2
      [seconds,sampleRate] = deal(varargin{:});
   case 3
      [seconds,sampleRate,chanID] = deal(varargin{:});
   otherwise
      error('Too many input arguments.');
   end
elseif isstr(varargin{1})
   switch nargin
   case 1
      error('ID and SECONDS must be defined.');
   case 2
      error('SECONDS must be defined');
   case 3
      [adaptor, id, seconds] = deal(varargin{:});
   case 4
      [adaptor, id, seconds, sampleRate] = deal(varargin{:});
   case 5
      [adaptor, id, seconds, sampleRate,chanID] = deal(varargin{:});
   otherwise
      error('Too many input arguments.');
   end
elseif isa(varargin{1}, 'daqdevice')
   % Timer Action or Stop Action.
   obj = varargin{1};
   event = varargin{2};
   action = varargin{3};
   Fs = varargin{4};
   filename = varargin{5};
   switch action
   case 'getdata'
      localGetData(obj, event);
      return;
   end
else
   error('SECONDS must be numeric.');
end

% Error checking on the input arguments.
if ~isa(seconds, 'double')
   error('SECONDS must be a double.');
elseif ~isa(sampleRate, 'double')
   error('SAMPLERATE must be a double.');
elseif ~isa(chanID, 'double');
   error('NUMCHANNELS must be a double.');
elseif ~isstr(filename)
   error('FILENAME must be a string.');
end

% Create the winsound object.
if(strcmp(adaptor, 'nidaq'))
   GAPFREE_AI = analoginput(adaptor, id);
   chanID=chanID-1;
   ai_chans = addchannel(GAPFREE_AI, chanID);
   set(GAPFREE_AI, 'InputType', 'NonReferencedSingleEnded');
   set(GAPFREE_AI, 'DriveAISenseToGround', 'On');
else
   GAPFREE_AI = analoginput(adaptor);
   ai_chans = addchannel(GAPFREE_AI, 1);
   chp = propinfo(GAPFREE_AI);
   sr=chp.SampleRate;
   if((1000000/sampleRate) < sr.ConstraintValue(1) | ...
         (1000000/sampleRate) > sr.ConstraintValue(2))
      sampleRate = sr.DefaultValue;
   end;
   set(hg, 'YLim', chan.InputRange);
end;
%GAPFREE_AI
% capture the skip argument in the display (normally 1)
skip = 1;
hskip = findobj('tag', 'Gapfree_skip');
if(~isempty(hskip))
   skip = str2num(get(hskip, 'string'));
   if(skip < 1)
      skip = 1;
   elseif skip > 10
      skip = 10;
   end;
   set(hskip, 'string', sprintf('%d', skip)); % block values ...
end;


if(strcmp(adaptor, 'nidaq')) % in case of nidaq, read the telegraph
   AmpStatus = telegraph;
	stop(GAPFREE_AI); % if it happens to be running
	delete(GAPFREE_AI.Channel);
   % read the external gain...
   hgt = findobj('tag', 'gapfree_gain');
   hgv = get(hgt, 'value');
   hgs = cellstr(get(hgt, 'string'));
   ext_gain = str2num(char(hgs(hgv)));
   vg=ones(1, length(ai_chans));
   vg(1)=AmpStatus.Gain*ext_gain;
   switch AmpStatus.Mode
      case 'I'
      ai_chans = addchannel(GAPFREE_AI, DFILE.Channels.v(1));
   case 'V'
      ai_chans = addchannel(GAPFREE_AI, DFILE.Channels.v(2));
   otherwise
      QueMessage('Amp Mode not recognized', 1);
      return;
   end;
   
   hchan = findobj('tag', 'Gapfree_channel');
   rchan = get(ai_chans(1), 'hwChannel')+1;
   set(hchan, 'value', rchan); % list is linear, just map it straight
   range = [-DFILE.AD_Range.v DFILE.AD_Range.v];
   DFILE.Sensor_Range.v;
   DFILE.AD_Range.v;
   for j = 1:length(ai_chans)
      if(AmpStatus.Mode == 'V')
          k = 2;
      else
          k = 1;
      end;
      set(ai_chans(j), 'InputRange', [-DFILE.AD_Range.v(k) DFILE.AD_Range.v(k)]);
      sr = (DFILE.AD_Range.v(k)/(DFILE.Sensor_Range.v(k)/vg(j)));
      set(ai_chans(j), 'SensorRange', [-sr sr]);
      %  set(ai_chans(j), 'UnitsRange', ur(j,:));
   end;
      title('');
   if(AmpStatus.Mode == 'I')
      set(hg, 'YLim', DISPLIM.V);
      ylabel('mV');
      set(ai_chans(1), 'Units', 'mV');
   else
      set(hg, 'YLim', DISPLIM.I);
      ylabel('pA');
	   set(ai_chans(1), 'Units', 'pA');
   end;
   
end;

% Set the sampleRate and capture the value it was actually set to.

Fs = setverify(GAPFREE_AI, 'SampleRate', sampleRate);

% Set the object to acquire for the specified amount of time.

set(GAPFREE_AI, 'SamplesPerTrigger', Fs*seconds);
chp = propinfo(GAPFREE_AI);

if(~isempty(ACQ_FILENAME))
   gfname = sprintf('%s_%03d.abf', ACQ_FILENAME, GAPFREE_CTR);
else
   gfname = 'c:\data\gapfree.abf';
end;
hfn = findobj('tag', 'Gapfree_filename');
if(ishandle(hfn))
   set(hfn, 'string', gfname);
end;
note(sprintf('%s   Gapfree   %s', datestr(now), gfname));
% Start the object; while the object is running try to update the window display.  
%ai
blocksize=2048;

n=0;
set(hg, 'XLim', [0,seconds]);
cla(hg);
grid on;
line([0 0.001], [0 0], 'parent', hg, 'EraseMode', 'normal', 'color', 'blue');
ts=([0:blocksize-1]./(sampleRate))';
start(GAPFREE_AI);
while ~isempty(GAPFREE_AI) && strcmp(GAPFREE_AI.Running, 'On');
   x=get(GAPFREE_AI, 'SamplesAcquired');
   if(x > (n+blocksize-1))
      d = peekdata(GAPFREE_AI, blocksize);    
      n = n + length(d);
      t0=(x-blocksize)/(sampleRate);
      tp = ts + t0;
      %         if(n < 3*blocksize)
      %            fprintf('t0: %12.6f ts: %8.6f %8.6f %d %d\n', t0, min(tp), max(tp), length(ts), length(d));
      %         end;
      line(tp(1:skip:end), d(1:skip:end), 'parent', hg, 'color', 'r', 'EraseMode', 'none');
      drawnow;
   end;
end;

if(isempty(GAPFREE_AI))
   data= []; % no data to return - we stopped.
   return;
end;
% Get the data.
nsamp = get(GAPFREE_AI, 'SamplesAvailable');
data = getdata(GAPFREE_AI, nsamp);

% Delete the object.
delete(GAPFREE_AI);

df = init_dfile;
df.record = 1;
%df.comment = 'testing 123';
df.nr_points = nsamp;
df.rate = (1000000/sampleRate)*ones(1,16);
hg = findobj('tag', 'gapfree_mode');
hgv = get(hg, 'value');
switch(hgv)
case 1
   df.mode = 'CC';
case 2
   df.mode = 'VC';
otherwise
   df.mode = 'CC';
end;
df.records_in_file = 1;
df.nr_channel = 1;
df.vgain=1;

write_pc6_mat(gfname, df, data);
GAPFREE_CTR = GAPFREE_CTR + 1; % only update after successful write...
note(sprintf('%s   Gapfree acquisition complete', datestr(now)));
return;
