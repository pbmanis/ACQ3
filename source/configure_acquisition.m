function [A2D] = configure_acquisition()

global DFILE HARDWARE MCList AXPList APRList

% now compute the channel list and gains from our hardware and DFILE
% information.
% 1. From DFILE, get the channel list, and then the actual channels
chlist = DFILE.ChannelList.v; % is a string, like "v1 t1" etc.
vlist = textscan(chlist, '%s');
vlist = vlist{1}; % convert to cell array getting rid of first dimension
nchans = length(vlist); % how many requests?

ndev = HARDWARE.NInputDevices; % how many input devices are possible?
adchlist =cell(ndev, 1); % build the system a-d channel list from the hardware
adchj = ones(ndev, 1);
ampinfo = cell(ndev, 1);
j = 1;
for i = 1:ndev
    ampinfo{i} = eval(sprintf('HARDWARE.InputDevice%d', i));
    switch(lower(ampinfo{i}.Amplifier))
        case MCList
            adchlist{j} = ampinfo{i}.Amp1;
            adchj(j) = i;
        case AXPList
            adchlist{j} = ampinfo{i}.Amp1;
            adchj(j) = i;
        case APRList
            adchlist{j} = ampinfo{i}.Amp1;
            adchj(j) = i;
        case {'ttl'}
            tamp = i;
            adchlist{j} = ampinfo{i}.PrimaryChan;
            adchj(j) = i;
        otherwise
            return;
    end;
    j = j + 1;

end;
if(strcmpi(DFILE.Data_Mode.v,'cc'))
    dmode = 1;
else
    dmode = 0;
end;

% now associate the inputs with the a/d channel, and set the parameters up.
% Note that this utilizes the structure of the rig.hdw file, and so any
% changes to that file need to be reflected here as well.

A2D = struct('chan', 1, 'sensorrange', 10, 'units', 'mV', 'inputrange', 10, 'unitsrange', 1);

for i = 1:nchans
    amp = str2double(vlist{i}(2)); % get the second character in the designation
    ch = char( vlist{i}(1) );
    
    switch(lower(ampinfo{amp}.Amplifier))
        case MCList
            if(dmode == 1)
                order = 'ivt';
            else
                order = 'vit';
            end;
            k = strfind(order, ch);
            if(k == 3)
                k = 1;
                amp = tamp;
            end;
            
            if(dmode)
                x = textscan(HARDWARE.multiclamp.UnitsCC, '%s');
                A2D(i).units = char(x{1}(k));
                A2D(i).unitsrange = HARDWARE.multiclamp.UnitsRangeCC(k);
                A2D(i).sensorrange = HARDWARE.multiclamp.SensorRangeCC(k);
                A2D(i).inputrange = HARDWARE.multiclamp.InputRangeCC(k);
            else
                x = textscan(HARDWARE.multiclamp.UnitsVC, '%s');
                A2D(i).units = char(x{1}(k));
                A2D(i).unitsrange = HARDWARE.multiclamp.UnitsRangeVC(k);
                A2D(i).sensorrange = HARDWARE.multiclamp.SensorRangeVC(k);
                A2D(i).inputrange = HARDWARE.multiclamp.InputRangeVC(k);
            end;

        case AXPList
            k = 1;
            if(dmode)
                x = textscan(HARDWARE.axopatch.UnitsCC, '%s');
                A2D(i).units = char(x{1}(k));
                A2D(i).unitsrange = HARDWARE.axopatch.UnitsRangeCC(k);
                A2D(i).sensorrange = HARDWARE.axopatch.SensorRangeCC(k);
                A2D(i).inputrange = HARDWARE.axopatch.InputRangeCC(k);
            else
                x = textscan(HARDWARE.axopatch.UnitsVC, '%s');
                A2D(i).units = Hchar(x{1}(k));
                A2D(i).unitsrange = HARDWARE.axopatch.UnitsRangeVC(k);
                A2D(i).sensorrange = HARDWARE.axopatch.SensorRangeVC(k);
            A2D(i).inputrange = HARDWARE.axopatch.InputRangeVC(k);
            end;


        case APRList
            k = 1;
            A2D(i).sensorrange = HARDWARE.axoprobe.SensorRangeCC(k);
            A2D(i).units = HARDWARE.axoprobe.UnitsCC(k);
            A2D(i).inputrange = HARDWARE.axoprobe.InputRangeCC(k);
            A2D(i).unitsrange = HARDWARE.axoprobe.UnitsRangeCC(k);
% no vc for apr 

        case 'ttl'
            k = 1;
            A2D(i).sensorrange = HARDWARE.TTL.SensorRange;
            A2D(i).units = HARDWARE.TTL.Units;
            A2D(i).inputrange = HARDWARE.TTL.InputRange;
            A2D(i).unitsrange = HARDWARE.TTL.UnitsRange;

        otherwise
    end;
    A2D(i).chan = adchlist{amp}(k);

end;
