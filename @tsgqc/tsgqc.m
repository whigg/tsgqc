classdef tsgqc < handle
  %TSGQC: Thermosalinograph (TSG) Quality Control software
  
  %   %% COPYRIGHT & LICENSE
  %  Copyright 2007 - IRD US191, all rights reserved.
  %
  %  This file is part of tsgqc.
  %
  %    TSGQC is free software; you can redistribute it and/or modify
  %    it under the terms of the GNU General Public License as publDisplayished by
  %    the Free Software Foundation; either version 2 of the License, or
  %    (at your option) any later version.
  %
  %    tsgqc is distributed in the hope that it will be useful,
  %    but WITHOUT ANY WARRANTY; without even the implied warranty of
  %    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  %    GNU General Public License for more details.
  %
  %    You should have received a copy of the GNU General Public License
  %    along with Datagui; if not, write to the Free Software
  %    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  
  properties
    hdlMainFig
    hdlFileMenu
    hdlOpenMenu
    hdlSaveMenu
    hdlExportMenu
    hdlExportTsg
    hdlExportSample
    hdlQuitMenu
    hdlInfoPanel
    hdlInfoFileText
    hdlInfoDateText
    hdlInfoSSPSText
    hdlInfoSSJTText
    hdlInfoSSTPText
    hdlInfoLatText
    hdlInfoLongText
    hdlToolbar
    hdlOpenPushtool
    hdlSavePushtool
    hdlPrintFigPushtool
    hdlZoomInToggletool
    hdlZoomOutToggletool
    hdlPanToggletool
    hdlQCToggletool
    hdlTimelimitToggletool
    hdlMapToggletool
    hdlGoogleEarthPushtool
    hdlClimToggletool
    hdlCalToggletool
    hdlInterpToggletool
    hdlBottleToggletool
    hdlHeaderPushtool
    hdlReportPushtool
    
    nc
    inputFile
    outputFile
    preference = preference
    path
    configFile
    display
    help
    axes
    map
    
    hdlDataAvailable
    fontSize = 11
  end
  
  events
    dataAvailable
    fileclose
    axesVisible
  end
  
  methods
    
    % constructor
    % -----------
    function obj = tsgqc(varargin)
      property_argin = varargin(1:end);
      while length(property_argin) >= 2
        property = property_argin{1};
        value    = property_argin{2};
        property_argin = property_argin(3:end);
        switch lower(property)
          case {'inputfile', 'input'}
            obj.inputFile = value;
          case {'outputfile', 'output'}
            obj.outputFile = value;
          case 'display'
            obj.display = value;
          case 'help'
            obj.help = value;
          otherwise
            error('Unknow property: "%s"', property);
        end
      end
      
      % display user interface
      obj.path = mfilename('fullpath');
      obj.configFile = [prefdir, filesep, mfilename, '.mat'];
      obj.setMainUI;
      obj.setDisplayUI;
      obj.setToolBarUI;
      % prepare plot and map with events
      obj.map = tsgqc.map(obj);
      obj.axes = tsgqc.plot(obj);
      
      
      % add listener
      obj.hdlDataAvailable = addlistener(obj,'dataAvailable',@obj.dataEvent);
    end
    
    % destructor
    % ----------
    function delete(obj)
      % method save_config
      saveConfig(obj);
      if ~isempty(obj.map.hdlMapFig)
        close(obj.map.hdlMapFig);
      end
      closereq;
    end
    
  end % end of public methods
  
  methods(Static)
    
    function cdata = readIcon(filename)
      thePath = fileparts(which(mfilename));
      data = load(strcat(thePath,filesep,'../icons',filesep,filename));
      cdata = data.cdata;
    end
    
  end % end of static methods
end

