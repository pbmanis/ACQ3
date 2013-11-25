function getmethod()
% getmethod  -  get the method and store the code in the STIM block.
%
% The "method" is the stimulus waveform code from the m file specified
% by the stim block. In this routine we read the m file into a character
% array and store it in the STIM structure. The structure is then stored.
% This archives the code for the stimulus generation routine with the data
% For complex stimuli (such as noise, or simulated EPSP trains with stochastic
% interevent intervals), this codifies the method used in absolute terms.
%
% 8/14/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
global STIM

mf = [STIM.Method.v '.m']; % name of method file
fid = fopen(mf, 'r');
if(fid < 0)
   fprintf('getmethod: Method file: %s not found? ', mf);
   return;
end;
m = fread(fid, inf, 'schar'); % read the source file
fclose(fid);
STIM.method_code = char(m'); % store it in the array in a way we can extract it later to generate the stim.
return;

