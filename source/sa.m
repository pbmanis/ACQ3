function [err] = sa(acqfile)
% sa: Save the current Acquisition paramters to disk.
% ***CMD***
% The line above specifies this file as avaialable at the command line in
% acq3

% Usage
%     sa <cr> saves the current acquisition file to disk, using a file dialog box
%     sa filename saves the acquisition paramters, using the specified filename

%
% 7/10/2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
global DFILE CONFIG FILEFORMAT

if(nargout > 0)
    err = 1;
end;

cd(CONFIG.BasePath.v);
if(exist(CONFIG.AcqPath.v, 'dir') == 7)
    wd = cd(CONFIG.AcqPath.v);
else
    QueMessage(sprintf('sa: Configuration Path %s is invalid', CONFIG.AcqPath.v), 1);
    return;
end;


internal = DFILE.Filename.v;
if(nargin == 0)
    sug = sprintf('%s.mat', internal);
    [acqname, acqpath] = uiputfile(sug,'Save Acq Parameter File');
    if(acqname == 0)
        cd(CONFIG.BasePath.v);
        return;
    end;
    acqfile=fullfile(acqpath, acqname);
end

[p, sfn, e] = fileparts(acqfile);

if(~strcmp(internal, sfn))
    answer = questdlg(sprintf('Filename (%s) and internal (%s) name do not match.\n Change internal name to match filename and save?', sfn, internal), 'Save Acq Param File');
    if(strcmp(answer, 'Yes'))
        DFILE.Filename.v = sfn;
        struct_edit('Redisplay', DFILE);
    else
        QueMessage('Acq structure NOT saved', 1);
        cd(CONFIG.BasePath.v);
        return;
    end;
end;

save(acqfile, 'DFILE', FILEFORMAT);
cd(CONFIG.BasePath.v);
QueMessage(sprintf('Acquisition Params saved in %s', acqfile), 1);
if(nargout > 0)
    err = 0;
end;
return;

