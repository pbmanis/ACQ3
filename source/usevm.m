function usevm(Vm)
% usevm: set Vm for qinactp2 protocol to a value
% sets holding, and levels 1 and 5 to Vm
global STIM

if(ischar(Vm))
   Vm = str2num(Vm);
end;

STIM.Holding.v = Vm;
levs = STIM.Level.v;
levs(1) = Vm;
levs(length(levs)) = Vm;
STIM.Level.v = levs;
pv;
struct_edit('edit', STIM);
return
