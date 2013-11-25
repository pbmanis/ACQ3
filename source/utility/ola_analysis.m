function ola_analysis(data, k1)

% On-line analysis routine.
% parameters controlling the online analysis are set in the structure ONLINE
% The structure is updated via the routine on_line.m, which is the main
% callback from the online analysis GUI.
%
% The routine returns the result in the ONLINE structure itself.
% It is up to the user program to plot the value.
%
% Routine written for use in ACQ program.

% Paul B. Manis, Ph.D.
% 2001-2002
% Univ. of North Carolina at Chapel Hill
% pmanis@med.unc.edu

% The following analyses are available:
% mean, max, min, slope (over a window), first event latency,
% number of events detected in a,
% of either channel

%

global ONLINE ONLINE_DATA
global DFILE STIM

global ZTIME

% fprintf(1, '+++ Online analysis is called with data length %d, arg %d\n', length(data), k1);

if(~exist('ZTIME', 'var') || isempty(ZTIME)) % make sure its set... sometimes it might not be.
    ZTIME(1,:) = clock;
    ZTIME(2,:) = clock;
end;

% from the current DFILE and stim, get some information
nchan=length(DFILE.Channels.v);
% cycle=STIM.Cycle.v/1000;
srate = 1000000/(DFILE.Actual_Rate.v*nchan);

