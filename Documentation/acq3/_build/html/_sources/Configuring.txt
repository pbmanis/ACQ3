=======================================
Setting Stimulus And Recording Scaling
=======================================

Before commencing experiments, it is necessary to set up the stimulus
parameter files. The way in which the program deals with the scaling
of the data depends on these files, and there are several factors
which interact. The ultimate indicator is the displayed data, which
corresponds exactly to the numeric values of the data stored in the
file.

-------------------------
Configuration parameter
-------------------------
In the configuration block, there is an entry for the amplifier type.
The program recognizes several amplifiers from Axon Instruments,
including the AxoProbe 1A (discontinued), the Axopatch 200 series, and
the Multiclamp 700A. To get correct scaling for these amplifiers, you
must enter the name of the amplifier in the field: edit config;
amplifier axopatch, and save the configuration file. Additional
amplifiers can be supported by editing the acquire_one.m file in the
appropriate section.

----------------
Stimulus Scaling
----------------

There is no independent control of the stimulus scaling; it is set
automatically according to the amplifier type and data collection mode
(voltage or current clamp) in the acquire_one.m routine.

-----------------
Recording Scaling
-----------------

The recording scaling is a function of three different factors: the
intrinsic gains of the amplifier, the setting of the gain selector on
the output of the amplifier (for Axopatch and Multiclamp amplifiers),
and the data collection mode. Recording scaling is controlled by the
sensor parameter in the acquisition parameter block (edit
acquisition). Typically these sensor values are large, rounded
positive numbers, and there is a separate value for each channel
collected. For example, to set the multiclamp commander, with the
output gain set for 2 (corresponding to 1V/nA), the command::

    sensor[40, 2]

will produce the correct data scaling. Note that in voltage clamp, the
current channel is collected first, so this corresponds to a channel
list (for example) of::

    channel[11]

where the current output of the amplifier is connected to A/D input
11, and the voltage output is connected to A/D input 3.
The recording scaling is also affected by the amplifier gain. For the
Axoprobe, this is fixed in the software (10x for voltage, 1nA/V for
the current), but for the Axopatch, the gain is read from the
telegraph inputs, and is dependent on the mode (voltage or current
clamp). For the Multiclamp, telegraphs are available, but we cannot
read them into MATLAB yet, so it is treated as a fixed gain system, for
which you will have to write down any variations from the standard
gain settings.

In practice, setting the channel sensor factors is fairly easy,
assuming that you have an independent way to verify the different
outputs of the system.

Once the sensor values are set, it is a good idea to write a short
MATLAB script to update these values, based on the ``setcc`` and ``setvc``
scripts found in the source directory. In this way, you add a command
to the system that sets the gains automatically whenever you wish to
design a new stimulus or acquisition protocol. A smart script would
read the current configuration (global CONFIG), to get the amplifier
type (in CONFIG.Amplifier.v), and set the gains accordingly.


