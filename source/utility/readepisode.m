function [episode] = readepisode(fid,pc6h,en)
%READEPISODE Get an episode from a pClamp 6.x Axon Binary File (ABF).
%   EPISODE = READEPISODE(FID,PC6H,EN) returns an array of the data points
%   for the episode number EN.  EN must be between 1 and the number of
%   episodes in the file pointed to by FID.
%
%   PC6H is a structure obtained from GETPC6HEADER.

%   Carsten Hohnke 12/99
scfglen=656;
if nargin ~= 3 % Check for the correct number of arguments.
  error('readepisode: Three input arguments required.')
end
if fid == -1, % Check for valid fid.
   error('readepisode: Invalid fid.');
end
ne=pc6h.lActualEpisodes; % The number of episodes.
if en < 1 | en > ne, % Check for valid en.
   error('readepisode: Invalid episode number.');
end

datafmt=pc6h.nDataFormat;

cn = pc6h.nAutosampleADCNum + 1;
pc6h.fGain=pc6h.fInstrumentScaleFactor.*pc6h.fAutosampleAdditGain;
pc6h.fGain=pc6h.fGain.*pc6h.fADCProgrammableGain.*pc6h.fSignalGain;

gain = pc6h.fADCRange / pc6h.lADCResolution / (pc6h.fInstrumentScaleFactor(cn) * pc6h.fAutosampleAdditGain * pc6h.fADCProgrammableGain(cn) * pc6h.fSignalGain(cn)) ;
offset = pc6h.fSignalOffset(cn);
ns = pc6h.lActualAcqLength / pc6h.lActualEpisodes;
dpos = (pc6h.lDataSectionPtr-1) * 512;
switch(datafmt)
case 0 % 2 byte integer format.
   fseek(fid, dpos + (en-1) * ns, 'bof');
	episode = fread(fid, ns, 'int16') * gain + offset;
case 1 % 4 byte floating format
   fseek(fid, dpos + (en-1) * 2 * ns, 'bof');
	episode = fread(fid, ns, 'float32') * gain + offset;
otherwise
   episode=[];
end;

