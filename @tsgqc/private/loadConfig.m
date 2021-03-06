function loadConfig(obj, ~)

% import preference class from tsgqc package
import tsgqc.preference

% test if configuration .mat file exist
if exist(obj.configFile, 'file') == 2
  
  try
    % try to load class instance in local workspace
    load(obj.configFile, 'tsgqcPrefs');
    % affect local workspace tsgqcPrefs to preference instance
    obj.preference = tsgqcPrefs;
  catch
    % on error, load default preference class
    obj.preference = preference(obj.VERSION, obj.DATE);
  end
  
  % for a new version, reload default preference class
  if isa(tsgqcPrefs, 'preference') && ~strcmp(obj.preference.version, obj.VERSION)
    obj.preference = preference(obj.VERSION, obj.DATE);
  elseif ~isa(tsgqcPrefs, 'preference')
    obj.preference = preference(obj.VERSION, obj.DATE);
  end
else
  obj.preference = preference(obj.VERSION, obj.DATE);
end 