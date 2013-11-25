function chdis(nch, arg1, arg2)
% chdis: set voltage axes display limits for arbitrary channel
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%    chdis n min max sets V display min and max for channel n
%    n must be > 2 (use vdis, idis for low channels)

%
% 10/19/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
global DISPCTL
if(isempty(DISPCTL))
    initdispctl;
end;
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
switch nargin
case 0
% mode called from buttons - 
    hchan = findobj('tag', 'acq_d_select');
    if(isempty(hchan))
        return;
    end;
    hpos = findobj('tag', 'acq_d_position');
    if(isempty(hpos))
        return;
    end;
    hgain = findobj('tag', 'acq_d_gain');
    if(isempty(hgain))
        return;
    end;
    vchan = get(hchan, 'value');
    nch = vchan;
    
    pv = get(hpos, 'Value');
    spchan = get(hpos, 'String');
    if(spchan > 1)
        pos = str2double(spchan(pv,:));
    end;
    
    gv = get(hgain, 'Value');
    sfscale = get(hgain, 'String');
    fullscale = str2double(sfscale(gv,:));
    
        arg1 = fullscale*(100-pos)/100; % figure out the top of the data
    arg2 = arg1 - fullscale;  % then subtract the full scale
    

case 2
   nch = number_arg(nch);
   arg1 = number_arg(arg1);
   arg2 = -arg1; % use negative and make display symmetrical
case 1
   nch = number_arg(nch);
   
   if(nch < 1 || nch > 16)
   	QueMessage('chdis: channel must be in range 1-16', 1);   
      return;
   end;
   [x] = inputdlg({'Max', 'Min'}, sprintf('Display Limits CH%d', nch), [2 20], ...
      {sprintf('%d', DISPCTL.ymax(nch)); sprintf('%d', DISPCTL.ymin(nch))}, options); % make an input dialog
   arg1 = number_arg(x{1});
   arg2 = number_arg(x{2});
otherwise
   if(nargin > 3)
   	QueMessage('chdis: requires only three arguments (ch, min, max) for display limits', 1);
	   return;
   end;
end;
nch = number_arg(nch);
arg1 = number_arg(arg1);
arg2 = number_arg(arg2);


V = sort([arg1 arg2]);
DISPCTL.ymax(nch) = V(2);
DISPCTL.ymin(nch) = V(1);

hc=[0 0];

hfound = findobj('Tag', 'Acq_MW1');
if(isempty(hfound))
   QueMessage('chdis: UserData area of display frame is empty?');
   return;
else
    hc(1) = hfound;
end;

hfound = findobj('Tag', 'Acq_MW2');
if(isempty(hfound))
   QueMessage('chdis: UserData area of display frame is empty?');
   return;
else
    hc(2) = hfound;
end;


if(nch <= length(hc)) % if we're in the display list...
   axes(hc(nch)); % access the top axis
   if(diff([DISPCTL.ymax(nch) DISPCTL.ymin(nch)]) ~= 0)
      set(gca, 'YLim', [DISPCTL.ymin(nch) DISPCTL.ymax(nch)]); % set new limits
   else
      ylim(gca, 'auto');
   end;
   
else % replot the screen with the new display... ?
    acq_plot_data(1);
end;
return
