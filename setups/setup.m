function setup()
% setup:  Create the default Acq directory structure
% Usage
%   setup <cr>
% creates (if they don't exist)
%   AcqPar
%   StmPar
%   Macros
%   Data
%   source
%   pcode
%   source/private
% Sets path to include:
%   source
%   pcode
%   Macros


% This routine sets things up in the current directory.
%

k = mkdir('source');
if(k == 2)
   fprintf(2, 'Setup: It appears that this directory is already set up\n');
   fprintf(2, '       I will not overwrite it\n');
   
   setpath;
   return;
end;
k = mkdir('source/private');
k = mkdir('AcqPar');
k = mkdir('StmPar');
k = mkdir('Macros');
k = mkdir('Data');
k = mkdir('source');
k = mkdir('source/private');
k = mkdir('pcode');

setpath;

return;

function setpath()
%
fprintf(2, 'Setup:  setting paths\n');
cwd = pwd;
addpath([cwd '\source']); % make sure we are on the paths.
addpath([cwd '\pcode']);
addpath([cwd '\Macros']);
return;
