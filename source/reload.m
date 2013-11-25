function reload()
% reload: force update of current stim, save s2 auto overwrite
% ***CMD***
%       - and reload the original protocol, with pv -f to make sure
%       - it is recomputed with the new s2.
%

pv('2');
s2('-f'); % force the file to be saved, overwriting the previous version
g -l  % reload the last file that was "get"
pv('-f'); % update the whole file one more time

end

