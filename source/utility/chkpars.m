function [seqpars, err] = chkpars(list, possibles)
% chkpars: check the possibile sequence list against the request
% format:
% [out1 out2 err] = chkpars(string, {cellarray of possibles});
%

err = 0;

if(nargin ~= 2)
   fprintf(2, 'chkpars: expect 2 input arguments\n');
   err = 1;
   return;
end;

% copy sequence parameter into cell array
s = lower(list); % get the parameter to sequence
pars={};
i = 1;
while(~isempty(s))
   [pars{i}, s] = strtok(s, ' '); % get the tokens into a cell array
   i = i + 1;
end;
seqpars = zeros(length(pars), length(possibles));
% verify valid sequence parameter for this stimulus type
for j = 1:length(possibles)
    for i = 1:length(pars)
        x = strcmpi(pars{i}, possibles{j});
        if(isempty(x))
            QueMessage(sprintf('Stimulus Method: Sequencing only allowed on %s\n', possibles),1)
            return;
        else
            seqpars(i, j) = x;
        end;
    end;
end;

err = 0;
return;
