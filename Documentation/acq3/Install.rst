============
Installation
============
The program is installed by copying the .m files to their appropriate
directories. The directory structure is simple. Under the top
directory (\mat_datac\acq), are the following:AcqPar (holds
acquisition parameter files), StmPar (holds stimulus files), Macros
(holds macro files), configs, and source (all m-files that are
accessible as commands must reside in the source directory). Under
source are two directories: private and utility. These are the m-files
that are not accessible as commands from the command box. m-files in
the private directory are only accessible from the source directory,
but not theutility directory. Routines placed in the utility directory
need to be cognizant of this organization.
Once the files have been copied, a initial set of stimulus and
acquisition files can be generated with the command make_standard.
When this routine exits, a basic set of files can be found in the
StmPar and AcqPar directories. It is recommended that a routine
similar to this be created to allow you to automatically regenerate in
a standard way any stimulus protocols you might use.
All of the routines necessary for the program are found ini the source
directory and the directories below it. The MATLAB path is modified to
include both the source andsource\utility directories when the program
starts. To do this, you must go to the directory where ACQ is present,
and run it, after which it should be sufficient to start it from the
MATLAB command line. A good way to do this in new versions of MATLAB is
to add a starting script to the MATLAB shortcuts list that appears just
beneath theMATLAB toolbar.

The program requires a working copy of MATLAB, with the Data
Acquisition and Signal Processing Toolboxes.

==============
Configuration
==============
The basic configuration is controlled by files located in the config
subdirectory. The choice of the configuration file is selected by a
drop-down list when the program is started. The program is provided
with a default file, called default.mat, which can be modified and
renamed for each configuration that is desired. Thus, each user, or
each users experiment, can be organized by using the configurations,
and appropriate subdirectories. Note that after a configuration file
is created, it can only be loaded by exiting and restartingACQ.
Details on configuring the program for specific amplifiers can be
found in Section F.

======================
Hardware Configuration
======================
ACQ uses the MATLAB Data Acquisition Toolbox. Any hardware supported by
this toolbox can be used for acquisition; the program has been tested
with 12 and 16 bit boards from National Instruments. In principle, the
Windows sound card can also be used, although this is neither
recommended nor fully implemented at present since it is only AC
coupled and has limited input/output rates. We use NI6052E, NI6251 and NI 6559 boards,
with the BNC2090 chassis.

-------------
Connections
-------------

Configure NI boards as follows::

    Triggering

    Connect PFI0/Trig1 to User1 (via a short BNC cable)
    Connect DIO1 to User1 (use a wire jumper)
    Connect DIO0 to PFI6 (use a wire jumper)
    OR:
    Connect PFIO/Trig1 to PFI16 and to DIO1.

The analog signals can be connected to any of the A-D input channels.
Select NRSE mode for all channels by setting the appropriate switches
on the BNC2090. The channels actually sampled and their order are set
in the acquisition parameter file. However, if you are using an
Axopatch amplifier, such as the Axopatch 200, 200A or 200B, from Axon
Instruments (now owned by Molecular Devices), and wish to read the
telegraphs, you MUST connect the telegraphs as follows::

    AmplifierMODEtelegraphtoA-D  input13.
    
    AmplifierGAINtelegraphtoA-D  input14.
    
    AmplifierFILTERtelegraphtoA-D  input15.


If you wish to control an external set of valves, you will need to
connect lines from the digital IO port to the valve TTL input. The
program sets DIO lines 5-8 to control up to 4 valves.
