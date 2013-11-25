function err = chklength(sf, namelist, maxcount)
% chklength: Check to see that the structure elemtents in namelist have correct lengths
err = 1;

if(nargin ~= 3)
   fprintf(2, 'chklength: Incorrect calling list \n');
   return;
end;
if(length(namelist) ~= length(maxcount))
   fprintf(2, 'chklength: name and count lists have different lengths\n');
   return;
end;
fn = fieldnames(sf);
for i = 1:length(namelist)
   this = strcmpi(namelist{i}, fn);
   if(~this)
      fprintf(2, 'chklength: %s is not an element of input structure\n', namelist{i});
      fprintf(2, 'in protocol: %s\n', sf.Name.v);
      fprintf(2, 'with method: %s\n', sf.Method.v);
      return;
   end;
   truename = find(this == 1); % must exist... 
   t = eval(['sf.' fn{truename} '.v']);
   if(length(t) ~= maxcount(i))
    %  QueMessage(sprintf('chklength: Requires %d value(s) in %s field, has %d\n', maxcount(i), namelist{i}, length(t)),1);
   end;
end;

err = 0;
return;

