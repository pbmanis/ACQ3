=======
Acq3
=======

ACQ : A Data Acquisition Program for Cellular Neurophysiology Based on
the MATLAB Data Acquisition Toolbox

    Version 3.0 (March 28, 2008)
    
    Paul B. Manis, Ph.D. and
    Scott C. Molitor, Ph.D.
    Depts. of Otolaryngology/Head and Neck Surgery,
    and Cell and Molecular Physiology,
    The University of North Carolina at Chapel Hill

============
Introduction
============
ACQ is a basic, extensible, data acquisition program for
electrophysiology and biophysical studies of ion channels, based on
the MATLAB (Mathworks) data acquisition toolbox. The program should
serve the same purposes as pClamp (Axon Instruments), or a DOS
program, DATAC. The program provides control of data acquisition
(analog-to-digital conversion) and experimental protocols (stimulus
waveforms delivered with digital-to-analog converters) through a set
of m-files. Currently the program is focussed on acquiring data in
response to current or voltage steps, pulse trains, alpha waveforms,
or noise, and storing the data in MATLAB files on disk. Analysis is the
domain of subsequent programs (such as the MATLAB version of DATAC).
This document describes the operation of ACQ, as well as information
necessary to write new stimulus modes or to add macros.

------------
Known bugs
------------
::
    Because the program operates in an event-driven mode, it is
    possible to initiate multiple actions that conflict with each other
    when using the GUI/mouse controls. Carefully click once to use the
    mouse-driven menu items. We have included more lock-out code to
    minimize problems, but by avoiding the temptation to click madly, the
    programs behavior will be more predictable.
    
    Gapfree acquisition is not working. However, you can collect very
    long stretches of data.

------------------------
Changes from version 2.5
------------------------
The method of setting the configuration has been modified. The
configuration is now held as a text file, with an extenstion of .ini.
The text files have a specific structure. See the ?? section. This is
a major change that should help move acquisition protocols from one
rig to another with different amplifiers.
Online analyses have been updated and some analyses fixed.
The model (used for testing) has been updated.
Acquisition timing has been improved.
Telegraph communication with the Multiclamp amplfiers has been
changed. We now use an FTP server protocol (set up by Luke Campangola)
to talk to the Multiclamp Commander. All parameters can be changed or
read from the program, although at the moment only a subset of
parameters are used. This communication allows the program to control
the mode of the amplifier automatically, so that it can switch between
current and voltage clamp automatically without user intervention.

--------------------
Document conventions
--------------------
Program commands are given in fixed-point type. Optional arguments are
enclosed with[braces]. Words used in a special context are italicized
when first used.



