=============
Operation
=============

------------
Running ACQ 
------------

ACQ is run from within MATLAB. To run ACQ, first start MATLAB and type
``acq`` at the prompt. The program initializes its internal variables,
sets paths to various files from a default configuration file
(``config/default.mat``), allows the user to select a profile (user-
dependent directories and parameters) and registers the
MATLAB functions (``\*.m`` files) present in the ``./source`` directory as valid
commands (these are the only commands recognized).
The program may be exited with the command ``bye``; this should close all
windows associated with the program. Alternatively, use ``File - Quit``
from the menu.

------------
Display
------------

The program window is designed to take the full area of a 1024x768
display. It should not be necessary to view any other windows. (When
using the Multiclamp Commander from Axon/MDS, it is convenient to position
it over the parameter display area as described below). The display is
divided into a four functionally distinct areas. First, down the left
hand side there is a margin that holds several control buttons
(described below). Second, the top of the next column holds the
command line area (white box), the message area (grey box), and the
status area (labeled blue boxes). Third, below this is the parameter
display area, which shows the current settings for the selected
parameter sets. Fourth, the right hand side of the display contains
the graphics, and is divided into 3 areas. The top area has 2
vertically stacked graphs that display the output data waveforms for
the two digital-to-analog convertor (DAC) channels. The default
waveform for a stimulus generation (the one that is played out in
scope mode) is shown in red, and the remainder are shown in white.
Below this are two graphs that are used for on-line analysis.
Currently, they are not programmable, and some stimulus generation
routines may use these graphs to summarize the stimulus. Below these
are two (or more) large graphs, which display the response data and
the recorded stimulus waveforms. When the data is collected in scope
mode, or is otherwise not being stored to disk, it is displayed with
green lines and the axes are shown in gray. When data is being
collected and stored on disk, the display lines are white, and the
background axes and grid are blue.

--------------------
Program Interaction
--------------------

Commands may be given to the program either through the keyboard, or
through selection of menu items and graphical interface elements. This
section describes how to use the keyboard input. Commands entered at
the keyboard are echoed in the field in the upper left hand corner of
the screen (white area); when the window has focus, any characters
entered at the keyboard should appear in that area. Currently, there
is no text editor per se, but a limited editing function is provided
by the backspace and delete keys. Commands are entered one to a line,
and terminated with the Enter key. A command buffer history is
provided, which is accessed through the ``Control-U`` (up or back in the
history) and ``Control-D`` (down, or forward in the history) keys.
Commands may be entered while the program is acquiring, but this will
stop the current acquisition. Stopping the acquisition with the space
bar is recommended, as the first character entered at the keyboard is
sometimes, but not always, lost during acquisition (this appears to be
a problem with the relative execution times of various routines).
There are no editable text fields on the screen that can be accessed
with the mouse; all fields are display only. Thus, if the window has
focus, it should accept commands.

There are several buttons on the screen, appearing on the left hand
margin. The ``PV`` button executes the preview function, which computes
the stimulus waveforms and displays the results in the stimulus
graphs. The ``scope`` button starts the program presenting the current
stimulus waveform (the one indicated in red in the stimulus waveform
window), but data is not stored. This is useful for setting up to
patch or search for a cell, or exploring changes in stimulus
parameters. The ``stop`` button ends ``scope`` mode, and also ends any data
acquisition, including acquisition initiated by macros. The next
button is ``take 1``, which causes the program to present one stimulus and
collect the data.

Below these are 4 buttons that are used mainly during initial patching
and when switching amplifier modes. The first is the ``VC-S`` button,
which loads the ``s.mat`` protocol. This protocol, designed to be used in
voltage-clamp, holds the electrode at 0 mV, with a brief step to -10
mV. The second is the ``VC-I`` button, which loads the ``i.mat`` protocol. The
only difference here is that the pipette is held at -60 mV, and
stepped to -70 mV. This is useful just prior to breaking into a cell,
so that the break-in doesn't cause a large shift in membrane potential.
Holding the pipette at a negative potential prior to break-in also
sometimes helps improve the seal resistance. The next button is the
``CCI`` button. This is used in current-clamp mode to provide a short
hyperpolarizing current pulse, to check input resistance and time
constants once the cell has been ruptured and you are in whole-cell
mode. Note that you have to switch the amplifier to current clamp
before using this mode. The ``SW`` button located below the ``CCI`` button
tries to coordinate a series of steps (turning off current injection,
switching amplifier modes, loading the new protocol, and then enabling
current or voltage commands) that minimize disruption of the cell
during the transition between current and voltage clamp, as well as
from voltage to current clamp.

