====================================
Design Considerations And History
====================================

One of the general goals in writing this program was to include
sufficient flexibility that the end user can readily customize the
program. To this end we chose to let MATLAB do as much of the work as
possible, and we chose to allow the user access to the capabilities of
MATLAB rather than having the program take complete control. The
program as provided and described herein provides a strong set of
basic commands, protocols, and simple data storage. In addition, the
end user can write macros (functions) in the MATLAB language to extend
the program.

In ACQ, we have adopted the use of keyboard input rather than mouse-
directed input, because it is generally easier and faster during an
experiment to type short commands at the keyboard than it is to
navigate a mouse through a set of menus. We have tried to implement
the interaction system in a way to allow brief commands from the
keyboard, as in the predecessor program, DATAC, because we have found
that during an experiment this is the most expedient way to send
commands to the computer. Nonetheless, a few graphical mouse items are
necessary (e.g., buttons) because of the callback structure of MATLAB,
which is used in ACQ, and the observation that MATLAB does not always
respond to the keyboard when certain tasks are being performed, but it
will respond to mouse clicks.

A second design decision in ACQ is that data structures should drive
the program. All relevant information necessary to perform an
acquisition protocol is held in data structures, and these structures
are also made part of the archival data file. The structures invoke
routines to generate stimuli, and drive the acquisition engine. From
these structures, it should be possible to derive all features of the
acquired data and stimulus. Presently, two structures (the stimulus
and acquisition structures) completely determine how stimuli are
generated and how the data is acquired. A third structure, the note
structure, is used to store ancillary information about the experiment
in a text form. A fourth structure informs the program about the
general configuration of the program directories and the hardware, and
has no information necessary for the analysis.

One might ask why we have chosen to use MATLAB? The answer to this
question lies partially in the prior choices and experience with
digital data acquisition for electrophysiology on a number of
platforms (Data General, 1975-76; DEC PDP 11-40 (RT-11), 1977-1982;
DEC PDP8 (LINK/FOCAL) and PDP 11-34 (TSX/RSX), 1982-1985, 8088, 80286,
80386, 80486, 80586/PC, 1985-1999, DOS 3.1-6.0, Windows 3.11, 95, 98).
Our previous data acquisition program, DATAC, was written originally
by Daniel Bertrand in C. This program had modules for array
computation, data display and figure construction, data acquisition,
and a macro facility. The program, originally written in 1985, ran
only under DOS (although versions for the Mac and Sun systems using a
graphical interface were generated). In the Manis laboratory, the
program was extended to have a more powerful macro facility, extended
array functions, and especially a powerful, fairly flexible, data
acquisition engine, while remaining in the DOS environment. This
program served well, was relatively free of bugs, and was easy to
operate for data acquisition.

However, the program has neared the end of its useful lifetime for
several reasons. DOS is no longer properly supported, and the
supported data hardware (Axon Instruments DIGIDATA 1200 board, or the
Manis-Bertrand board) uses the ISA bus, which has nearly disappeared
from the current computer bus options. Rather than rewrite DATAC under
Windows (a somewhat problematic task, given the direct interaction of
the program with the hardware and the DMA controller in the PC), it
was felt that a more general approach should be used. The approach
should in particular provide a short development cycle, a strong and
robust mathematical and graphic support facility, and make it easier
for end users to extend the program for specific experiments.
Originally, Origin (Microcal) was considered as a platform, since a
GUI-based interface can be easily implemented and DLLs can written to
control hardware. However the scripting language used by Origin,
LabTalk, was found to be inconsistent and buggy, poorly typed, and
overall both awkward and cumbersome.MATLAB provides all of the
facilities of DATAC(including array processing, graphics or plotting
functions) with few of the original limitations, and furthermore has a
proper language syntax. With the advent of the Data Acquisition
Toolbox (or the wrapper programs for the NIDAQ library that are
available), it became feasible to use MATLAB to replace nearly all of
the functions of DATAC without having to write code for the basic
engine. Furthermore, MATLAB runs well under Windows, Mac and Linux
operating systems, so data analysis components should be platform
independent (to a limited extent, this might be true for data
acquisition between Windows and Mac; there is currently no complete
library for Linux.). Thus, MATLAB seemed a logical choice, and perhaps
is better than DATAC because of the extensive library of routines and
the ability to rapidly extend the useful language with either C-coded
mex files that act like MATLAB commands, or m-files.
The resulting program operates somewhat similarly to DATAC in that it
has a display structure roughly based on the DATAC display, and has
commands that are similar or identical to those in the
DATAC acquisition engine. However, the program is more flexible and
more easily modified than DATAC since it is not compiled, and it has
significantly greater capability and flexibility in acquisition and
stimulus generation. Furthermore, its development time was
considerably shorter than that of DATAC: about 2 months of direct
programming time, versus an estimate of 8 months overall for the
acquisition engine in DATAC. The cost however is that the minimum
computer requirements are currently a 400 Mhz or faster PC, running
Windows 98. The resulting data files are also significantly larger,
due to the use of single floating point format for storing data (as
opposed to integer storage in DATAC), and the storage of a
significantly larger body of ancillary information (such as stimulus
waveforms) that ultimately should make analysis easier and more
accurate.

Finally, the ultimate success of this program lies in its use. We have
now used the program for all data collection in my lab for nearly a
year. There have been and may still be a few bugs, and operation is
not quite as smooth as I would like, but progress is being made.
Although I initially disliked the GUI control (menus, etc), I find
myself using it more, and plan to include GUI control for the stimulus
parameters similar to that implemented for the pulse protocol for
secondary channels. I am satisfied that the program serves its purpose
as designed and that it does allow us to collect data in a much more
flexible way than before. New stimulus protocols have been written
(usually taking only a few hours for coding and testing). Routines
have been written to access the data structure and pass data to my
data analysis program, and the data has been correctly analyzed. New
commands have been added with minimal work. Complex stimulus step
protocols have been designed and are found to work correctly.
