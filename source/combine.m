function [outdata, tbase, out_rate, err] = combine(in_data, in_tbase, in_rate, sfile, op)
% combine: superimpose or parallelize two stimulus waveforms to DAC buffers
% Usage
%     Normally this routine is not called directly by the user

%
%    superimpose two stimulus waveforms
% OR
%    place as two channels (outdata.v, v2)
% We mesh the stimuli as best we can. This means that the sample rate is the same (both channels or
% superimposed waveforms on one channel). The only difference between op = 'superimpose' and
% op = 'addchannel' is whether the output is summed or added as two channels

% September/October 2000
% Paul B. Manis, Ph.D.
% pmanis@med.unc.edu
%
% Coding changes 8/5/04 and 8/6/04: Routine should not recalculate the
% secondary waveform every time. pv-s commented out here, and the secondary
% waveform is copied into the placeholders for the primary.
%

%
%global STIM2 % use this to check if its already "in memory"
%fprintf('Entering Combine\n');

outdata={};
tbase={};
out_rate=[];
err = 1;
if(nargin < 5)
    QueMessage('combine.m: bad call?', 1);
    return;
end;
for m = 1:length(in_data)
    jnan=find(isnan(in_data{m}.v));
    if(~isempty(jnan))
        in_data{m}.v(jnan) = 0;
    end;
end;
    jnan=find(isnan(in_data{1}.vsco));
    if(~isempty(jnan))
        in_data{1}.vsco(jnan) = 0;
    end;
    
% initialize to input in case we bomb out.
outdata = in_data;
tbase = in_tbase;
out_rate = in_rate;

switch lower(op)
    case 'superimpose'
        filename = sfile.Superimpose.v;
    case 'addchannel'
        filename = sfile.Addchannel.v;
    otherwise
        QueMessage(sprintf('combine.m: operation %s is not valid', op), 1);
        return;
end;

