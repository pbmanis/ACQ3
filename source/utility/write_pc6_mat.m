function [err] = write_pc6_mat(filename, dfile, data)
% write_pc6_mat: write a gapfree record in pClamp6 format (abf files).
%
% We use initpc6header to get the base information to populate dfile.
% We then write it 
%
err = 1;
if(nargin  ~= 3)
   fprintf(1, 'write_acq_mat: requires exactly 3 arguments\n');
   return;
end;
day = clock;
startdate = mod(day(1),100)*10000+day(2)*100+day(3); % in yymmdd integer format
starttime = day(4)*60*60+day(5)*60+day(6); % seconds past midnight
[path, fname, ext, ver] = fileparts(filename);
dfile.fullfile = filename;
dfile.filename = fname;
dfile.path = path;
dfile.ext = ext;

fid = fopen(filename, 'w');
if(isempty(fid) | fid < 0)
   return;
end;

pc6h = initpc6header; % create a default (blank) header
% now copy from our datac dfile structure into the header 
pc6h.lActualEpisodes = dfile.records_in_file;
pc6h.lActualAcqLength=dfile.nr_points;
pc6h.fSampleRate = dfile.rate(1);
pc6h.sFileComment = sprintf('%-56s', dfile.comment');
pc6h.nDataFormat = 0;
% pc6h.lSamplesPerTrace = dfile.nr_points;

dfile.mode = 6; % corresponds to ABF file...
switch(dfile.dmode)
case 'VC'
   pc6h.nExperimentType = 1;
case 'CC'
   pc6h.nExperimentType = 2;
otherwise
   pc6h.nExperimentType = 1;
end;
pc6h.fADCSampleInterval = dfile.rate(1);

dfile.record = 1;

pc6h.nADCNumChannels = dfile.nr_channel;
pc6h.fInstrumentScaleFactor = dfile.vgain*ones(1,16)';
pc6h.lDataSectionPtr = 8; % put data 8 blocks out...

% now write the header line by line.
if fid == -1, % Check for invalid fid.
   error('write_pc6_mat: Invalid fid.');
end
fseek(fid,0,'bof'); % Set the pointer to beginning of the file.
pc6h.lFileStartDate = startdate;
pc6h.lFileStartTime = starttime;

% file ID and size information
fwrite(fid, pc6h.sFileType, 'schar'); % pointing to byte 0 ('ABF')
fwrite(fid, pc6h.fFileVersionNumber, 'float32')% 4 (1.5 for current file)
fwrite(fid, pc6h.nOperationMode, 'int16'); % 8  (3 = gapfree).
fwrite(fid, pc6h.lActualAcqLength, 'int32'); % 10 (total ADC samples in file)
fwrite(fid, pc6h.nNumPointsIgnored, 'short'); % 14 (0)
fwrite(fid, pc6h.lActualEpisodes, 'int32'); % 16 (1 for gapfree, otherwise # sweeps)
fwrite(fid, pc6h.lFileStartDate, 'int32'); % 20 (yymmdd)
fwrite(fid, pc6h.lFileStartTime, 'int32'); % 24 (seconds past midnight)
fwrite(fid, pc6h.lStopwatchTime, 'int32'); % 28 (0)
fwrite(fid, pc6h.fHeaderVersionNumber, 'float32'); % 32 (1.5)
fwrite(fid, pc6h.nFileType, 'int16'); % 36 (1 = ABF)
fwrite(fid, pc6h.nMSBinFormat, 'int16'); % 38 (0 for IEEE format...)

% file structure
fwrite(fid, pc6h.lDataSectionPtr, 'int32'); % 40 (block number of DATA section)
fwrite(fid, pc6h.lTagSectionPtr, 'int32'); % 44 (block number of Tag section)
fwrite(fid, pc6h.lNumTagEntries, 'int32'); % 48 (Number of Tag entries)
fwrite(fid, pc6h.lLongDescriptionPtr, 'int32'); % 52 (Block number of Scope Config Pointer)
fwrite(fid, pc6h.lLongDescriptionLines, 'int32'); % 56 (Number of Scope Config sections)
fwrite(fid, pc6h.lDACFilePtr, 'int32'); % 60 (block number of start of DAC section)
fwrite(fid, pc6h.lDACFileNumEpisodes, 'int32'); % 64 (number of sweeps in DAC sectoin)
fwrite(fid, pc6h.sUnused68, 'schar'); % 4char % 68 (unused)
fwrite(fid, pc6h.lDeltaArrayPtr, 'int32'); % 72 (block number of Delta array section)
fwrite(fid, pc6h.lNumDeltas, 'int32'); % 76 (number of entries in Delta array section)
fwrite(fid, pc6h.lNotebookPtr, 'int32'); % 80 (block number of voice tag section)
fwrite(fid, pc6h.lNotebookManEntries, 'int32'); % 84 (number of voice tag entries)
fwrite(fid, pc6h.lNotebookAutoEntries, 'int32'); % 88 (unused)
fwrite(fid, pc6h.lSynchArrayPtr, 'int32'); % 92 (block number of synch array section_
fwrite(fid, pc6h.lSynchArraySize, 'int32'); % 96 (number of PAIRS of entries in synch array section)
fwrite(fid, pc6h.nDataFormat, 'int16'); % 100 (data representation: 0 = 2-byte integer, 1 = IEEE 4 byte float)
fwrite(fid, pc6h.nSimultaneousScan, 'int16'); % 102 (ADC channel scanning mode 0=mux, 1=simul; NOT IMPLEMENTED)
fwrite(fid, pc6h.sUnused102, 'schar'); % 18char % 102 (

% Trial hierarhcy information
fwrite(fid, pc6h.nADCNumChannels, 'int16'); % 120 (number of analog input channels sampled)
fwrite(fid, pc6h.fADCSampleInterval, 'float32'); % 122 (interval between multiplexed channels)
fwrite(fid, pc6h.fADCSecondSampleInterval, 'float32'); %  % 126 (when switching clocks)
fwrite(fid, pc6h.fSynchTimeUnit, 'float32'); % 130 (synch array time unit: 0 = samples, nn = usec. normally 0)
fwrite(fid, pc6h.fSecondsPerRun, 'float32'); % 134 (gapfree: duration of acq; otherwise set to -1 (ignore and refer to lEpisodesPerRun))
fwrite(fid, pc6h.lNumSamplesPerEpisode, 'int32'); % 138 (# muxed ADC samples per sweep if mode is 2, 4 or 5; undefined if mode is 1 or 3)
fwrite(fid, pc6h.lPreTriggerSamples, 'int32'); % 142 (pretrigger intervals = 0)
fwrite(fid, pc6h.lEpisodesPerRun, 'int32'); % 146 (sweeps per run.  if gapfree, set to 1.
fwrite(fid, pc6h.lRunsPerTrial, 'int32'); % 150 (runs per trial. if gapfree, set to 1.
fwrite(fid, pc6h.lNumberOfTrials, 'int32'); % 154 (set to 1)
fwrite(fid, pc6h.nAveragingMode, 'int16'); % 158 (0 = no averaging)
fwrite(fid, pc6h.nUndoRunCount, 'int16'); % 160 set to -1
fwrite(fid, pc6h.nFirstEpisodeInRun, 'int16'); % 162 (set to 1)
fwrite(fid, pc6h.fTriggerThreshold, 'float32'); % 164 (user units: set to 0)
fwrite(fid, pc6h.nTriggerSource, 'int16'); % 168 (set to -1 for external, > 0 for physical channel number, -3 for start-to-start interval)
fwrite(fid, pc6h.nTriggerAction, 'int16'); % 170 (0 = one sweep, 1 = one run, 2 = one trial)
fwrite(fid, pc6h.nTriggerPolarity, 'int16'); % 172 (0 = rising, 1 == falling)
fwrite(fid, pc6h.fScopeOutputInterval, 'float32'); % 174 (set to 0)
fwrite(fid, pc6h.fEpisodeStartToStart, 'float32'); % 178 (time between start of sweeps, in seconds = cycle time)
fwrite(fid, pc6h.fRunStartToStart, 'float32'); % 182 (time between start of runs (seconds)
fwrite(fid, pc6h.fTrialStartToStart, 'float32'); % 186 (time between trials (seconds)
fwrite(fid, pc6h.lAverageCount, 'int32'); % 190 (number of runs for each average: set to 1)
fwrite(fid, pc6h.lClockChange, 'int32'); % 194 (# samples after which second sampling interval begins: set to -1)
fwrite(fid, pc6h.nAutoTriggerStrategy, 'int16'); % 2char % 198 (0 = do not auto trig; 1 = autotrig; only when nOpmode = highspeed osc).

% display parameters
fwrite(fid, pc6h.nDrawingStrategy, 'int16'); % 200 (0 = not draw, 1 = update immed.... set to 0)
fwrite(fid, pc6h.nTiledDisplay, 'int16'); % 202 (set to 0)
fwrite(fid, pc6h.nEraseStrategy, 'int16'); % 204 (set to 2)
fwrite(fid, pc6h.nDataDisplayMode, 'int16'); % 206 (set to 1 = lines)
fwrite(fid, pc6h.lDisplayAverageUpdate, 'int32'); % 208 (set to -1)
fwrite(fid, pc6h.nChannelStatsStrategy, 'int16'); % 212 (set to 0)
fwrite(fid, pc6h.lCalculationPeriod, 'int32'); % 214 (set to 16384)
fwrite(fid, pc6h.lSamplesPerTrace, 'int32'); % 218 (number of multiplexed adc samples displayed per trace)
fwrite(fid, pc6h.lStartDisplayNum, 'int32'); % 222 (set to 1)
fwrite(fid, pc6h.lFinishDisplayNum, 'int32'); % 226 (set to 0 to finish at end of sweep)
fwrite(fid, pc6h.nMultiColor, 'int16'); % 230 (set to 1 for multicolor)
fwrite(fid, pc6h.nShowPNRawData, 'int16'); % 232 (set to 0 for display corrected data
fwrite(fid, pc6h.fStatisticsPeriod, 'float32'); % 234 set to 0
fwrite(fid, pc6h.lStatisticsMeasurements, 'int32'); % 238   set to 0  ***** possible problem *****
fwrite(fid, pc6h.nstatisticsSaveStrategy, 'int16'); % 242 set to 0 for auto

% hardware information
fwrite(fid, pc6h.fADCRange, 'float32'); % 244  ADC-full scale (5 or 10 V)
fwrite(fid, pc6h.fDACRange, 'float32'); % 248  DAC full scale (10V)
fwrite(fid, pc6h.lADCResolution, 'int32'); % 252 number of adc counts corresponding to full scale voltage: 2048 or 16384
fwrite(fid, pc6h.lDACResolution, 'int32'); % 256 dac counts for full scale.... 

% Environment information
fwrite(fid, pc6h.nExperimentType, 'int16'); % 260 % 0 for voltage clamp, 1 for current clamp
fwrite(fid, pc6h.nAutosampleEnable, 'int16'); % 262 % set to 0 (disabled)
fwrite(fid, pc6h.nAutosampleADCNum, 'int16'); % 264 % physical sample number for autosample: set to 1
fwrite(fid, pc6h.nAutosampleInstrument, 'int16'); % 266 % instrument: set to 0 (unknown)
fwrite(fid, pc6h.fAutosampleAdditGain, 'float32'); % 268 % additional gain multiplier (set to gain reading or 1)
fwrite(fid, pc6h.fAutosampleFilter, 'float32'); % 272 % low pass filter (set to LPF reading or 100000)
fwrite(fid, pc6h.fAutosampleMembraneCapacitance, 'float32'); % 276 cap : set to 0 (not read)
fwrite(fid, pc6h.nManualInfoStrategy, 'int16'); % 280 set to 0.
fwrite(fid, pc6h.fCellID1, 'float32'); % 282 numeric cell identifier (set to 1)
fwrite(fid, pc6h.fCellID2, 'float32'); % 286 numeric identifier (set to 0)
fwrite(fid, pc6h.fCellID3, 'float32'); % 290 numeric identifier (set to 0)
fwrite(fid, pc6h.sCreatorInfo, 'schar'); % 16char % 294 write as "Clampex 6.0" 
fwrite(fid, pc6h.sFileComment, 'schar'); % 56char % 310 56 byte ascii comment string (copy comment here)
fwrite(fid, pc6h.sUnused366, 'schar'); % 12char % 366 unused

% Multichannel information
fwrite(fid, pc6h.nADCPtoLChannelMap, 'int16'); % 378 physical to logical channel map (end with -1 if fewer than 16)
fwrite(fid, pc6h.nADCSamplingSeq, 'int16'); % 410 ADC sampling sequence (pad with -1 if fewer than 16)
fwrite(fid, pc6h.sADCChannelName, 'char'); % 442 channel names (set to spaces)
fwrite(fid, pc6h.sADCUnits, 'char'); % 8char % 602 user units for adc (set to spaces)
fwrite(fid, pc6h.fADCProgrammableGain, 'float32'); % 730 adc programmable gain (read it or set to 1)
fwrite(fid, pc6h.fADCDisplayAmplification, 'float32'); % 794 (set to 1: array)
fwrite(fid, pc6h.fADCDisplayOffset, 'float32'); % 858 (set to 0: array)
fwrite(fid, pc6h.fInstrumentScaleFactor, 'float32'); % 922 (set to 1: array)
fwrite(fid, pc6h.fInstrumentOffset, 'float32'); % 986 (set to 0 array) 
fwrite(fid, pc6h.fSignalGain, 'float32'); % 1050 (set to 1 array)
fwrite(fid, pc6h.fSignalOffset, 'float32'); % 1114 (set to 0 array)
fwrite(fid, pc6h.fSignalLowpassFilter, 'float32'); % 1178 (set to 100000 array)
fwrite(fid, pc6h.fSignalHighpassFilter, 'float32'); % 1242 (set to 0 array)
fwrite(fid, pc6h.sDACChannelName, 'char'); % 1306 (set to spaces)
fwrite(fid, pc6h.sDACChannelUnits, 'char'); % 8char % 1346 (set to spaces)
fwrite(fid, pc6h.fDACScaleFactor, 'float32'); % 1378 (dac channel gains: set to 1)
fwrite(fid, pc6h.fDACHoldingLevel, 'float32'); % 1394 (set to 0)
fwrite(fid, pc6h.nSignalType, 'int16'); % 12char % 1410 (set to 0 for no signal conditioner)
fwrite(fid, pc6h.sUnused1412, 'char'); % 10char % 1412

% synchronous timer outputs
fwrite(fid, pc6h.nOUTEnable, 'int16'); % 1422 % set to 0
fwrite(fid, pc6h.nSampleNumberOUT1, 'int16'); % 1424 % set to 0
fwrite(fid, pc6h.nSampleNumberOUT2, 'int16'); % 1426 % set to 0
fwrite(fid, pc6h.nFirstEpisodeOUT, 'int16'); % 1428 % set to 0
fwrite(fid, pc6h.nLastEpisodeOUT, 'int16'); % 1430 % set to 0
fwrite(fid, pc6h.nPulseSamplesOUT1, 'int16'); % 1432 % set to 0
fwrite(fid, pc6h.nPulseSamplesOUT2, 'int16'); % 1434 % set to 0

%Epoch waveform and pulses
fwrite(fid, pc6h.nDigitalEnable, 'int16'); % 1436 % set to 0
fwrite(fid, pc6h.nWaveformSource, 'int16'); % 1438 % set to 0
fwrite(fid, pc6h.nActiveDACChannel, 'int16'); % 1440 % set to 0
fwrite(fid, pc6h.nInterEpisodeLevel, 'int16'); % 1442 % set to 0
fwrite(fid, pc6h.nEpochType, 'int16'); % 1444 % set to 0
fwrite(fid, pc6h.fEpochInitLevel, 'float32'); % 1464 % set to 0
fwrite(fid, pc6h.fEpochLevelInc, 'float32'); % 1504 % set to 0
fwrite(fid, pc6h.nEpochInitDuration, 'int16'); % 1544 % set to 0
fwrite(fid, pc6h.nEpochDurationInc, 'int16'); % 1564 % set to 0
fwrite(fid, pc6h.nDigitalHolding, 'int16'); % 1584 % set to 0
fwrite(fid, pc6h.nDigitalInterEpisode, 'int16'); % 1586 % set to 0
fwrite(fid, pc6h.nDigitalValue, 'int16'); % 1588 ^% set to 0
fwrite(fid, pc6h.fWaveformOffset, 'float32'); % 1608 % set to 0
fwrite(fid, pc6h.sUnused1612, 'schar'); % 8char % 1612

% DAC output file
fwrite(fid, pc6h.fDACFileScale, 'float32'); % 1620 % set to 1
fwrite(fid, pc6h.fDACFileOffset, 'float32'); % 1624 % set to 0
fwrite(fid, pc6h.sUnused1628, 'schar'); % 2char % 1628 % unused
fwrite(fid, pc6h.nDACFileEpisodeNum, 'int16'); % 1630  set to 0
fwrite(fid, pc6h.nDACFileADCNum, 'int16'); % 1632 set to 0
fwrite(fid, pc6h.sDACFileName, 'schar'); % 12char % 1634 % set to spaces
fwrite(fid, pc6h.sDACFilePath, 'schar'); % 60char % 1646 set to spaces
fwrite(fid, pc6h.sUnused1706, 'schar'); % 12char % 1706

% Conditioning pulse train
fwrite(fid, pc6h.nConditEnable, 'int16'); % 1718 % set to 0
fwrite(fid, pc6h.nConditChannel, 'int16'); % 1720 0
fwrite(fid, pc6h.lConditNumPulses, 'int32'); % 1722 0
fwrite(fid, pc6h.fBaselineDuration, 'float32'); % 1726 0
fwrite(fid, pc6h.fBaselineLevel, 'float32'); % 1730 0
fwrite(fid, pc6h.fStepDuration, 'float32'); % 1734 0
fwrite(fid, pc6h.fStepLevel, 'float32'); % 1738 0
fwrite(fid, pc6h.fPostTrainPeriod, 'float32'); % 1742 0
fwrite(fid, pc6h.fPostTrainLevel, 'float32'); % 1746 0
fwrite(fid, pc6h.sUnused1750, 'schar'); % 12char % 1750 0

% variable parameter user list
fwrite(fid, pc6h.nParamToVary, 'int16'); % 1762 % set to 0
fwrite(fid, pc6h.sParamValueList, 'schar'); % 80char % 1764 % set to 0

% statistics measurement
fwrite(fid, pc6h.nAutopeakEnable, 'int16'); % 1844 % set to 0
fwrite(fid, pc6h.nAutopeakPolarity, 'int16'); % 1846 % set to 0
fwrite(fid, pc6h.nAutopeakADCNum, 'int16'); % 1848 % set to 0
fwrite(fid, pc6h.nAutopeakSearchMode, 'int16'); % 1850 % set to -1
fwrite(fid, pc6h.lAutopeakStart, 'int32'); % 1852 % set to 0
fwrite(fid, pc6h.lAutopeakEnd, 'int32'); % 1856 % set to 0
fwrite(fid, pc6h.nAutopeakSmoothing, 'int16'); % 1860 % set to 3
fwrite(fid, pc6h.nAutopeakBaseline, 'int16'); % 1862 % set to =2
fwrite(fid, pc6h.nAutopeakAverage, 'int16'); % 1864 % set to 0
fwrite(fid, pc6h.sUnused1866, 'schar'); % 14char % 1866

% Channel arithmetic
fwrite(fid, pc6h.nArithmeticEnable, 'int16'); % 1880 % % set to 0
fwrite(fid, pc6h.fArithmeticUpperLimit, 'float32'); % 1882 0
fwrite(fid, pc6h.fArithmeticLowerLimit, 'float32'); % 1886 0
fwrite(fid, pc6h.nArithmeticADCNumA, 'int16'); % 1890 0
fwrite(fid, pc6h.nArithmeticADCNumB, 'int16'); % 1892 0
fwrite(fid, pc6h.fArithmeticK1, 'float32'); % 1894 0
fwrite(fid, pc6h.fArithmeticK2, 'float32'); % 1898 0
fwrite(fid, pc6h.fArithmeticK3, 'float32'); % 1902 0
fwrite(fid, pc6h.fArithmeticK4, 'float32'); % 1906 0
fwrite(fid, pc6h.sArithmeticOperator, 'schar'); % 2char % 1910 '+'
fwrite(fid, pc6h.sArithmeticUnits, 'schar'); % 8char % 1912 % spaces
fwrite(fid, pc6h.fArithmeticK5, 'float32'); % 1920 0
fwrite(fid, pc6h.fArithmeticK6, 'float32'); % 1924 0
fwrite(fid, pc6h.nArithmeticExpression, 'int16'); % 1928 set to 1
fwrite(fid, pc6h.sUnused1930, 'schar'); % 2char % 1930

% Online subtraction
fwrite(fid, pc6h.nPNEnable, 'int16'); % 1932  % set to 0
fwrite(fid, pc6h.nPNPosition, 'int16'); % 1934 % set to 0
fwrite(fid, pc6h.nPNPolarity, 'int16'); % 1936 % set to -1
fwrite(fid, pc6h.nPNNumPulses, 'int16'); % 1938 set to 1
fwrite(fid, pc6h.nPNADCNum, 'int16'); % 1940 set to 1
fwrite(fid, pc6h.fPNHoldingLevel, 'float32'); % 1942 set to 0
fwrite(fid, pc6h.fPNSettlingTime, 'float32'); % 1946 set to 1
fwrite(fid, pc6h.fPNInterpulse, 'float32'); % 1950 set to 1
fwrite(fid, pc6h.sUnused1954, 'schar'); % 12char % 1954

% Miscellaneous elements placed in "unused space at end of header block"
fwrite(fid, pc6h.nListEnable, 'int16'); % 1966 set to 0
fwrite(fid, pc6h.sUnused1966, 'schar'); % 80char % 1968 set to 0's

% now write the data. The data is stored 8 blocks out, as a continuous.
datafmt=pc6h.nDataFormat;

cn = pc6h.nAutosampleADCNum + 1;

pc6h.fGain=pc6h.fInstrumentScaleFactor.*pc6h.fAutosampleAdditGain;
pc6h.fGain=pc6h.fGain'.*pc6h.fADCProgrammableGain.*pc6h.fSignalGain;

gain = pc6h.fADCRange / pc6h.lADCResolution / (pc6h.fInstrumentScaleFactor(cn) * pc6h.fAutosampleAdditGain * pc6h.fADCProgrammableGain(cn) * pc6h.fSignalGain(cn)) ;
offset = pc6h.fSignalOffset(cn);
ns = pc6h.lActualAcqLength / pc6h.lActualEpisodes;
dpos = (pc6h.lDataSectionPtr-1) * 512;
% can't position past end of currently written file, so
% we must fill the space in between with empty...
cpos = ftell(fid);
if(cpos < dpos)
   filler = zeros(1, dpos-cpos+1);
   fwrite(fid, filler, 'schar');
end;
% now we can write.

chunksize = 512; % gapfree chunksize is 8192 bytes.
en = 1;
switch(datafmt)
case 0 % 2 byte integer format.
   fseek(fid, dpos, 'bof');
   data = 0.5 + (data - offset) / gain;
   fwrite(fid, data, 'int16');
   leftover = rem(length(data)*2, chunksize); % left over bytes (int 16 writes...)
   za = zeros(1, length(leftover));
   fwrite(fid, za, 'int16'); % fill with zeros
case 1 % 4 byte floating format
   fseek(fid, dpos + (en-1) * ns, 'bof');
   fwrite(fid, data, 'float32');
   leftover = rem(length(data)*4, chunksize); % left over bytes.
   za = zeros(1, length(leftover));
   fwrite(fid, za, 'int16'); % fill with zeros.
otherwise
end;
filler = zeros(1, chunksize);
fwrite(fid, filler, 'schar'); % this seems to be important, even if there's nothing there.

% then close the file
fclose(fid);
err = 0; % success!
return;

