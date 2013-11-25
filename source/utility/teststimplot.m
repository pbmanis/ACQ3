function teststimplot(tbase, outdata, type)
% generate a test plot of the stimulus that was generated.
% outdata is passed from the data set generated
% tbase is passed from the data set generated
% type is 0 to just make the plot
% type is 1 to include some statisitcs (for poisson, etc).
% 4/2008 P. Manis

h = findobj('tag', 'acqstimfigure');
if(isempty(h) || ~ishandle(h))
    h = figure('tag', 'acqstimfigure');
end;
figure(h);
set(h, 'Name', 'Test stimulus waveform');
clf;
if(type == 1)
    maxisih = 100;
    maxpsth = 500;
    ix = (0:0.5:maxisih); % isi binning;
    px = (0:1:maxpsth); % psth binning;
    spt = {}; % spike train list....
    isih = zeros(length(ix),1);
    psth = zeros(length(px),1);
    pst = []; isi = [];
end;


clist = ['r', 'g', 'b', 'y', 'c', 'm', 'k'];
for i = 1: length(outdata)
    ci = mod(i-1, length(clist)) + 1;
    if type == 0
        hp = subplot(1,1,1);
    else
        hp = subplot(2,2,1);
    end;
    plot(tbase{i}.v, outdata{i}.v, [clist(ci), '-']);
    title('Pulse Waveform');
    if(i == 1)
        hold on
    end;
    if(type == 1)
        [d1, k2] =find(outdata{i}.v >= 1);
        switch(length(k2))
            case 0
                spike_pos = [];
            case 1
                spike_pos = k2(1);
            otherwise
                spike_pos = [k2(1) k2(find(diff(k2) > 1)+1)]; % and store the resulting array
        end;
        A = tbase{i}.v(spike_pos)';
        pst = [pst; A]; %#ok<AGROW>
        isi = [isi; diff(A)];     %#ok<AGROW>
        psth = hist(pst, px);
        isih = hist(isi, ix);
        isim = mean(isi);
        hp=subplot(2,2,4);
        bar(ix(1:end-1), isih(1:end-1));
        set(hp, 'Xlim', [0 maxisih]);
        title('ISI');
        xlabel('Time (ms)');
        ylabel('Counts');
        hp=subplot(2,2,3);
        bar(px(1:end-1), psth(1:end-1));
        set(hp, 'Xlim', [0 maxpsth]);
        title('PSTH');
        xlabel('Time (ms)');
        ylabel('Counts');
   end;
% make some calculations about the pulse widths to check performance of the
% pulse generator routine
   pulsewidths = [];
   t = tbase{i}.v;
   d = outdata{i}.v;
   pm = max(d);
   u = find(diff(d) > 0.);
   d = find(diff(d) < 0.);
   dt = d - u;
   mean(dt);
   std(dt);
   
   
end;

