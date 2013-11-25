function print_block(arg)

names=fieldnames(arg);
nfield = length(names);
s_field = strmatch('start', names);
e_field = strmatch('end', names);
if(isempty(s_field) | isempty(e_field))
   QueMessage(sprintf('structure %s lacks start or end field', arg.title));
   err = 1;
   return;
end

nm = size(char(names));
ml = nm(2) + 2;

fmt1 = sprintf('%%%ds : ', ml);
fprintf(1, '\n..................................\n');
for i = 1:length(names)
   if(i < s_field | i > e_field)
      v = eval(['arg.' char(names(i))]);
      fprintf(1, fmt1, char(names(i)));
      if(isempty(strmatch(char(names(i)), {'method_code', 'waveform', 'tbase', 'fhandles'}, 'exact')))
         if(isempty(v))
            fprintf(1, '/e/ [] ');
         elseif(isnumeric(v))
            fprintf(1, '/n/ %g ', v);
         elseif (ischar(v))
            fprintf(1, '/s/ %s ', v);
         end;
      else
         if(isempty(v))
            fprintf(1, '/e/ []');
         elseif(ischar(v))
            fprintf(1, '/s/ (data)');
         elseif(isnumeric(v))
            fprintf(1, '/n/ (data)');
         elseif(isstruct(v))
            fprintf(1, '/S/ (structure)');
            a=fieldnames(v);
            fprintf(1, ' %s', a); 
         elseif(iscell(v))
            fprintf(1, '/c/ (cell {%d})', length(v));
            
         end;
      end;
   end;
   if(i == s_field)
      fprintf(1, '*------------------------------*');
   end;
   if(i == e_field)
      fprintf(1, '*------------------------------*');
   end;
   if(i > s_field & i < e_field)
      v = eval(['arg.' char(names(i)) '.v']);
      fprintf(1, fmt1, char(names(i)));
      if(isempty(strmatch(char(names(i)), strvcat('method_code', 'waveform', 'tbase'), 'exact')))
         if(isempty(v))
            fprintf(1, '/e/ [] ');
         elseif(isnumeric(v))
            fprintf(1, '/n/ %g ', v);
         elseif (ischar(v))
            fprintf(1, '/s/ %s ', v);
         end;
      else
         if(isempty(v))
            fprintf(1, '/e/ []');
         elseif(ischar(v))
            fprintf(1, '/s/ (data)');
         elseif(isnumeric(v))
            fprintf(1, '/n/ (data)');
         elseif(isstruct(v))
            fprintf(1, '/S/ (structure)');
            a=fieldnames(v);
            fprintf(1, ' %s', a); 
         elseif(iscell(v))
            fprintf(1, '/c/ (cell {%d})', length(v));
         end;
         
      end;
   end;
   fprintf(1,'\n');
end;

return;
