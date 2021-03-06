function setMenuUI(obj,handleVisibility)

% this function define menus

% menu File
% -----------------------------------------------------------------------
obj.hdlFileMenu = uimenu(...
  'Parent', obj.hdlMainFig,...
  'HandleVisibility', handleVisibility,...
  'Label', 'File');

obj.hdlOpenMenu = uimenu(...
  'Parent', obj.hdlFileMenu,...
  'Label','Open',...
  'Accelerator','O',...
  'HandleVisibility', handleVisibility,...
  'UserData', 'off',...
  'Callback', {@(src,evt) openFileMenuCallback(obj,src)});

obj.hdlSaveMenu = uimenu(...
  'Parent', obj.hdlFileMenu,...
  'Label','Save',...
  'Accelerator','S',...
  'Enable', 'off',...
  'UserData', 'off',...
  'HandleVisibility', handleVisibility,...
  'Callback', {@(src,evt) saveMenuCallback(obj,src)});

obj.hdlExportMenu = uimenu(...
  'Parent', obj.hdlFileMenu,...
  'Label','Export',...
  'Accelerator','E',...
  'Enable', 'off',...
  'UserData', 'off',...
  'HandleVisibility', handleVisibility,...
  'Callback', {@(src,evt) exportMenuCallback(obj,src)});

obj.hdlExportTsg = uimenu(...
  'Parent', obj.hdlFileMenu,...
  'Label','Tsg ascii file',...
  'Enable', 'off',...
  'HandleVisibility', handleVisibility,...
  'Callback', {@(src,evt) exportTsgCallback(obj,src)});

obj.hdlExportSample = uimenu(...
  'Parent', obj.hdlFileMenu,...
  'Label','Sample ascii file',...
  'Enable', 'off',...
  'HandleVisibility', handleVisibility,...
  'Callback',{@(src,evt) exportSampleCallback(obj,src)});

obj.hdlQuitMenu = uimenu(...
  'Parent',obj.hdlFileMenu,...
  'Label','Quit',...
  'Separator','on',...
  'Accelerator','Q',...
  'HandleVisibility', handleVisibility,...
  'Callback',{@(src,evt) delete(obj)});

% menu preferences
% -----------------------------------------------------------------------
obj.hdlPreferencesMenu = uimenu(...
  'Parent', obj.hdlMainFig,...
  'HandleVisibility', handleVisibility,...
  'Label', 'Preferences',...
    'Callback', {@(src,evt) preferencesMenuCallback(obj,src)});


end % end of setMainUI