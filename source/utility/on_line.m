function on_line(cmd, win)
%
% on_line: parse the on-line callbacks.
% most of the callbacks refer to changing different parameters.
% The global structure is updated when the callback is used
% The routine ola_analysis uses the ONLINE structure to control
% the analysis.
% Routine for use in ACQ program

% Paul B. Manis, Ph.D.
% 2001-2002
% Univ. of North Carolina at Chapel Hill
% pmanis@med.unc.edu
%
% 4/2004 - additional analyses 
% use ModeY to determine the plot type (e.g., now include histograms)
%

global ONLINE ONLINE_DATA ZTIME ONLINE_NAMES


switch(cmd) % what is the command?
case 'init' % build window; create structure; populate window from structure.
   for i = 1:2
      ONLINE.Enable{i} = 1; % all are enabled.
      ONLINE.AutoReset{i} = 1; % normal mode is automatic reset...
      ONLINE.ModeY{i} = 1; % analysis measure
      ONLINE.ModeX{i} = 1;
      ONLINE.ChannelX{i} = 1;
      ONLINE.ChannelY{i} = 2;
      ONLINE.T1X{i} = 0;
      ONLINE.T1Y{i} = 0;
      ONLINE.T2X{i} = 5;
      ONLINE.T2Y{i} = 5;
      ONLINE.Threshold{i} = 0;
      ONLINE.ThreshSlope{i} = 1; % select positive slope
      ONLINE.SpecFunc{i} = 1; % select no special function
      ONLINE.x{i} = [0 100]; % x size
      ONLINE.y{i} = [-5 5]; % y size
      ONLINE.PointMode{i} = 1; % 1 for lines, 2 for points, 3 for histograms, 4 for rasters
   end;
   
   
   if(win == 0) % build display if win is set to 0
      on_line('up');
   end;
   on_line('update', 0);
   
case 'reset' % do the reset according to the auto reset flags.
   % do any initializations here in case window is not up.
   ONLINE = on_line_field_check(ONLINE); % make sure all fields exist and are at least initialized.
   for win = 1:2
      if(ONLINE.AutoReset{win} == 1)
         ONLINE_DATA.dx{win} = []; % be sure data arrays are cleard when we do the "update"
         ONLINE_DATA.dy{win} = [];
         ZTIME(win,:) = clock; % also restart the ZTIME clock associated with the window........
      end;
   end;
   
case 'up'
   % check to see if we're already up? if not, bring it up.
   h = findobj('tag', 'Acq_OnlineWindow');
   if(isempty(h))
      open('olafig.fig');
      %olafig3;
      h = findobj('tag', 'Acq_OnlineWindow');
   end;
   figure(h); % make it top
   % build the drop down lists for the popup menus for special functions.
   % we do this here because it is easier to maintain than modifying both menus with
   % GUIDE
   for i = 1:2
      hm = findtag('ola_SpecFunc_%d', i);
      set(hm, 'String', 'None|Y/X|(Y-Y0)/X|Y-X|Y+X|Rin-P2|Rin-P3|Rin-P4');   
      set(hm, 'Value', 1); % pick the none initially
   end;
   on_line('update', 0); % update the window with our data...
   hm = findtag('ola_ModeX_%d', 1); % get the list of names.
   ONLINE_NAMES = get(hm, 'String');
   
case 'enable'
   hm = findtag('ola_Enable%d', win);
   ONLINE.Enable{win} = get(hm, 'Value');
   
case 'autoreset'
   hm = findtag('ola_AutoReset_%d', win);
   ONLINE.AutoReset{win} = get(hm, 'Value');
   
case 'modex'
   hm = findtag('ola_ModeX_%d', win);
   ONLINE.ModeX{win} = get(hm, 'Value');
   setmodes(ONLINE, win);
   
case 'modey'
   hm = findtag('ola_ModeY_%d', win);
   ONLINE.ModeY{win} = get(hm, 'Value');
   setmodes(ONLINE, win);
   ONLINE.ModeY{win};
   
