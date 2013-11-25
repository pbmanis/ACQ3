function varargout = g(sfilename, varargin)
% g: get a stimulus file from disk
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     g [filename] gets and loads the sfile (and dfile if included) structures
%     from the selected file
%     If no filename is specified, a browser window is provided to select a file.

% 7/10/2000 - get a stimulus file from disk.
% Paul B. Manis   pmanis@med.unc.edu
% returns the loaded sfile structure in global variable SFILE.
% If you call without a filename on the command line, then
% this routine will use uigetfile to do the file access
% if there is an output argument, the data is returned there rather than in
% the global variable stim (9/11/2000 P. Manis)
% if there is an acq file stored in the stim file, then use it (makes AcqFile empty
% so when we save it the current acq structure is saved).
% 3/18/08 cleaned up
% pmanis
global STIM DFILE CONFIG IN_ACQ DISPCTL ONLINE
global DEVICE_ID
global Last_File

debugme = 0;

if nargin > 1
    noreload = varargin{1};
else
    noreload = 0
end;

QueMessage(' ', 1);
if(IN_ACQ)
    QueMessage('Already in acquisition: cannot change protocols', 1);
    return;
end;

if(nargout > 0)
    for i = 1:nargout
        varargout{i} = []; % initialize the outputs if present
    end;
end;
% load a protocol from the disk
fullstmpath = slash4OS([append_backslash(CONFIG.BasePath.v) CONFIG.StmPath.v]);
if(exist(fullstmpath, 'dir') == 7)
    wd = cd(fullstmpath);
else
    QueMessage(sprintf('g: Configuration StimPath %s invalid', fullstmpath), 1);
    return;
end;

if(nargin == 0)
    [stimname, stimpath] = uigetfile('*.mat','Load Stimulus File');
    if(stimname == 0)
        cd(wd);
        return;
    end;
    sfilename=fullfile(stimpath, stimname);
end;
if strcmp(sfilename, '-l') && ~isempty(Last_File)
    sfilename = Last_File;
end;
sfilename=unblank(sfilename);
[~, ~, ext] = fileparts(sfilename); % if filename still missing extension, add the default
if(isempty(ext))
    sfilename = [sfilename '.mat'];
end;
fid = fopen(sfilename, 'r');
if(fid == -1)
    QueMessage(sprintf('File %s not found? ', sfilename), 1);
    cd(wd);
    return;
end;
fclose(fid);
if noreload == 0
    Last_File = sfilename;
end;
a = load(sfilename);
sf=a.STIM;
x = fieldnames(a);
if(debugme)
    fprintf(1, 'Fieldnames in Stim file:\n');
    for i = 1:length(x)
        fprintf(1, '%s, ', char(x{i}));
    end;
    fprintf(1, '\n');
    fprintf(2, 'Name of protocol: %s\n', sf.Name.v);
end;

df=[];
onl=[];
displaycontrol = [];
if(any(strcmp('DFILE', x))) % indicates that an acquisition block was stored with the stimulus
    df = a.DFILE;
    sf.AcqFile.v = []; % force internal (although should not be necessary)
end;
if(any(strcmp('ONLINE', x)))
    onl = a.ONLINE;
end;
if(any(strcmp('DISPCTL', x)))
    displaycontrol = a.DISPCTL;
end;

cd(wd);
if(chkfile(sf))
    return;
end;
if(debugme)
    fprintf(1, 'Checking configuration and modes\n');
end;

if(nargout == 0) % no output - place it globally and DO things to it
    STIM = sf; % get it back (somehow, "deal" is needed to copy over the cell arrays as well).
    STIM.Name.v
    if(~isempty(unblank(STIM.Addchannel.v)))
        err = g2(STIM.Addchannel.v);
        if err
            return
        end;
    else
        if(~isempty(unblank(STIM.Superimpose.v)))
            err = g2(STIM.Superimpose.v);
            if err
                return
            end;
        end;
    end;
    if(~isempty(unblank(STIM.AcqFile.v)))
        ga(STIM.AcqFile.v);  % first get the acquisition file
    else
        if(any(strcmp('DFILE', x)))
            DFILE = df; % retrieve acq parameters from the internal file
            struct_edit('load', DFILE);
        end;
        struct_edit('edit', STIM, 1); % THIS ONE... then do the new stim file so its up last
        pv('-p'); % execute a preview with no calculation - just display it.
    end;
    if DEVICE_ID ~= -1
        try
            [t, ~, clist] = checkMC700Mode(); % read the multiclamp700
        catch Error %#ok<NASGU>

        end;
        dmode = DFILE.Data_Mode.v;
        for i = 1:length(t)
            if(t(i).mode == 'V')
                t(i).mode = 'VC';
            end;
            if(t(i).mode == 'I')
                t(i).mode = 'CC';
            end
        end;
        
        if(~strcmpi(dmode, t(1).mode))
            mc700bswitch(clist, {'0', '0'}); % go to 0 current mode if we are different
        end;
        AmpStatus = telegraph(); %#ok<NASGU> % we need to update the gains...
        set_hold;
        % now we can complete the switch - if we need to...
        if(~strcmpi(dmode, t(1).mode))
            mc700bswitch(clist, {dmode, dmode});
        end;
    end
    if(any(strcmp('ONLINE', x)))
        on_line('init', -1); % make sure we are cleared first....
        ONLINE = onl; % no struct_edit for online analysis - handled by a window....
        on_line('update'); % but update window if it is displayed.
    end;
    if(any(strcmp('DISPCTL', x)))
        DISPCTL = displaycontrol; % get display control variable
    end;
    QueMessage(sprintf('g: Stim Params loaded from %s', sfilename));
else % an output - ? just return the structure in the designated argument
    varargout(1) = {a.STIM};
    if(nargout == 2 && any(strcmp('DFILE', x)))
        if(~isempty(a.DFILE))
            varargout(2) = {a.DFILE};
        else
            varargout(2) = [];
        end;
    end;
    QueMessage(sprintf('Stim Params returned from %s', sfilename));
end;
return;
