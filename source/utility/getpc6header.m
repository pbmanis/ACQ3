function [pc6h] = getpc6header(fid);
%GETPC6HEADER Get header information from a pClamp 6.x Axon Binary File (ABF).
%   PC6H = GETPC6HEADER(FID) returns a structure with all header information.
%   ABF files should be opened with the appropriate machineformat (IEEE floating
%   point with little-endian byte ordering, e.g., fopen(file,'r','l').
%   For a description of the fields, see the "abf.asc" file included with the 
%   "Axon PC File Support Package for Developers".
%
%   FID is an integer file identifier obtained from FOPEN.

%   Carsten Hohnke 12/99

% Mods and updated for version 1.5, P. Manis, 2/2002
%

if fid == -1, % Check for invalid fid.
   error('getpc6header: Invalid fid.');
end
fseek(fid,0,'bof'); % Set the pointer to beginning of the file.

pc6h.size=2048;

% file ID and size information
pc6h.sFileType=fread(fid,4,'char'); % pointing to byte 0 ('ABF')
pc6h.fFileVersionNumber=fread(fid,1,'float'); % 4 (1.5 for current file)
pc6h.nOperationMode=fread(fid,1,'short'); % 8  (3 = gapfree).
pc6h.lActualAcqLength=fread(fid,1,'int'); % 10 (total ADC samples in file)
pc6h.nNumPointsIgnored=fread(fid,1,'short'); % 14 (0)
pc6h.lActualEpisodes=fread(fid,1,'int'); % 16 (1 for gapfree, otherwise # sweeps)
pc6h.lFileStartDate=fread(fid,1,'int'); % 20 (yymmdd)
pc6h.lFileStartTime=fread(fid,1,'int'); % 24 (seconds past midnight)
pc6h.lStopwatchTime=fread(fid,1,'int'); % 28 (0)
pc6h.fHeaderVersionNumber=fread(fid,1,'float'); % 32 (1.5)
pc6h.nFileType=fread(fid,1,'short'); % 36 (1 = ABF)
pc6h.nMSBinFormat=fread(fid,1,'short'); % 38 (0 for IEEE format...)

% file structure
pc6h.lDataSectionPtr=fread(fid,1,'int'); % 40 (block number of DATA section)
pc6h.lTagSectionPtr=fread(fid,1,'int'); % 44 (block number of Tag section)
pc6h.lNumTagEntries=fread(fid,1,'int'); % 48 (Number of Tag entries)
pc6h.lLongDescriptionPtr=fread(fid,1,'int'); % 52 (Block number of Scope Config Pointer)
pc6h.lLongDescriptionLines=fread(fid,1,'int'); % 56 (Number of Scope Config sections)
pc6h.lDACFilePtr=fread(fid,1,'int'); % 60 (block number of start of DAC section)
pc6h.lDACFileNumEpisodes=fread(fid,1,'int'); % 64 (number of sweeps in DAC sectoin)
pc6h.sUnused68=fread(fid,4,'char'); % 4char % 68 (unused)
pc6h.lDeltaArrayPtr=fread(fid,1,'int'); % 72 (block number of Delta array section)
pc6h.lNumDeltas=fread(fid,1,'int'); % 76 (number of entries in Delta array section)
pc6h.lNotebookPtr=fread(fid,1,'int'); % 80 (block number of voice tag section)
pc6h.lNotebookManEntries=fread(fid,1,'int'); % 84 (number of voice tag entries)
pc6h.lNotebookAutoEntries=fread(fid,1,'int'); % 88 (unused)
pc6h.lSynchArrayPtr=fread(fid,1,'int'); % 92 (block number of synch array section_
pc6h.lSynchArraySize=fread(fid,1,'int'); % 96 (number of PAIRS of entries in synch array section)
pc6h.nDataFormat=fread(fid,1,'short'); % 100 (data representation: 0 = 2-byte integer, 1 = IEEE 4 byte float)
pc6h.nSimultaneousScan=fread(fid, 1, 'short'); % 102 (ADC channel scanning mode 0=mux, 1=simul; NOT IMPLEMENTED)
pc6h.sUnused102=fread(fid,16,'char'); % 18char % 102 (

% Trial hierarhcy information
pc6h.nADCNumChannels=fread(fid,1,'short'); % 120 (number of analog input channels sampled)
pc6h.fADCSampleInterval=fread(fid,1,'float'); % 122 (interval between multiplexed channels)
pc6h.fADCSecondSampleInterval=fread(fid,1,'float'); %  % 126 (when switching clocks)
pc6h.fSynchTimeUnit=fread(fid,1,'float'); % 130 (synch array time unit: 0 = samples, nn = usec. normally 0)
pc6h.fSecondsPerRun=fread(fid,1,'float'); % 134 (gapfree: duration of acq; otherwise set to -1 (ignore and refer to lEpisodesPerRun))
pc6h.lNumSamplesPerEpisode=fread(fid,1,'int'); % 138 (# muxed ADC samples per sweep if mode is 2, 4 or 5; undefined if mode is 1 or 3)
pc6h.lPreTriggerSamples=fread(fid,1,'int'); % 142 (pretrigger intervals = 0)
pc6h.lEpisodesPerRun=fread(fid,1,'int'); % 146 (sweeps per run.  if gapfree, set to 1.
pc6h.lRunsPerTrial=fread(fid,1,'int'); % 150 (runs per trial. if gapfree, set to 1.
pc6h.lNumberOfTrials=fread(fid,1,'int'); % 154 (set to 1)
pc6h.nAveragingMode=fread(fid,1,'short'); % 158 (0 = no averaging)
pc6h.nUndoRunCount=fread(fid,1,'short'); % 160 set to -1
pc6h.nFirstEpisodeInRun=fread(fid,1,'short'); % 162 (set to 1)
pc6h.fTriggerThreshold=fread(fid,1,'float'); % 164 (user units: set to 0)
pc6h.nTriggerSource=fread(fid,1,'short'); % 168 (set to -1 for external, > 0 for physical channel number, -3 for start-to-start interval)
pc6h.nTriggerAction=fread(fid,1,'short'); % 170 (0 = one sweep, 1 = one run, 2 = one trial)
pc6h.nTriggerPolarity=fread(fid,1,'short'); % 172 (0 = rising, 1 == falling)
pc6h.fScopeOutputInterval=fread(fid,1,'float'); % 174 (set to 0)
pc6h.fEpisodeStartToStart=fread(fid,1,'float'); % 178 (time between start of sweeps, in seconds = cycle time)
pc6h.fRunStartToStart=fread(fid,1,'float'); % 182 (time between start of runs (seconds)
pc6h.fTrialStartToStart=fread(fid,1,'float'); % 186 (time between trials (seconds)
pc6h.lAverageCount=fread(fid,1,'int'); % 190 (number of runs for each average: set to 1)
pc6h.lClockChange=fread(fid,1,'int'); % 194 (# samples after which second sampling interval begins: set to -1)
pc6h.nAutoTriggerStrategy=fread(fid,1,'short'); % 2char % 198 (0 = do not auto trig; 1 = autotrig; only when nOpmode = highspeed osc).

% display parameters
pc6h.nDrawingStrategy=fread(fid,1,'short'); % 200 (0 = not draw, 1 = update immed.... set to 0)
pc6h.nTiledDisplay=fread(fid,1,'short'); % 202 (set to 0)
pc6h.nEraseStrategy=fread(fid,1,'short'); % 204 (set to 2)
pc6h.nDataDisplayMode=fread(fid,1,'short'); % 206 (set to 1 = lines)
pc6h.lDisplayAverageUpdate=fread(fid,1,'int'); % 208 (set to -1)
pc6h.nChannelStatsStrategy=fread(fid,1,'short'); % 212 (set to 0)
pc6h.lCalculationPeriod=fread(fid,1,'int'); % 214 (set to 16384)
pc6h.lSamplesPerTrace=fread(fid,1,'int'); % 218 (number of multiplexed adc samples displayed per trace)
pc6h.lStartDisplayNum=fread(fid,1,'int'); % 222 (set to 1)
pc6h.lFinishDisplayNum=fread(fid,1,'int'); % 226 (set to 0 to finish at end of sweep)
pc6h.nMultiColor=fread(fid,1,'short'); % 230 (set to 1 for multicolor)
pc6h.nShowPNRawData=fread(fid,1,'short'); % 232 (set to 0 for display corrected data
pc6h.fStatisticsPeriod=fread(fid, 1, 'float'); % 234 set to 0
pc6h.lStatisticsMeasurements=fread(fid, 1, 'long'); % 238   set to 0
pc6h.nstatisticsSaveStrategy=fread(fid, 1, 'short'); % 242 set to 0 for auto

% hardware information
pc6h.fADCRange=fread(fid,1,'float'); % 244  ADC-full scale (5 or 10 V)
pc6h.fDACRange=fread(fid,1,'float'); % 248  DAC full scale (10V)
pc6h.lADCResolution=fread(fid,1,'int'); % 252 number of adc counts corresponding to full scale voltage: 2048 or 16384
pc6h.lDACResolution=fread(fid,1,'int'); % 256 dac counts for full scale.... 

% Environment information
pc6h.nExperimentType=fread(fid,1,'short'); % 260 % 0 for voltage clamp, 1 for current clamp
pc6h.nAutosampleEnable=fread(fid,1,'short'); % 262 % set to 0 (disabled)
pc6h.nAutosampleADCNum=fread(fid,1,'short'); % 264 % physical sample number for autosample: set to 1
pc6h.nAutosampleInstrument=fread(fid,1,'short'); % 266 % instrument: set to 0 (unknown)
pc6h.fAutosampleAdditGain=fread(fid,1,'float'); % 268 % additional gain multiplier (set to gain reading or 1)
pc6h.fAutosampleFilter=fread(fid,1,'float'); % 272 % low pass filter (set to LPF reading or 100000)
pc6h.fAutosampleMembraneCapacitance=fread(fid,1,'float'); % 276 cap : set to 0 (not read)
pc6h.nManualInfoStrategy=fread(fid,1,'short'); % 280 set to 0.
pc6h.fCellID1=fread(fid,1,'float'); % 282 numeric cell identifier (set to 1)
pc6h.fCellID2=fread(fid,1,'float'); % 286 numeric identifier (set to 0)
pc6h.fCellID3=fread(fid,1,'float'); % 290 numeric identifier (set to 0)
pc6h.sCreatorInfo=fread(fid,16,'char'); % 16char % 294 write as "Clampex 6.0" 
pc6h.sFileComment=fread(fid,56,'char'); % 56char % 310 56 byte ascii comment string (copy comment here)
pc6h.sUnused366=fread(fid,12,'char'); % 12char % 366 unused

% Multichannel information
pc6h.nADCPtoLChannelMap=fread(fid,16,'short'); % 378 physical to logical channel map (end with -1 if fewer than 16)
pc6h.nADCSamplingSeq=fread(fid,16,'short'); % 410 ADC sampling sequence (pad with -1 if fewer than 16)
pc6h.sADCChannelName=fread(fid,16*10,'char'); % 442 channel names (set to spaces)
pc6h.sADCUnits=fread(fid,16*8,'char'); % 8char % 602 user units for adc (set to spaces)
pc6h.fADCProgrammableGain=fread(fid,16,'float'); % 730 adc programmable gain (read it or set to 1)
pc6h.fADCDisplayAmplification=fread(fid,16,'float'); % 794 (set to 1: array)
pc6h.fADCDisplayOffset=fread(fid,16,'float'); % 858 (set to 0: array)
pc6h.fInstrumentScaleFactor=fread(fid,16,'float'); % 922 (set to 1: array)
pc6h.fInstrumentOffset=fread(fid,16,'float'); % 986 (set to 0 array) 
pc6h.fSignalGain=fread(fid,16,'float'); % 1050 (set to 1 array)
pc6h.fSignalOffset=fread(fid,16,'float'); % 1114 (set to 0 array)
pc6h.fSignalLowpassFilter=fread(fid,16,'float'); % 1178 (set to 100000 array)
pc6h.fSignalHighpassFilter=fread(fid,16,'float'); % 1242 (set to 0 array)
pc6h.sDACChannelName=fread(fid,4*10,'char'); % 1306 (set to spaces)
pc6h.sDACChannelUnits=fread(fid,4*8,'char'); % 8char % 1346 (set to spaces)
pc6h.fDACScaleFactor=fread(fid,4,'float'); % 1378 (dac channel gains: set to 1)
pc6h.fDACHoldingLevel=fread(fid,4,'float'); % 1394 (set to 0)
pc6h.nSignalType=fread(fid,1,'short'); % 12char % 1410 (set to 0 for no signal conditioner)
pc6h.sUnused1412=fread(fid,10,'char'); % 10char % 1412

% synchronous timer outputs
pc6h.nOUTEnable=fread(fid,1,'short'); % 1422 % set to 0
pc6h.nSampleNumberOUT1=fread(fid,1,'short'); % 1424 % set to 0
pc6h.nSampleNumberOUT2=fread(fid,1,'short'); % 1426 % set to 0
pc6h.nFirstEpisodeOUT=fread(fid,1,'short'); % 1428 % set to 0
pc6h.nLastEpisodeOUT=fread(fid,1,'short'); % 1430 % set to 0
pc6h.nPulseSamplesOUT1=fread(fid,1,'short'); % 1432 % set to 0
pc6h.nPulseSamplesOUT2=fread(fid,1,'short'); % 1434 % set to 0

%Epoch waveform and pulses
pc6h.nDigitalEnable=fread(fid,1,'short'); % 1436 % set to 0
pc6h.nWaveformSource=fread(fid,1,'short'); % 1438 % set to 0
pc6h.nActiveDACChannel=fread(fid,1,'short'); % 1440 % set to 0
pc6h.nInterEpisodeLevel=fread(fid,1,'short'); % 1442 % set to 0
pc6h.nEpochType=fread(fid,10,'short'); % 1444 % set to 0
pc6h.fEpochInitLevel=fread(fid,10,'float'); % 1464 % set to 0
pc6h.fEpochLevelInc=fread(fid,10,'float'); % 1504 % set to 0
pc6h.nEpochInitDuration=fread(fid,10,'short'); % 1544 % set to 0
pc6h.nEpochDurationInc=fread(fid,10,'short'); % 1564 % set to 0
pc6h.nDigitalHolding=fread(fid,1,'short'); % 1584 % set to 0
pc6h.nDigitalInterEpisode=fread(fid,1,'short'); % 1586 % set to 0
pc6h.nDigitalValue=fread(fid,10,'short'); % 1588 ^% set to 0
pc6h.fWaveformOffset=fread(fid,1,'float'); % 1608 % set to 0
pc6h.sUnused1612=fread(fid,8,'char'); % 8char % 1612

% DAC output file
pc6h.fDACFileScale=fread(fid,1,'float'); % 1620 % set to 1
pc6h.fDACFileOffset=fread(fid,1,'float'); % 1624 % set to 0
pc6h.sUnused1628=fread(fid,2,'char'); % 2char % 1628 % unused
pc6h.nDACFileEpisodeNum=fread(fid,1,'short'); % 1630  set to 0
pc6h.nDACFileADCNum=fread(fid,1,'short'); % 1632 set to 0
pc6h.sDACFileName=fread(fid,12,'char'); % 12char % 1634 % set to spaces
pc6h.sDACFilePath=fread(fid,60,'char'); % 60char % 1646 set to spaces
pc6h.sUnused1706=fread(fid,12,'char'); % 12char % 1706

% Conditioning pulse train
pc6h.nConditEnable=fread(fid,1,'short'); % 1718 % set to 0
pc6h.nConditChannel=fread(fid,1,'short'); % 1720 0
pc6h.lConditNumPulses=fread(fid,1,'int'); % 1722 0
pc6h.fBaselineDuration=fread(fid,1,'float'); % 1726 0
pc6h.fBaselineLevel=fread(fid,1,'float'); % 1730 0
pc6h.fStepDuration=fread(fid,1,'float'); % 1734 0
pc6h.fStepLevel=fread(fid,1,'float'); % 1738 0
pc6h.fPostTrainPeriod=fread(fid,1,'float'); % 1742 0
pc6h.fPostTrainLevel=fread(fid,1,'float'); % 1746 0
pc6h.sUnused1750=fread(fid,12,'char'); % 12char % 1750 0

% variable parameter user list
pc6h.nParamToVary=fread(fid,1,'short'); % 1762 % set to 0
pc6h.sParamValueList=fread(fid,80,'char'); % 80char % 1764 % set to 0

% statistics measurement
pc6h.nAutopeakEnable=fread(fid,1,'short'); % 1844 % set to 0
pc6h.nAutopeakPolarity=fread(fid,1,'short'); % 1846 % set to 0
pc6h.nAutopeakADCNum=fread(fid,1,'short'); % 1848 % set to 0
pc6h.nAutopeakSearchMode=fread(fid,1,'short'); % 1850 % set to -1
pc6h.lAutopeakStart=fread(fid,1,'int'); % 1852 % set to 0
pc6h.lAutopeakEnd=fread(fid,1,'int'); % 1856 % set to 0
pc6h.nAutopeakSmoothing=fread(fid,1,'short'); % 1860 % set to 3
pc6h.nAutopeakBaseline=fread(fid,1,'short'); % 1862 % set to =2
pc6h.nAutopeakAverage=fread(fid,1,'short'); % 1864 % set to 0
pc6h.sUnused1866=fread(fid,14,'char'); % 14char % 1866

% Channel arithmetic
pc6h.nArithmeticEnable=fread(fid,1,'short'); % 1880 % % set to 0
pc6h.fArithmeticUpperLimit=fread(fid,1,'float'); % 1882 0
pc6h.fArithmeticLowerLimit=fread(fid,1,'float'); % 1886 0
pc6h.nArithmeticADCNumA=fread(fid,1,'short'); % 1890 0
pc6h.nArithmeticADCNumB=fread(fid,1,'short'); % 1892 0
pc6h.fArithmeticK1=fread(fid,1,'float'); % 1894 0
pc6h.fArithmeticK2=fread(fid,1,'float'); % 1898 0
pc6h.fArithmeticK3=fread(fid,1,'float'); % 1902 0
pc6h.fArithmeticK4=fread(fid,1,'float'); % 1906 0
pc6h.sArithmeticOperator=fread(fid,2,'char'); % 2char % 1910 '+'
pc6h.sArithmeticUnits=fread(fid,8,'char'); % 8char % 1912 % spaces
pc6h.fArithmeticK5=fread(fid,1,'float'); % 1920 0
pc6h.fArithmeticK6=fread(fid,1,'float'); % 1924 0
pc6h.nArithmeticExpression=fread(fid,1,'short'); % 1928 set to 1
pc6h.sUnused1930=fread(fid,2,'char'); % 2char % 1930

% Online subtraction
pc6h.nPNEnable=fread(fid,1,'short'); % 1932  % set to 0
pc6h.nPNPosition=fread(fid,1,'short'); % 1934 % set to 0
pc6h.nPNPolarity=fread(fid,1,'short'); % 1936 % set to -1
pc6h.nPNNumPulses=fread(fid,1,'short'); % 1938 set to 1
pc6h.nPNADCNum=fread(fid,1,'short'); % 1940 set to 1
pc6h.fPNHoldingLevel=fread(fid,1,'float'); % 1942 set to 0
pc6h.fPNSettlingTime=fread(fid,1,'float'); % 1946 set to 1
pc6h.fPNInterpulse=fread(fid,1,'float'); % 1950 set to 1
pc6h.sUnused1954=fread(fid,12,'char'); % 12char % 1954

% Miscellaneous elements placed in "unused space at end of header block"
pc6h.nListEnable=fread(fid,1,'short'); % 1966 set to 0
pc6h.sUnused1966=fread(fid,80,'char'); % 80char % 1968 set to 0's