case 'channelx'
   hm = findtag('ola_Channelx_%d', win);
   ONLINE.ChannelX{win} = get(hm, 'Value');
   
case 'channely'
   hm = findtag('ola_Channely_%d', win);
   ONLINE.ChannelY{win} = get(hm, 'Value');
   
case 't1x'
   hm = findtag('ola_T1x_%d', win);
   ONLINE.T1X{win} = str2num(get(hm, 'String'));
   
case 't2x'
   hm = findtag('ola_T2x_%d', win);
   ONLINE.T2X{win} = str2num(get(hm, 'String'));
   
case 't1y'
   hm = findtag('ola_T1y_%d', win);
   ONLINE.T1Y{win} = str2num(get(hm, 'String'));
   
case 't2y'
   hm = findtag('ola_T2y_%d', win);
   ONLINE.T2Y{win} = str2num(get(hm, 'String'));
   
case 'threshold'
   hm = findtag('ola_Threshold_%d', win);
   ONLINE.Threshold{win} = str2num(get(hm, 'String'));
   
case 'threshslope'
   hm = findtag('ola_ThreshSlope_%d', win);
   ONLINE.ThreshSlope{win} = get(hm, 'Value');
   
case 'specfunc'
   hm = findtag('ola_SpecFunc_%d', win);
   ONLINE.SpecFunc{win} = get(hm, 'Value');
   
case 'pointmode'
   hm = findtag('ola_PointMode_%d', win);
   ONLINE.PointMode{win} = get(hm, 'Value');
   
case 'update' % load with the current values from the ONLINE structure.
   h = findobj('Tag', 'Acq_OnlineWindow');
   if(~isempty(h))
      ONLINE = on_line_field_check(ONLINE);
      for win = 1:2
         hm = findtag('ola_Enable%d', win);
         v = get(hm, 'Value');
         set(hm, 'Value', ONLINE.Enable{win});
         
         hm = findtag('ola_ModeX_%d', win);
         set(hm, 'Value', ONLINE.ModeX{win});
         
         hm = findtag('ola_ModeY_%d', win);
         set(hm, 'Value', ONLINE.ModeY{win});
         
         hm = findtag('ola_Channelx_%d', win);
         set(hm, 'Value', ONLINE.ChannelX{win});
         
         hm = findtag('ola_Channely_%d', win);
         set(hm, 'Value', ONLINE.ChannelY{win});
         
         hm = findtag('ola_T1x_%d', win);
         set(hm, 'Value', ONLINE.T1X{win});
         set(hm, 'String', num2str(ONLINE.T1X{win}));
         
         hm = findtag('ola_T1y_%d', win);
         set(hm, 'Value', ONLINE.T1Y{win});
         set(hm, 'String', num2str(ONLINE.T1Y{win}));
         
         hm = findtag('ola_T2x_%d', win);
         set(hm, 'Value', ONLINE.T2X{win});
         set(hm, 'String', num2str(ONLINE.T2X{win}));
         
         hm = findtag('ola_T2y_%d', win);
         set(hm, 'Value', ONLINE.T2Y{win});
         set(hm, 'String', num2str(ONLINE.T2Y{win}));
         
         hm = findtag('ola_Threshold_%d', win);
         set(hm, 'Value', ONLINE.Threshold{win});
         set(hm, 'String', num2str(ONLINE.Threshold{win}));
         
         hm = findtag('ola_ThreshSlope_%d', win);
         set(hm, 'Value', ONLINE.ThreshSlope{win});
         
         hm = findtag('ola_AutoReset_%d', win);
         set(hm, 'Value', ONLINE.AutoReset{win});
         
         hm = findtag('ola_SpecFunc_%d', win);
         if(length(ONLINE.SpecFunc) == 1)
             ONLINE.SpecFunc{2} = 0;
         end;
         set(hm, 'Value', ONLINE.SpecFunc{win});
         
