function [st] = an_generate (spont, freq, inten, delay_totone, stimdur, end_silence, seed1, seed2)
% matlabDemo is a skeleton script for running a modle using AMS_ng

if(nargin ~= 8)
   fprintf(1, 'Input args not correct!');
   st=[];
   return;
end;

cpath = pwd;

simFilePath = 'C:\DSAM\AMS\Tutorials\AuditoryPeriphery';
simFileName = 'auditoryNerve.sim';
% Set the directory to the location of the .sim file
if ~isempty(simFilePath)
   cd (simFilePath);
end

switch (spont) 
case  'low'
   gcamax = 2.75e-9; % From Sumner et al. (2002), Table II(lower part)
   concthr = 4.0e-11;
   maxpool = 7;
case 'medium'
   gcamax = 4.5e-9; % From Sumner et al. (2002), Table II(lower part)
   concthr = 3.2e-11;
   maxpool = 10;
case 'high'
   gcamax = 8e-9;% From Sumner et al. (2002), Table II(lower part)
   concthr = 4.48e-11;
   maxpool = 10;
otherwise
   return;
end;

pars  = [ ...
      ' FREQUENCY.stim_pureTone_2.0 ', num2str(freq), ...
      ' INTENSITY.stim_pureTone_2.0 ', num2str(inten), ...
      ' DURATION.stim_pureTone_2.0 ', num2str(stimdur), ...
      ' BEGIN_SILENCE.stim_pureTone_2.0 ', num2str(delay_totone), ...
      ' END_SILENCE.stim_pureTone_2.0 ', num2str(end_silence), ...
      ' GMAX_CA.IHC_Meddis2000.10 ', num2str(gcamax), ...
      ' CONC_THRESH_CA.IHC_Meddis2000.10 ', num2str(concthr), ...
      ' MAX_FREE_POOL_M.IHC_Meddis2000.10 ', num2str(maxpool), ...
      ' RAN_SEED.IHC_Meddis2000.10 ', num2str(seed1), ...
      ' RAN_SEED.AN_SG_Meddis02.11 ', num2str(seed2), ...
      
   ];

%default output file name is assumed to be output.dat
outputFileName='output.dat';

% Now run AMS
runAMS_RM (simFileName,pars);

% When the program reaches here, AMS should have created a results file
[results, column1Values, columnHeadingsValues, errorMsg]=...
   readDatFile(outputFileName);

if errorMsg==1
   QueMessage('error when reading output file',1)
   return
end
ir = find(results ~= 0);
t = column1Values(ir);
s = results(ir);
st = [t, s];



%--------------------------------------------------------------------------
% --------------------------------------------------------read data file
function [results, column1Values, columnHeadingsValues, errorMsg]=readDatFile(datFileName)
% readDatFile get results from file created by AMS
% It is assumed that the .dat file consists of
% a first row with short text followed by heading values
% later rows are row heading followed by results

errorMsg=0;
try
   fid = fopen(datFileName);
catch
   errorMsg=1; return
end   

columnHeadings = fgetl(fid); 	%column headings     

% assume that the first 9 characters are text
closingParenthesis=1+ findstr(columnHeadings, ')');
columnHeadings=columnHeadings(closingParenthesis:end); %remove 'Time (s)'

% extract BFs
columnHeadingsValues=str2num(columnHeadings); 
numHeadings=length(columnHeadingsValues);

x= fscanf(fid,'%g',[numHeadings+1 inf]);
x=x';

column1Values=x(:,1);
results=x(:,2:end);

fclose(fid); 

function tempFileName=setNoRepeats (simFile, noRepeats)
% setNoRepeats alters .sim file to set repeats as required
% tempFileName=setNoRepeats (simFile, noRepeats)

tempFileName='tempSimFile.sim';
fidIn = fopen(simFile);
if fidIn == -1, error('simFile not found'), end
fidOut = fopen(tempFileName,'w');
if fidOut == -1, error('setNoRepeats, tempSimFile.sim could not be opened'), end

while 1
   line = fgetl(fidIn);   if ~ischar(line), break, end
   if ~isempty(findstr(line, 'repeat'));
      if ~isempty(findstr(line, '{'));
         line=['repeat ' num2str(noRepeats) ' {'];
      end
   end
   
   %  disp(line)
   fprintf(fidOut,'%s\n', line);  
end
fclose(fidOut);   fclose(fidIn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --------------------------------------------- runAMS
function runAMS_RM(simFile, pars)
% runAMS*    run AMS application using AMS_ng.exe 
% This is a simplified copy of runDSAM from Chris Sumner's dsam_mat folder
%
% SYNOPSIS:
% Function: to run the AMS application from MATLAB. 
% It runs  any specified 'sim' file. 
% This is a simplified version that assumes 
% 1. You are using ams_ng as the executable.
% 2. The executable is to be found in 'c:\Progra~1\DSAM\AMS\'
%
% USE:
% runAMS(simFile, pars)
%   simFile:    simulation file defining the process modules
%   pars:       stimuli for the simulation modules, overriding 
%               par file settings (optional).
%
% stimuli (pars):
%   stimuli are specified in a string, separated by spaces.
%   the format for each is:
%        [ <variable name><space><variable value><space> ..]
%
%This function calls AMS_ng.exe, which must be located on thepath:
%  C:\Program Files\DSAM\AMS
%If you have located this executable somewhere else, you must change
% the path name appropriately below.
%
% SEGMENT MODE is set to OFF

% ------ Path for the aim routine -------
amsdsam_path  = 'c:\DSAM\AMS\';
amsdsam_exe = 'ams_ng';

% ------ Check sim file is specified ------
if nargin < 1
   error('runAMS: No sim file specified.');
end;

% ------ Check for stimulus options -------
if nargin < 2
   pars='';
end;

% Look for requests for lsting of the stimuli, and remove them
% from the pars string.
stimuluslistcmd = '';
pars_inds = findstr(pars,'pars');
if ~isempty(pars_inds) 
   stimuluslistcmd = ' -l stimuli ';
   pars = [pars(1:pars_inds(1)-1) pars( pars_inds(1)+4: length(pars) )]
end;
stimuli_inds = findstr(pars,'stimuli');
if ~isempty(stimuli_inds) 
   stimuluslistcmd = ' -l stimuli ';
   pars = [pars( 1:stimuli_inds(1)-1 ) ...
         pars( stimuli_inds(1)+10:length(pars) )]
end;

% -------- Run the DSAM program (usually AMS) -------------------
 cmd = ['!' amsdsam_path amsdsam_exe stimuluslistcmd ' -s ' simFile ' -d off SEGMENT_MODE OFF ' pars ];
cmd = ['!' amsdsam_path amsdsam_exe stimuluslistcmd ' -s ' simFile ' ' pars ];
eval(slash4OS(cmd));

%-----------------------------------------------------------------------------------
function strout = slash4OS(strin)
% strout = slash4OS(strin)
% Takes a string, containing paths, and converts any slashes to the correct
% form for the underlying operating system, automatically determining OS

if (computer=='PCWIN')
   newslash = '\';
   oldslash = '/';
else 
   newslash = '/';
   oldslash = '\';
end;

oldslashpos = findstr(strin,oldslash);
strin(oldslashpos) = ones(size(oldslashpos))*newslash;
strout = strin;