% check to see if base rate needs to be set
if(~isempty(filename)) % is a file specified?
    %   if(isempty(STIM2)) % no structure in global variable
    sf2 = g(filename, 1); % then data is not loaded, so load it.

    %   elseif (~strcmp(STIM2.Name.v, filename)) % file in STIM2 is different file than one we need?
    %      sf2 = g(filename); % get the arg

    %   else
    %      sf2 = STIM2; % file is in global storage, and name matches our required name.
    %   end;
    if(isempty(sf2))
        QueMessage(sprintf('combine.m: Unable to get stimulus file %s\n', filename));
        return;
    end;
    if(sf2.update == 0) % make sure we have been updated
        [o2, t2, sr2, err2] = eval([sf2.Method.v '(sf2)']); % compute the new waveforms.
    else % if not needing an update then...
        o2 = sf2.waveform; % just copy data over.
        t2 = sf2.tbase;
        sr2 = sf2.Sample_Rate.v; % set sample rate - but check it out...
        err2 = 0;
    end;

    for m = 1:length(o2)
        jnan=find(isnan(o2{m}.v));
        if(~isempty(jnan))
            o2{m}.v(jnan) = 0;
        end;
    end;
        jnan=find(isnan(o2{1}.vsco));
        if(~isempty(jnan))
            o2{1}.vsco(jnan) = 0;
        end;

    if(err2 == 1) % couldn't compute?
        return;
    end;
    % determine which one lasts the longest...
    %    for i = 1:length(in_tbase) % in the first series
    %       tb1=max(max(in_tbase{i}.v));
    %    end;
    %    for i = 1:length(t2) % and in the second series
    %       tb2=max(max(t2{i}.v));
    %    end;
    %    tmax = max(tb1, tb2); % find the maximum time point
    %    tfac = 1000000;
    %    dt = gcd(floor(tfac/in_rate), floor(tfac/sr2)); % and then find the minimum step size, in microseconds
    %    if(dt > 500)
    %       dt = 500; % always clock at at least 2 kHz.
    %    end;
    %    out_rate=tfac/dt;
    % find out which one has the fastest clock...and use THAT one!
    for i = 1:length(in_tbase) % in the first series
        tb1=max(max(in_tbase{i}.v));
    end;
    for i = 1:length(t2) % and in the second series
        tb2=max(max(t2{i}.v));
    end;
    tmax = max(tb1, tb2); % find the maximum time point
    tfac = 1000000;
    dt = 1/(max(floor(tfac/in_rate), floor(tfac/sr2))); % and then find the minimum step size, in microseconds
    if(dt > 500)
        dt = 500; % always clock at at least 2 kHz.
    end;
    out_rate=1/dt;
    %fprintf(2, 'dt: %12.3f    out_rate: %f, inrate: %8.3f   sr2:  %8.3f \n', dt, out_rate, tfac/in_rate, tfac/sr2);
    % the time base will now the be same for all traces as we interpolate
    % for each element of superimposed data, interpolate onto new time base
    dt2=dt*1000;
    for i=1:length(in_data)
        tbmax1 = max(in_tbase{i}.v);
        tbase1=[0:dt2:tbmax1-dt2]; % new time base for display etc.
        out1{i}.v=interp1(in_tbase{i}.v, in_data{i}.v, tbase1, 'nearest');
    end;
    tbvsco1 = max(in_tbase{1}.vsco); % now handle the scope waveforms
    tbase1=[0:dt2:tbvsco1-dt2]; % new time base for display etc.
    out1{1}.vsco = interp1(in_tbase{1}.vsco, in_data{1}.vsco, tbase1, 'nearest');

    for i = 1:length(o2)
        tbmax2 = max(t2{i}.v);
        tbase2=[0:dt2:tbmax2-dt2];
        out2{i}.v=interp1(t2{i}.v, double(o2{i}.v), double(tbase2), 'nearest');
    end;
    if(strmatch('vsco', fieldnames(t2{1})))
        tbvsco2 = max(t2{1}.vsco);
        tbase2=[0:dt2:tbvsco2-dt2];
        out2{1}.vsco=interp1(t2{1}.vsco, double(o2{1}.vsco), double(tbase2), 'nearest');
    else
        out2{1}.vsco = 0 * out1{1}.vsco;
    end;
    % out2{1}.v=out2{1}.vsco;   %%% !!!!! %%% make same as scope mode (temp fix until bug solved).



    sz1=length(out1);
    sz2=length(out2);
    ko=1;
    %   fprintf(2, 'BEFORE ADJUSTMENT: out1: %d pts   out2: %d pts\n', length(out1{1}.v), length(out2{1}.v))
    % Finally, we can mesh the two data sets
    outdata={};
    minlen = 100;
    for i = 1:sz1
        for j = 1:sz2
            % pad the shorter array to match the longer - use last element value to do the padding
            lp1 = length(out1{i}.v);
            lp2 = length(out2{j}.v);
            if(lp1 < lp2)
                out1{i}.v=[out1{i}.v out1{i}.v(lp1)*ones(1, lp2-lp1)]; % this is the pad operation
            elseif(lp1 > lp2)
                out2{j}.v = [out2{j}.v out2{j}.v(lp2)*ones(1, lp1-lp2)];
            end;
            lp1 = length(out1{i}.v); % get padded lengths
            lp2 = length(out2{j}.v);
            if(lp1 < minlen) % now do the same for the min length required for dac success
                out1{i}.v=[out1{i}.v out1{i}.v(lp1)*ones(1, minlen-lp1)]; % this is the pad operation
            end;
            if(lp2 < minlen)
                out2{j}.v=[out2{j}.v out2{j}.v(lp2)*ones(1, minlen-lp2)]; % this is the pad operation
            end;
            switch(lower(op))
                case 'superimpose'
                    outdata{ko}.v = out1{i}.v+out2{j}.v; % for every one in A sequence, add each of B
                case 'addchannel'
                    % fprintf(2, 'Adding Channel');
                    outdata{ko}.v  = [out1{i}.v];
                    outdata{ko}.v2 = [out2{j}.v];
            end;
            tmax = length(outdata{ko}.v)*dt2; % adjust for correct length of output array
            tbase{ko}.v = [0:dt2:tmax-dt2];    % one common time base for both signals
            ko = ko + 1;
        end;
    end;
end;
% now do the scope mode array separately
lp1 = length(out1{1}.vsco);
lp2 = length(out2{1}.vsco);
if(lp1 < lp2)
    out1{1}.vsco=[out1{1}.vsco out1{1}.vsco(lp1)*ones(1, lp2-lp1)]; % this is the pad operation
elseif(lp1 > lp2)
    out2{1}.vsco = [out2{1}.vsco out2{1}.vsco(lp2)*ones(1, lp1-lp2)];
end;
lp1 = length(out1{1}.vsco); % get padded lengths
lp2 = length(out2{1}.vsco);
if(lp1 < minlen) % now do the same for the min length required for dac success
    out1{1}.vsco=[out1{1}.vsco out1{1}.vsco(lp1)*ones(1, minlen-lp1)]; % this is the pad operation
end;
if(lp2 < minlen)
    out2{1}.vsco=[out2{1}.vsco out2{1}.vsco(lp2)*ones(1, minlen-lp2)]; % this is the pad operation
end;
switch(lower(op))
    case 'superimpose'
        outdata{1}.vsco = out1{1}.vsco+out2{1}.vsco; % for every one in A sequence, add each of B
        outdata{1}.vsco = [outdata{1}.vsco 0];
    case 'addchannel'
        outdata{1}.vsco  = [out1{1}.vsco];
        outdata{1}.v2sco = [out2{1}.vsco];
end;
tmax = length(outdata{1}.vsco)*dt2; % adjust for correct length of output array
tbase{1}.vsco = [0:dt2:tmax-dt2];    % one common time base for both signals

err = 0;
return;
