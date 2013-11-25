==================
Utility Commands
==================

-----------------------
Index of the Data File
-----------------------

There are two routines for viewing the index of the data file. The
first is ``lif`` (List IndexFile), which simply prints out to the
MATLAB window the index file information. A more complete listing of
the file can be obtained with the ``pf`` (print file) command. This lists
the index, followed by information about each block including all of
the note entries. You should consider making a hardcopy of this result
and saving it for future reference.

----------------
Displaying data
----------------

The display settings for voltage and current can be modified. The
command ``vdis min max`` sets the voltage display minimum and maximum
values. Data outside this range is clipped and not displayed. The
command ``idis min max`` works similarly for the current traces.
Data can be displayed after it has been collected using the db
(display block) command. This command operates in one of two ways. If
a file is currently open, then the command ``db block#`` will display ALL
of the data in that block (there is no way to display individual
records). If there is no file open, then the command db block#
filename will display the requested data block from the specified
file. The data is displayed into the data window using the current
display settings.

The drop-down menu under display permits modification of display
parameters for multiple channels.

---------
Valves
---------
Solution delivery can be commanded from the program by using the ``valve``
command. This requires a separate hardware interface, and is
controlled through the digital IO lines of the acquisition hardware.
See me for details.
