================
Using The Menu
================

To simplify program operation, a standard drop-down menu list has been
implemented, as can be seen on the top of the window. The menu
provides the following functions:

-----
File
-----
This menu entry brings up a submenu largely related to file
maintenance.

* Open
    This invokes the ``aopen`` command to open a data file for collection. The
    filename is automatically generated as described above.
* Close
    This invokes the ``aclose`` command to close a currently open data file.
    Closed data files cannot be re-opened.
* Gather
    This causes the program to update the current command list. Only
    commands that are registered with the program can be executed from the
    command line. Normally this command is used only during program
    development when new commands are added. The gather function is
    implemented automatically on program start-up and normally is not
    needed by the user.
* Exit
    Closes any open data file and exits the program to the MATLAB prompt.

-----
Edit
-----
This menu brings up a submenu controlling which parameter sets will be
edited or saved.

* Edit Acquisition
    Selects the acquisition parameters for display and command-line
    editing.
* Edit Stimulus
    Selects the stimulus parameters for display and command-line editing.
* Edit Stimulus2
    Selects a secondary stimulus parameter set for display and
    modification by a GUI. Note that this only works for pulse stimuli at
    present. The GUI is designed to allow rapid modification of pulse
    trains (for example, used to stimulate afferent fiber systems)
    delivered on a second DAC channel, and updates the information in the
    primary protocol.

* Edit Config
    Selects the configuration parameters for display and command-line
    editing.
    
* Save Acquisition
    Saves the current acquisition parameters to disk, optionally
    overwriting or renaming the file.

* Save Config
    Saves the current acquisition configuration parameters to disk,
    optionally overwriting or renaming the file.

* New
    Each of the New entries corresponds to the creation of a stimulus
    template for a different kind of stimulus. Use this when you are
    making new stimulus sets.

---------
Protocol
---------
This menu selection brings up a choice of commands relating to
protocols, including a dynamically updated list of available protocols
in the current ``StmPar`` directory.

* Save Protocol
    Saves the current protocol to disk.

* Update Protocols
    Reloads the current list of stimulus protocols from the selected
    directory and redisplays them in the menu.

* Change Directory
    This selection brings up a Windows directory browser to change the
    current stimulus protocol directory. A successful directory selection
    results in an updated list of protocols found in the new directory.
    The entry ``StmPar`` in the configuration parameter set is also updated to
    reflect the current choice (however, the configuration is not
    permanently updated, and must be saved manually if the new selection
    is to be made permanent).
    
Below this is a list of the recognized ``StmPar`` protocols in the
selected directory. You may select one of these protocols from the
list, and it will be loaded, recomputed if necessary, and is ready to
use.

-------
Macros
-------

* Update list
    reads the contents of the macros directory, and updates the drop-down
    list of available macros.
    The remainder of the list allows selection of a macro from those a
    available.

-------------
Acquisition
-------------

* sequence
    causes the program to execute the current sequence, storing data if a
    file is open. This is how most parametric data is collected.

* data
    initiates collection of data without sequencing, and repeats until the
    stop button or menu item is selected.

* scope
    puts the program in scope mode (same as the button).

* stop
    stops ongoing data acquisition (same as the button).

* switch
    controls mode switching between voltage and current clamp with
    Axopatch 200 series amplifiers. This requires reading the telegraphs
    from the amplifier.

--------
Display
--------

* Erase
    forces a redraw of the screen

* A number of new options allow you to change the display scaling.

-----
Help
-----

* Help
    shows the list of current commands, with a short description of each
    one (taken from the m-file).

* Show flags
    shows the status of several of the control flags (mostly used for
    debugging).

* Clear flags
    resets the status of the flags, so that acquisition can run. This was
    necessary at one point to prevent the acquisition from stopping or
    failing to start. If the program seems to have stalled, or does not
    begin collecting data when requested, use this menu item to reset it
    to a known state.

