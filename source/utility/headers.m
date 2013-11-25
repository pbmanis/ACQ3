function headers()
% headers.m  -  Read files on disk and find the headers
% print the header information for each file found on disk
monlist = {'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'};
x=dir('*.mat'); % only the mat files.
% it would be best to sort x by experiment date.....
for i = 1:length(x)
   if(~isempty(str2num((x(i).name(1:2)))))
      u(1,i) = str2num(x(i).name(1:2)); % day of the month 
      u(2,i) = strmatch(lower(x(i).name(3:5)), monlist); % month of year in number
      u(3,i) = str2num(x(i).name(6:7)); % year in digits
      u(4,i) = lower(x(i).name(8))-65; % sequence number
      if(u(3,i) < 80) % no data before 1980 in this case (rollover)
         u(3,i) = u(3,i)+2000;
      else
         u(3,i)=u(3,i)+1900;
      end;
   else
      u(1,i)= 999;
      u(2,i)=999;
      u(3,i)=9999;
      u(4,i)=99;
   end;
end;
[b, index] = sortrows(u', [3,2,1,4]); % get the indices - use for copy of elements

for i = 1:length(x)
   fn = x(index(i)).name;
   HFILE = [];
   hf=load(fn, 'HFILE'); % try to read HFILE from the file to read the header
   hfn = fieldnames(hf);
   if(strmatch('HFILE', hfn))
      
      HFILE = hf.HFILE;
      if(~isempty(HFILE)) % if one exists, the do the thing
         fprintf(1, '\nFile: %s\n', HFILE.filename);
         fprintf(1, 'Species: %12s  Age: %8s  Weight: %8s  DIV: %4s\n', char(HFILE.Species.v), char(HFILE.Age.v), char(HFILE.Weight.v), char(HFILE.DIV.v));
         fprintf(1, 'Experiment:\n');
         c=char(HFILE.Experiment.v);
         for j = 1:size(c,1)
            fprintf(1, '     %s\n', c(j,:));
         end;
         fprintf(1, '-----------------------\n');
      end;
   end;
end;

