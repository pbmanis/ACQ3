function [outdata, tbase, out_rate, err, sfile] = SAM(varargin)
% sam_pulse: Method to generate pulse train waveforms with sinusoidal
% amplitude modulation.
% Usage
%     CAN BE called directly by the user

% PULSEGEN - create pulse train waveform
%
%    PULSEGEN produces a pulse train waveform pulse_out
%    specified by the parameters in the structure sfile.
%
%    The stimulus structure is generated by new.m.
%		The following parameters are required:
%   sfile.Npulses= number of pulses in the train
%   sfile.Delay= delay to first pulse
%   sfile.IPI= interpulse interval (one number)
%   sfile.Duration = duration list for pulses (compound pulses allowed at each interval)
%   sfile.Level= level list for pulses (compound levels corresponding to durations)
%   sfile.LevelFlag= 'absolute' or 'relative': levels after first are either absolute or relative
%   sfile.Scale= scale factor applied to output
%	 sfile.Offset = offset added to output (after scaling)
%   sfile.Sequence= sequence (operates as in steps - multiple seqeuences allowed)
%   sfile.SeqParList= parameters to sequence (apply according to entries in sequence)
%   sfile.SeqStepList= which step to be operated on by the sequence element if level or duration
%
%
% original by S.C. Molitor, 8/2000
% modified Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
% 9/1/2000   uses new record_parse and step generator
%
% Revised 4/10/2008 to use new methods.
% - call with no arguments tests the algorithm.
% - uses state matrix to drive sequencing.

% initialize output
outdata = {};
err = 0;
tbase = {};
out_rate = [];

if(nargin == 0) % test mode...
    sfile = new('SAM');
else
    sfile = varargin{1};
    if(isempty(sfile))
        QueMessage('SAM: No STIM?', 1);
        return;
    end;
    if(~strcmpi(sfile.Method.v, 'SAM'))
        QueMessage(sprintf('SAM: loaded sfile is of type %s, not ours!', sfile.Method.v), 1);
        return;
    end;
end;
sfile.IPI.v = 1000.0/sfile.SamCarrier.v;
sfile.Npulses.v = floor(sfile.SamDuration.v*sfile.SamCarrier.v/1000.0);
[outdata, tbase, out_rate, err, sfile] = pulse(sfile);
for i = 1:length(outdata) % now modify the output waveforms.
    tb = [tbase{i}.v];
    rf = rfshape(sfile.Delay.v, sfile.Npulses.v*sfile.IPI.v, out_rate, sfile.SamRF.v);
    sw = (1.0 - sfile.SamDepth.v/100.0) + (sfile.SamDepth.v/100.0)*(0.5*sin(2*pi*(sfile.SamFMod.v/1000.0)*(tb-sfile.Delay.v))+0.5);
    sw(1:length(rf)) = sw(1:length(rf)).*rf';
    outdata{i}.v = sw' .* outdata{i}.v';
end;
tb = [tbase{1}.vsco];
rf = rfshape(sfile.Delay.v, sfile.Npulses.v*sfile.IPI.v, out_rate, sfile.SamRF.v);
sw = (1.0 - sfile.SamDepth.v/100.) + (sfile.SamDepth.v/100.0)*(0.5*sin(2*pi*(sfile.SamFMod.v/1000.0)*(tb-sfile.Delay.v))+0.5);
sw(1:length(rf)) = sw(1:length(rf)).*rf';
outdata{1}.vsco = sw' .* outdata{1}.vsco';

%rf shape function taken from python PySounds code, modified for matlab.
function fil = rfshape(delay, duration, samplefreq, rf)

% convert values all to seconds
delay = delay/1000.;
duration = duration/1000.;
rf = rf/1000.;

jd = floor(delay*samplefreq); % beginning of signal buildup (delay time)
if jd < 1
    jd = 1;
end;
je = floor((delay+duration)*samplefreq)+1; % end of signal decay (duration + delay)
%
% build sin^2 filter from 0 to 90deg for shaping the waveform
%
nf = floor(rf*samplefreq); % number of points in the filter
fo = 1.0/(4.0*rf); % filter "frequency" in Hz - the 4 is because we use only 90deg for the rf component

pts = 0:nf;
fil = zeros(je, 1);
fil(jd:jd+nf) = sin(2*pi*fo*pts/samplefreq).^2; % filter
fil((jd+nf):(je-nf)) = 1;
pts = ((je-nf):je);
kpts = (jd+nf:-1:jd);
fil(pts) = fil(kpts);





