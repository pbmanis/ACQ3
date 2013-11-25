function sure_close()

      [filename, pathname] = uigetfile('*.mat', 'File to add index to?');
      if(filename == 0)
         return;
      end;
   full_file = fullfile(pathname, filename);
   x = exist([pathname 'INDEX' '.mat']);
   if(any(x ==2))
      Index = load('INDEX');
      Index = Index.INDEX;
      save(full_file, 'Index', '-append');
      delete ('INDEX.mat'); % remove existing index file
   else
      QueMessage('index_file: INDEX is missing at close', 1);
   end;
