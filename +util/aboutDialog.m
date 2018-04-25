function aboutDialog(hTsgGUI, DEFAULT_PATH_FILE)
%
% Input
% -----
% hTsgGUI ............ Handel to the main user interface
%
% Output
% ------
% none

% $Id: aboutDialog.m 816 2017-03-27 13:33:33Z jgrelet $


% Get the data from the application GUI
% -------------------------------------
tsg = getappdata(hTsgGUI, 'tsg_data');

% preferences Uicontrols in a new figure
% ---------------------------------
hAboutDialogFig = figure(...
  'Name', 'About TSGQC', ...
  'NumberTitle', 'off', ...
  'Resize', 'off', ...
  'Menubar','none', ...
  'Toolbar', 'none', ...
  'Tag', 'TSG_ABOUT', ...
  'Visible','on',...
  'WindowStyle', 'modal', ...
  'Units', 'normalized',...
  'ButtonDownFcn', @quitAboutCallback);

% Create center uipanel
% -----------------
hCenterPanel = uipanel( ...
  'Parent', hAboutDialogFig, ...
  'Units', 'normalized', ...
  'BorderType', 'line',...
  'Position',[.0, .15, .85, .85],...
  'ButtonDownFcn', @quitAboutCallback);

% properties, to review
% ---------------------
axes('parent',hCenterPanel,'DataAspectRatioMode','manual');
img = image(iconReadMat('thermo.mat'));
set(img, 'clipping', 'off','ButtonDownFcn', @quitAboutCallback);
axis off; axis fill;
axis image;

% Create bottom uipanel
% -----------------
hBottomPanel = uipanel( ...
  'Parent', hAboutDialogFig, ...
  'Units', 'normalized', ...
  'BorderType', 'none',...
  'Position',[.0, .0, 1, .15],...
  'ButtonDownFcn', @quitAboutCallback);

% Create right uipanel
% --------------------
hRightPanel = uipanel( ...
  'Parent', hAboutDialogFig, ...
  'Units', 'normalized', ...
  'BorderType', 'none',...
  'Position',[.85, .15, .15, .85],...
  'ButtonDownFcn', @quitAboutCallback);

% display info in botom panel
msg = sprintf( 'TSGQC v %s - %s - GOSUD v %s', ...
  tsg.preference.char_version, tsg.preference.date_version, tsg.FORMAT_VERSION)
uicontrol('Parent', hBottomPanel, ...
  'Style','text',...
  'FontSize', 14, ...
  'Units','normalized',...
  'Position',[.1 .1 .75 .5],...
  'FontWeight','bold',...
  'String', msg,...
  'HorizontalAlignment','center');

% display info in right panel
uicontrol('Parent', hRightPanel, ...
  'Style','text',...
  'FontSize', 9, ...
  'Units','normalized',...
  'Position',[.05 .8 .9 .1],...
  'String',sprintf('Clim: %s', tsg.levitus.version),...
  'HorizontalAlignment','left');

% display info in right panel
uicontrol('Parent', hRightPanel, ...
  'Style','text',...
  'FontSize', 9, ...
  'Units','normalized',...
  'Position',[.05 .73 .9 .1],...
  'String',sprintf('Type: %s', tsg.levitus.type),...
  'HorizontalAlignment','left');

depth = ...
  tsg.preference.levitus_depth_string{tsg.preference.levitus_depth_value};

% display info in right panel
uicontrol('Parent', hRightPanel, ...
  'Style','text',...
  'FontSize', 9, ...
  'Units','normalized',...
  'Position',[.05 .66 .9 .1],...
  'String',sprintf('Depth: %s m', depth),...
  'HorizontalAlignment','left');


% -------------------------------------------------------------
% nested function on mouse clic when QC toggle tool is selected
% -------------------------------------------------------------
  function quitAboutCallback(gcbo, eventdata)
    close(hAboutDialogFig);
  end

end