--------------------------------------------
Typical Acquisition Session (command driven)
--------------------------------------------
In this section, the operations of a typical acquisition session is
described. Further details on commands are described below. A menu-
driven mode is also incorporated, and is described later.
First, it is necessary to open a data acquisition file. In the white
command entry box, enter ``aopen``. This opens a file to store the results
of the acquired data. The file name is determined the same way as in
DATAC: the name is formatted as ``ddmmmyyl.mat``, where ``dd`` is the current
date (leading zero), mmm is the 3-letter abbreviation for the current
month, ``yy`` is a 2-digit year, and l is a-z, corresponding to the
sequence of the file within the current date. It is recommended that
this structure be adhered to. The program will
display a new window with several fields that should be filled in to
describe the overall experiment. The last field is a line for the user
(experimenter) to sign. If this is the first acquisition of the day,
then the fields will be filled with default values. However, if it is
not the first file of the day, then the fields will be filled with the
values from the previous file in the sequence and you should modify
these as necessary. Click on OK to enter the dialog fields to the data
file and close the box. You are now read to begin acquisition. Before
proceeding further, you should make sure that the amplifier and the
acquisition program are synchronized with respect to the operation
mode - either voltage-clamp (VC) or current-clamp (CC). If the mode
needs to be switched, use the ``sw`` command to detect the amplifier
configuration and set the mode switch to the correct mode. Note that
at present, this is only important for the Axopatch 200 amplifier.
Other amplifiers cannot be read.

While searching for a cell, or beginning the formation of a patch, you
will need to operate in a search mode. Typically, this will utilize a
short current pulse (or voltage step). Load the stimulus configuration
with the g s (this ``Gets`` the search file which is called ``s.mat`` and
resides in the ``StmPar`` subdirectory; it also retrieves the acquisition
parameters, which are contained in the same the file). Using the
mouse, hit the ``scope`` button in the upper right hand corner of the
display, or type ``sco`` in the command window. This begins a cycle of
stimulus generation and display in an oscilloscope-style mode that can
be used to monitor the electrode resistance or the formation of a
patch. Once a seal is obtained, hit the ``stop`` button, and get the
stimulus file to begin the intracellular acquisition (typically, ``g i``
(intracellular)). Once intracellular access is obtained as indicated
by the capacitative charging transients and a change in the input
resistance and holding current, one is ready for data acquisition.

A stimulus file/acquisition combination file can now be loaded with
the ``g`` filename command. For example, a current-voltage relationship
might be generated using a standard IV protocol, which is loaded with
``g iv``. The command ``seq`` then will compute the stimuli and collect the
data for an IV, using the parameters in the stimulus display - for an
IV, cycling through the voltage steps. During the acquisition, the
data will be displayed on the screen (assuming that the acquisition
parameters are set to permit this), and the message box will show
information about the progress of the acquisition. You may then get
other protocols with the g command. Note that stimulus files may
include acquisition information internally, or may externally
reference a separate acquisition file.

You may also execute several stimulus protocols in sequence, using the
``do xyz abc`` command. The do command loads each protocol in order, makes
sure the waveforms are current with the parameters, executes a ``seq``,
and when the acquisition is done, reloads the protocol that was in
effect when the do command was entered, and goes into scope mode.
Notes regarding the experiment may be added with the note command.
This brings up an editing window, in which you may type a note of
arbitrary length. The notes are meant to provide supplemental
information, such as when valves are manually changed to apply drugs
to a cell, or to indicate information about the status of the cell,
that are either necessary or helpful for subsequent analysis. It is
recommended that the notes be used generously; they form an important
part of the experimental record and can really help untangle the
acquisition session in data analysis that make take place years after
the data was originally collected. Notes should also point out other
files associated with this one, such as imaging data.

The data file is closed with the ``aclose`` command. Typically, there is
only one cell to a data file (appropriate notes should be added if
this is not true), and most cells will have only one data file,
although exceptionally long protocols, program crashes, or lengthy
recordings may result in several files holding data for one cell.

----------------
Switching Modes
----------------

