function [drive, path, extension] = getdriveext()
htag = findobj('Tag', 'Drive');
sdrv = get(htag, 'String');
drive = sdrv(get(htag, 'Value'),:);

htag = findobj('Tag', 'FileExtension');
str = get(htag, 'String');
extension = str(get(htag, 'Value'),:);

htag = findobj('Tag', 'Path');
path = get(htag, 'String');
%path = str(get(htag, 'Value'),:);
return;