%          	hm = findtag('ola_PointMode_%d', win);
%          if(length(ONLINE.PointMode) == 1)
%              ONLINE.PointMode{2} = 0;
%          end;
%           set(hm, 'Value', ONLINE.PointMode{win});
         
      end;
   end;
   
   
case 'close'
   h = findobj('Tag', 'Acq_OnlineWindow');
   if(~isempty(h))
      close(h);
   end;
otherwise
end;
if(nargin < 2)
   win = [];
end;
setmodes(ONLINE, win);
return;

% always check the mode windows and make sure they are correct (enable/disable)
function setmodes(ONLINE, win)
if(any(win < 1))
   return;
end;
h = findobj('Tag', 'Acq_OnlineWindow');
if(isempty(h))
   return;
end;
if(isempty(win))
   win = [1,2];
end;
for i = win
   if(ONLINE.ModeX{i} == 5)
      hm = findtag('ola_T1x_%d', i);
      set(hm, 'Enable', 'off');
      hm = findtag('ola_T2x_%d', i);
      set(hm, 'Enable', 'off');
   else
      hm = findtag('ola_T1x_%d', i);
      set(hm, 'Enable', 'on');
      hm = findtag('ola_T2x_%d', i);
      set(hm, 'Enable', 'on');
   end;      
   
   
   if(ONLINE.ModeY{i} == 5) % when we select "time", the values in t1 and t2 are not relevant
      hm = findtag('ola_T1y_%d', i);
      set(hm, 'Enable', 'off');
      hm = findtag('ola_T2y_%d', i);
      set(hm, 'Enable', 'off');
   else
      hm = findtag('ola_T1y_%d', i);
      set(hm, 'Enable', 'on');
      hm = findtag('ola_T2y_%d', i);
      set(hm, 'Enable', 'on');
   end;      
end;
return;


function [handle] = findtag(name, n)
tagname = sprintf(name, n);
handle = findobj('Tag', tagname);
if(isempty(handle)) % stop program.....
   error(sprintf('Control tag <%s> not found? ', tagname));
end;


function [out] = on_line_field_check(ONLINE)
% Don't forget to update this structure with any new fields that are added!


ONLINE = fieldupdate(ONLINE, 'Enable', [1,1]);
ONLINE = fieldupdate(ONLINE, 'AutoReset', [1,1]); % check for field existence and initialized if not present
ONLINE = fieldupdate(ONLINE, 'ModeX', [1, 1]);
ONLINE = fieldupdate(ONLINE, 'ModeY', [1, 1]);
ONLINE = fieldupdate(ONLINE, 'ChannelX', [1, 1]);
ONLINE = fieldupdate(ONLINE, 'ChannelY', [1, 1]);
ONLINE = fieldupdate(ONLINE, 'T1X', [0, 0]);
ONLINE = fieldupdate(ONLINE, 'T1Y', [0, 0]);
ONLINE = fieldupdate(ONLINE, 'T2X', [0, 5]);
ONLINE = fieldupdate(ONLINE, 'T2Y', [0, 5]);
ONLINE = fieldupdate(ONLINE, 'Threshold', [0, 0]);
ONLINE = fieldupdate(ONLINE, 'ThreshSlope', [1, 1]);
ONLINE = fieldupdate(ONLINE, 'SpecFunc', [1, 1]);
ONLINE = fieldupdate(ONLINE, 'x', [0, 100]);
ONLINE = fieldupdate(ONLINE, 'y', [-5, 5]);
ONLINE = fieldupdate(ONLINE, 'PointMode', [1, 1]);

out = ONLINE;
return;

function [out] = fieldupdate(stru, fld, val)
out = stru;
if(~isfield(out, fld))
   out = setfield(out, fld, {1}, {val(1)});
   out = setfield(out, fld, {2}, {val(2)});
end;
return;
