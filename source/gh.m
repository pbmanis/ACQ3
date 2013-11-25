function [varargout] = gh(cname)
% gh: get hardware configuration file from disk
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     gh [filename] <nodisplay> gets a hardware configuration file from disk
%     If no filename is specified, a browser window is provided to select a file.

% 4/15/2008 - get a hardware configuration file from disk.
% Paul B. Manis   pmanis@med.unc.edu
% There is a single hardware configuration file for each rig.
% the file has the extension .hdw, and contains the following:
% 
% // Template for the hardware files (HARDWARE)
% // Modify this and save with the name rigN.hdw filename, where N is a number. 
% // The hardware onfiguration is loaded at startup. There should only be
% ONE hdw file in the main directory.
% // These parameters can be in any order; they are used to build the
% structure
% % This is the structure:

% [HARDWARE] // define us as a "hardware" structure.
% 
% title = "RigN Hardware"
% 
% hardware = "rign.hdw" // this is the filename for the configuration
% // it should be the  name of THIS FILE.
% 
% // the following are in the structure, but are actually filled by 
% // the program when it starts from the daqhwinfo call.
% // 
% NAcqBoards = 1  // number of acquisition boards (currently always 1)
% Boards = "NI6052E" // we get capabilities from the boards in the system
% Channels = 16 //
% MaxRate = 333000 // samples per second per channel sampled
% 
% // next section defines the amplifiers in the system
% Namps = 1
% [Amp1]
% Amplifier = "multiclamp"
% Amp1 = [3 5] // which a/d port for primary/secondary channels first amp?
% Amp2 = [5 7] // which a/d port for primary/secondary channels second amp?
% TelegraphChannels = 0 // we don't have to define this since telegraph is handled differently.
% VCCapable = 1 // we can do both voltage and current clamp
% CCCapable = 1
% // if we have a secondary amplifier connected, it would go here like
% this:
% // [Amp2]
% //Amplifier = "axopatch"
% //PrimaryChan1 = 0  // which a/d port for primary output 1?
% //SecondaryChan1 = 1 // which a/d input for ssecondary output?
% // VCCapable = 1 // we can do both current and voltage clamp
% // CCCapable = 1
% //TelegraphChannels = [13 14 15] // telegraph channels for axopatch 
% or:
% // [Amp3]
% //Amplifier = "axoprobe"
% //PrimaryChan1 = 0  // which a/d port for primary output 1?
% //SecondaryChan1 = 1 // which a/d input for ssecondary output?
% // VCCapable = 0
% // CCCapable = 1
% //TelegraphChannels = -1 //There are no telegraph channels, use fixed definitions 
%
% // DO NOT CHANGE THE FOLLOWING DEFINITIONS:
% [multiclamp] // define sensor ranges for the multiclamp
% all units ranges are defined for a gain of 1
% SensorRange = [10 10] // primary and secondary outputs (either amp)
% UnitsRangeCC = [1000 20] // at max sensor output, what is value at input to
% UnitsCC = "mV pA" //amp in current clamp?
% UnitsRangeVC = [20 1000] // at max sensor output
% UnitsVC = "nA mV"
% OutputRange = 10
% OutputUnitsVC = "mV"
% OutputUnitsCC = "pA"
% OutputUnitsRangeVC = [4000 20000] // pA/10V
%
% [axopatch] // define ranges for axopatch series
% SensorRange = [10 10]
% UnitsRangeVC = [20 1000]
% UnitsRangeCC = [1000 20]
% UnitsCC = "mV pA"
% UnitsVC = "pA mV"
%
% [axoprobe] // define ranges for axopatch series
% SensorRange = [10 10]
% UnitsRangeVC = [20 1000] // not used
% UnitsRangeCC = [1000 20]
% UnitsCC = "mV pA"
% UnitsVC = "pA mV" // not used
%

global BASEPATH HARDWARE

% load a protocol from the disk

% definitions
SGL = 0; %#ok<NASGU>
MULT = 1; %#ok<NASGU>

% edit_dis = 1;
% if(nargin == 2)
%     edit_dis = 0; % turn it off.
% end;
if(nargin == 0)
    askfile = 1;
end;
if(nargin == 1 && strcmp(cname, 'find'))
   c = dir('*.hdw');
   if(length(c) > 1)
       % let user choose
       askfile = 1;
   else
       cname = c.name;
       askfile = 0;
   end;
end;

if(askfile)
        [cname, cpath] = uigetfile('*.hdw','Load Hardware Configuration File');
    if(cname == 0)
        return;
    end;
    cname=fullfile(cpath, cname);
end;

[path file ext] = fileparts(cname); % if filename still missing extension, add the default
if(isempty(ext))
    cname = [cname '.hdw'];
end;
cname2 = cname;
if(isempty(path))
    cname2 = slash4OS([BASEPATH cname2]);
end;
fid = fopen(cname2, 'r');
if(fid == -1)
    QueMessage(sprintf('Hardware Configuration File %s not found? ', cname2), 1);
    return;
end;
fclose(fid);
HARDWARE = scriptread(cname2); % read from a script

% show_hwconfiguration;


fprintf(2, '     acq3: Hardware Configuration loaded from %s\n', cname);
if(nargout > 0)
    varargout{1} = HARDWARE;
end;
return;