Because the amplifier gains for current and voltage clamp commands are
often different, the stimulus files are keyed to the acquisition mode.
The telegraph outputs of the AxoPatch (but not the Multiclamp) series
of amplifiers are interpreted by the program to insure that the modes
of the amplifier and the intended stimuli are synchronized. If the
modes were not synchronized, it would be possible to load a voltage-
clamp stimulus file while doing current-clamp recording (or vice-
versa), and this very likely would damage the cell. The next two
paragraphs provide explicit instructions on how to change modes for
the two different sets of amplifiers. You cannot change modes for the
AxoProbe amplifier, since it is current-clamp only.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AxoPatch 200, 200A, 200B Amplifiers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To change the acquisition modes between voltage and current clamp, use
the ``sw`` (switch) command; this command will wait for you to change the
mode switch, and when it detects the change, it will load a default
protocol for that mode (specified in the config structure). When
setting the default modes, make sure that they have appropriate
holding and step sizes for the configuration of the cell/patch that
you want. After switching, which should leave you in a safe
configuration, you will nearly always load new stimulus protocols
associated with the new mode to collect additional data. To do this
properly, you should switch to the ``I=0`` setting and wait for the
program to recognize the change (there will be an informative display
message), before switching the the target mode.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Multiclamp 700, 700A, 700B
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These amplifiers can communicate with the computer via a USB/serial interface. 
We have an intermediate module that talks to the Multiclamp (the "Multiclamp Server")
and is accessible from MATLAB via a TCP connection. This module allows us to read
the amplifier configuration, and update internal parameters, as well as control
the amplifier settings. Switching modes in this case involves changing to a protocol
with the new mode. No other user interaction is required.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
All Other Amplifiers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

With other amplifiers, we cannot read the mode of the amplifier.
Therefore, switching must be done differently. The following sequence
of commands will ensure that you are presenting stimuli that are safe
to the cell at all times:

* *STOP* the current stimulation
* Set the amplifier to I=0 (or disable the current injection).
* In ACQ, load a protocol appropriate for the mode you will go into
  next; e.g., g i if going into voltage clamp next, or g cci if going
  into current clamp next.
* START the stimulus (and make sure it is going). This is an important
  step, so that the proper levels are going out the D-A converter.
* *NOW* switch the amplifier to the target mode (Voltage clamp or
  Current clamp).

Simply reverse this sequence in order to go back to the other mode.

--------------------------------------------
Modifying the values in the data structures
--------------------------------------------

Access to the data in the structures is accomplished via commands from
the ACQ command window (the white box in the upper left corner of the
main window). To be successful, this command must form the minimum
unique sequence of letters that accesses the desired field, and does
not collide with MATLAB command names that are registered with the
program. The appropriate names are listed to the left of the data
fields, and are case-insensitive. When these names have spaces, only
the first part of the field is used.

Structure elements that take strings are simply entered (e.g., Name
ivx). Structure elements that take single numbers can be entered in
the same way. However elements that take more than one argument can be
entered in two ways. One is to specify the index, followed by the
value (e.g., ``level 2 -100``, which changes the level of step number 2 to
-100). The other is to specify the whole array, with a MATLAB-like
syntax (e.g., ``level [-60 0 -60 -120]``, which changes all of the levels
and creates a 4-level step). Some care must be used when entering
these numbers in either format, to ensure that valid numbers are
entered; there is minimal checking in the program at present. It is
also important to be sure that the number of events matches. For
example, in steps, the number of levels and durations must be the
same. In acquisition, the number of channels, gains, filter settings,
scale factors, etc., must all match.

----------
Sequences
----------
One exception the the entry format just described is that used to specify sequences.

Sequences can be specified in several ways: as a MATLAB array; as a
DATAC-style sequence; or as an m-file that returns appropriate values.
Furthermore, the sequence may consist of several specified sequences
(which in the case of the stimulus structure will be applied in a
specific way to different control parameters), each using any of the
above formats. Multiple sequences using the MATLAB array format in any
of the individual cases must use an & sign between the sequences; this
is not necessary if the sequence use only the DATAC-style. The
resulting output represents the nested computation of the first
sequence, cycled element by element against the second sequence, etc.
The command ``seq`` permits the rapid collection of parametric data once
basic timing has been set. The use of this command can reduce the
number of macros that one might maintain on disk as well as permits
some flexibility during the experiment as to how the data will be
collected. The syntax for sequence is as follows: ``valuelist`` is a
sequence of the form ``a;b/xc`` that lists the values that the variable
will take. The argument c is optional. a;b/x will step from a to b
with increments of x; it is equivalent to theMATLAB statement
``[a:a+x:b]``. The statement ``a;b/xn`` makes ``xsteps`` from ``a`` to ``b``. ``a;b/xl`` makes
x steps with logarithmic spacing. ``a;b/xr`` is the same as ``a;b/xn`` except
that the results are in a randomized order. ``a;b/xs`` is the same as
``a;b/xl`` except that the results are in a randomized order. Floating
point values are permitted. When random presentation is done, the
sequence is always the same (the same seed is always used). Similar
sequences can be generated with MATLAB commands, for example ``linspace``
or ``logspace``.

Sequences can be nested in another way also. Furthermore, if a file is
specified for ``addchannel`` (e.g., for the second DAC output) or
``superimpose`` (summed with the primary DAC output), then the primary
sequence will be repeated for each element of the sequences present in
these stimulus blocks.