% Do the on line analysis...
for ol_win = 1:2
    if(ONLINE.Enable{ol_win}) % for those analysis windows currently enabled
        k = length(ONLINE_DATA.dx{ol_win})+1; % we add to the dataset using the current length of the x array.
    %    fprintf(1, '+++ olaanalysis: k = %d, modey = %d\n', k, ONLINE.ModeY{ol_win});
        chx = ONLINE.ChannelX{ol_win};
        chy = ONLINE.ChannelY{ol_win};
        t1x = chklimits(ONLINE.T1X{ol_win}, DFILE); % chklimits also computes the index....
        t2x = chklimits(ONLINE.T2X{ol_win}, DFILE);
        t1y = chklimits(ONLINE.T1Y{ol_win}, DFILE);
        t2y = chklimits(ONLINE.T2Y{ol_win}, DFILE);
        ONLINE.PointMode{ol_win} = 1; % force point mode - we change it with the analysis type below...
        if(t1x > t2x)
            t = t1x;
            t1x = t2x;
            t2x = t;
        end;
        if(t1y > t2y)
            t = t1y;
            t1y = t2y;
            t2y = t;
        end;
        switch(ONLINE.ModeY{ol_win})
            % basic analyses first
            case 1
                ONLINE_DATA.dy{ol_win}(k) = mean(data(t1y:t2y,chy));
            case 2
                ONLINE_DATA.dy{ol_win}(k) = min(data(t1y:t2y,chy));
            case 3
                ONLINE_DATA.dy{ol_win}(k) = max(data(t1y:t2y,chy));
            case 4
                ONLINE_DATA.dy{ol_win}(k) = mean(diff(data(t1y:t2y, chy)))/srate;
            case 5
                ONLINE_DATA.dy{ol_win}(k) = etime(clock, ZTIME(ol_win,:));

            case 6 % first spike latency
                %         3/26/2008 Working
                spike_lat = find_event(data(t1y:t2y, chy), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                spike_lat = spike_lat * srate;
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dy{ol_win}(k) = spike_lat(1);
                else
                    ONLINE_DATA.dy{ol_win}(k) = NaN; % no event detected
                end;
                
            case 7 % spike count in window
                % 3/26/2008 working
                spike_lat = find_event(data(t1y:t2y, chy), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dy{ol_win}(k) = length(spike_lat);
                else
                    ONLINE_DATA.dy{ol_win}(k) = 0;
                end;

            case 8 % PSTH - always against time, starting with analysis window start as 0 time.
                % 3/26/2008 - working (note force of dx mode)
                if(k1 == 1) % first time through, build x also
                    ONLINE_DATA.dx{ol_win} = (ONLINE.T1X{ol_win}:ONLINE.T1Y{ol_win}:ONLINE.T2X{ol_win});
                    ONLINE.PointMode{ol_win} = 3; % set histogram mode
                    ONLINE.ModeX{ol_win} = 8; % force PSTH mode for X as well to avoid other analysis clobber.
                end;
                spike_lat = find_event(data(t1x:t2x, chy), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(~isempty(spike_lat))
                    spike_lat = spike_lat*srate;
                    if(k > 1 && ~isempty(ONLINE_DATA.dy{ol_win}))
                        ONLINE_DATA.dy{ol_win} = ONLINE_DATA.dy{ol_win} + hist(spike_lat, ONLINE_DATA.dx{ol_win});
                    else
                        ONLINE_DATA.dy{ol_win} = hist(spike_lat, ONLINE_DATA.dx{ol_win});
                    end;
                end;
                
            case 9 % Raster Plot - much like PSTH. Each rep increments Y
                % 3/26/2008 - working
                ONLINE.PointMode{ol_win} = 4; % set dot mode
                ONLINE.ModeX{ol_win} = 8; % force PSTH mode for X as well to avoid other analysis clobber.
                spike_lat = find_event(data(t1x:t2x, chy), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(~isempty(spike_lat))
                    spike_lat = spike_lat*srate;
                        ONLINE_DATA.dy{ol_win} = [ONLINE_DATA.dy{ol_win} k1*ones(1, length(spike_lat))];
                        ONLINE_DATA.dx{ol_win} = [ONLINE_DATA.dx{ol_win} spike_lat];
                end;

            case 10 % Interspike interval histogram - like PSTH except based in differences of intervals
                % 3/25/2008 working
                if(k1 == 1) % first time through, build x also
                    ONLINE_DATA.dx{ol_win} = (ONLINE.T1X{ol_win}:ONLINE.T1Y{ol_win}:ONLINE.T2Y{ol_win});
                    ONLINE.PointMode{ol_win} = 3; % set histogram mode
                    ONLINE.ModeX{ol_win} = 10; % force PSTH mode for X as well to avoid other analysis clobber.
                end;
                spike_lat = find_event(data(t1x:t2x, chy), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(~isempty(spike_lat))
                    spike_lat = spike_lat*srate;
                    if(k > 1 && ~isempty(ONLINE_DATA.dy{ol_win}))
                        ONLINE_DATA.dy{ol_win} = ONLINE_DATA.dy{ol_win} + hist(diff(spike_lat), ONLINE_DATA.dx{ol_win});
                    else
                        ONLINE_DATA.dy{ol_win} = hist(diff(spike_lat), ONLINE_DATA.dx{ol_win});
                    end;
                end;

            case 11 % Synch (phase locking)
                spike_lat = find_event(data(t1y:t2y, chy), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dy{ol_win}(k) = spike_lat;
                else
                    ONLINE_DATA.dy{ol_win}(k) = 0;
                end;

            case 12 % Regularity (std(isi)/mean(isi) over time
                spike_lat = find_event(data(t1y:t2y, chy), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dy{ol_win}(k) = spike_lat;
                else
                    ONLINE_DATA.dy{ol_win}(k) = 0;
                end;

            case 13 % precision
                spike_lat = find_event(data(t1y:t2y, chy), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dy{ol_win}(k) = spike_lat;
                else
                    ONLINE_DATA.dy{ol_win}(k) = 0;
                end;

            case 14 % first interspike interval
                % working 3/25/2008
                spike_lat = find_event(data(t1y:t2y, chy), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                spike_lat = spike_lat * srate;
                if(length(spike_lat) >= 2)
                    ONLINE_DATA.dy{ol_win}(k) = spike_lat(2)-spike_lat(1);
                else
                    ONLINE_DATA.dy{ol_win}(k) = NaN; % no event detected
                end;

            otherwise
        end % of dy mode switch statement

        switch(ONLINE.ModeX{ol_win})
            case 1
                ONLINE_DATA.dx{ol_win}(k) = mean(data(t1x:t2x,chx));
            case 2
                ONLINE_DATA.dx{ol_win}(k) = min(data(t1x:t2x,chx));
            case 3
                ONLINE_DATA.dx{ol_win}(k) = max(data(t1x:t2x,chx));
            case 4 % slope
                ONLINE_DATA.dx{ol_win}(k) = mean(diff(data(t1x:t2x, chx)))/srate;
            case 5
                ONLINE_DATA.dx{ol_win}(k) = etime(clock, ZTIME(ol_win,:));
            case 6 % first spike latency
                spike_lat = find_event(data(t1x:t2x, chx), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                spike_lat = spike_lat * srate;
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dx{ol_win}(k) = spike_lat(1);
                else
                    ONLINE_DATA.dx{ol_win}(k) = NaN;
                end;

            case 7 % Total spike count in the window
                spike_lat = find_event(data(t1x:t2x, chx), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dx{ol_win}(k) = length(spike_lat);
                else
                    ONLINE_DATA.dx{ol_win}(k) = 0;
                end;

            case 8 % PSTH
                %					Nothing to do, since we handle it all
                %					in the y loop above.
            case 9 % Raster Plot
                %					Nothing to do, since we handle it all
                %					in the y loop above.
            case 10 % Interspike interval histogram
                % x is handled in Y processing
                
            case 11 % Synch (phase locking)
                spike_lat = find_event(data(t1x:t2x, chx), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dx{ol_win}(k) = length(spike_lat);
                else
                    ONLINE_DATA.dx{ol_win}(k) = 0;
                end;

            case 12 % Regularity (std(isi)/mean(isi) over time
                spike_lat = find_event(data(t1x:t2x, chx), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dx{ol_win}(k) = length(spike_lat);
                else
                    ONLINE_DATA.dx{ol_win}(k) = 0;
                end;

            case 13 % precision
                spike_lat = find_event(data(t1x:t2x, chx), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                if(length(spike_lat) >= 1)
                    ONLINE_DATA.dx{ol_win}(k) = length(spike_lat);
                else
                    ONLINE_DATA.dx{ol_win}(k) = 0;
                end;
                
            case 14 % first spike latency
                spike_lat = find_event(data(t1x:t2x, chx), ONLINE.Threshold{ol_win}, ONLINE.ThreshSlope{ol_win});
                spike_lat = spike_lat * srate;
                if(length(spike_lat) >= 2)
                    ONLINE_DATA.dx{ol_win}(k) = spike_lat(2)-spike_lat(1);
                else
                    ONLINE_DATA.dx{ol_win}(k) = NaN;
                end;

            otherwise
        end % of dx mode switch statement.


        % Special Functions.
        % The special functions are mathematical operations between the data computed above
        % and are always plotted as a function of TIME.
        % The functions are computed, for example, as:
        % Y/X vs time (ratio)
        % (Y-Y(0))/X vs time (Relative ratio)
        % Y - X vs time (difference between parts of a trace...)
        % for example, in current clamp, Y/X can be V/I at steady state, yielding Rin
        % in voltage clamp, Y/X can be I(max)/V(step), yielding an approximation to Rin
        % special function 1 is NONE

        switch(ONLINE.SpecFunc{ol_win})
            case 2
                if(ONLINE_DATA.dx{ol_win}(k) ~= 0) % protect against divide by zero
                    ONLINE_DATA.dy{ol_win}(k) = ONLINE_DATA.dy{ol_win}(k)/ONLINE_DATA.dx{ol_win}(k);
                else
                    ONLINE_DATA.dy{ol_win}(k) = NaN;
                end;
                ONLINE_DATA.dx{ol_win}(k) = etime(clock, ZTIME(ol_win,:));

            case 3
                if(ONLINE_DATA.dx{ol_win}(k) ~= 0) % protect against divide by zeron
                    ONLINE_DATA.dy{ol_win}(k) = (ONLINE_DATA.dy{ol_win}(k)-ONLINE_DATA.dy{ol_win}(1))/ONLINE_DATA.dx{ol_win}(k);
                else
                    ONLINE_DATA.dy{ol_win}(k) = NaN;
                end;
                ONLINE_DATA.dx{ol_win}(k) = etime(clock, ZTIME(ol_win,:));

            case 4 % difference
                ONLINE_DATA.dy{ol_win}(k) = ONLINE_DATA.dy{ol_win}(k) - ONLINE_DATA.dx{ol_win}(k);
                ONLINE_DATA.dx{ol_win}(k) = etime(clock, ZTIME(ol_win,:));

            case 5 % sum
                ONLINE_DATA.dy{ol_win}(k) = ONLINE_DATA.dy{ol_win}(k) * ONLINE_DATA.dx{ol_win}(k);
                ONLINE_DATA.dx{ol_win}(k) = etime(clock, ZTIME(ol_win,:));

                % the followin are the Rin computations, for different pulse positions.
            case {6, 7, 8} % Rin - 2, 3, 4
                % Specification:
                % Rin # refers to the pulse number in the stimulus train that is being tested.
                % Rin is computed as (V-V0)/(I-I0), where v0 and I0 are the mean voltage for the 2 msec
                % just before the pulse
                % V and I are computed according to the channels and times specified in the
                % online analysis window.

                pn = ONLINE.SpecFunc{ol_win} - 5; % compute pulse position.
                if(pn > length(STIM.Duration.v))
                    QueMessage('ola_analysis: Pulse number for Rin exceeds # pulses in train', 1);
                    return;
                end;
                bl_del1 = sum(STIM.Duration.v(1:pn))-1; % delay to pulse
                bl_del0 = bl_del1 - 2; % % prepare a 5 msec baseline
                t0	 = chklimits(bl_del0, DFILE); % chklimits also computes the index....
                t1	 = chklimits(bl_del1, DFILE); % chklimits also computes the index....

 
                ONLINE_DATA.dy{ol_win}(k) = 1000*(ONLINE_DATA.dy{ol_win}(k) - mean(data(t0:t1,chy)))/...
                    (ONLINE_DATA.dx{ol_win}(k) - mean(data(t0:t1,chx)));
                % fprintf('Rin: %f\n', ONLINE_DATA.dy{ol_win}(k));
                ONLINE_DATA.dx{ol_win}(k) = etime(clock, ZTIME(ol_win,:));
            otherwise % do nothing if there is no special function; also handles case = 1
        end;
        %
    end;	% of if statement on enabled computation.

    % here we can display the data : call ola_display.
    ola_display(ol_win);
end; % of main loop, enlist

return;


function t = chklimits(tx, DFILE)
% function to check the time limits; returns a point value
% corresponding to the time
t = floor(tx*DFILE.Actual_Rate.v/1000); % *length(DFILE.Channels.v))));
if(t > DFILE.Points.v)
    t = DFILE.Points.v;
end;
if(t <= 0)
    t = 1;
end;
return;

function [event_pos] = find_event(data, threshold, sign)
% function to find event crossings in data
% events must cross threshold either with + slope (sign > 0) or - slope (sign <= 0)
%
event_pos = []; %#ok<NASGU>

if(sign > 1)
    sign = 0; % convert for +/- dropdown list where 1 is + and 2 is -
end;

k1=zeros(1, length(data)); % initialize pulse vector

if(sign > 0)
    [d1] = find(data>threshold); % find points > threshold
    k1(d1) = 1; %#ok<FNDSB> % create pulse vectore array
    k1 = diff(k1); % find transitions by differentiating
    event_pos=find(k1 > 0); % and reduce to list of spike latencies - referenced from 0 time
else
    [d1] = find(data<threshold); % find points > threshold
    k1(d1) = 1; %#ok<FNDSB> % create pulse vectore array
    k1 = diff(k1); % find transitions by differentiating
    event_pos=find(k1 < 0); % and reduce to list of spike latencies - referenced from 0 time
end;
return;
