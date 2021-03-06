classdef plot < handle
  %tsgqc.plot
  %   Detailed explanation goes here
  
  properties
    parent
    hdlParent
    hdlPlotsPanel
    hdlPlotAxes
    hdlDataAvailable
  end
  
  methods
    
    % tsgqc.plot constructor; take tsgqc parent object as parameter
    % ---------------------------------------------------------------
    function obj = plot(parent)
      
      obj.parent = parent;
      obj.hdlParent = parent.hdlMainFig;
      obj.setUI;
      % add listener from tsgqc when data are available
      %obj.hdlDataAvailable = addlistener(parent,'dataAvailable',@obj.dataAvailableEvent);
    end
    
    % build plot data User Interface
    % --------------------------------
    function setUI(obj)
      obj.hdlPlotsPanel = uipanel( ...
        'Parent', obj.hdlParent, ...
        'Units', 'normalized', ...
        'BorderType', 'etchedin',...
        'Visible', 'on',...
        'Position',[0.15, 0.0, .85, .95]);
      % create Axes array
      obj.hdlPlotAxes = axes( 'Parent', obj.hdlPlotsPanel, 'Visible', 'off', ...
        'box', 'on', 'Units', 'normalized','Tag', 'TAG_AXES_1', ...
        'HandleVisibility','on', 'Position',[.05, .64, .93, .35]);
      obj.hdlPlotAxes(2) = axes( 'Parent', obj.hdlPlotsPanel, 'Visible', 'off',...
        'box', 'on', 'Units', 'normalized', 'Tag', 'TAG_AXES_2', ...
        'HandleVisibility','on', 'Position',[.05, .33, .93, .27]);
      obj.hdlPlotAxes(3) = axes('Parent', obj.hdlPlotsPanel, 'Visible', 'off',...
        'box', 'on', 'Units', 'normalized', 'Tag', 'TAG_AXES_3', ...
        'HandleVisibility','on', 'Position',[.05, .02, .93, .27]);
    end % end of tsgqc.plot constructor
    
        % wait for dataAvailable event from tsgqc
    % ---------------------------------------
    function plotData(obj, evnt)
      fprintf(1, 'data available for %s\n', class(obj));
      
      % print filename without path in DisplayUI
      [~,file,ext] = fileparts(obj.parent.inputFile);
      obj.parent.hdlInfoFileText.String = strcat(file, ext);
      lineType =  'none';
      markType = '*';
      colVal = 'b';
      markSize = 2;
      
      % get list of parameters from left panel popup passed to event
      PARA = evnt.param;
      
      X = obj.parent.nc.Variables.DAYD.data__;
      for i = 1 : length(PARA)
        obj.eraseLine(i);
        para = PARA{i};
        Y = obj.parent.nc.Variables.(para).data__;
        if  isfield(obj.parent.nc.Variables, [para '_QC'])
          QC = obj.parent.nc.Variables.([para '_QC']).data__;
        else
          QC = zeros(length(obj.parent.nc.Variables.(para).data__),1);
        end
        obj.plotParameter(i, X, Y, QC, obj.parent.qc, para, colVal, lineType, markType, markSize);
      end
    end
    
  end % end of public methods
  
  methods (Access = private)
    
    % plot data called by dataAvailableEvent
    % ---------------------------------------
    function plotParameter(obj, plotNum, X, Y, QC, qCode, para, colVal, ...
        lineType, markType, markSize)
      
      if ~isempty( X ) && ~isempty( Y )
        
        % positionning the right axes (set map current axe)
        axes(obj.hdlPlotAxes(plotNum));
        % obj.hdlParent.CurrentAxes = obj.hdlPlotAxes(plotNum);
        
        % see resetAxes from tsgqc V1
        %set(obj.hdlPlotAxes(plotNum), 'XLimMode', 'auto', 'YLimMode', 'auto');
        
        if ~isempty(QC)
          keys = fieldnames(qCode);
          for k = 1: length(keys)
            ind = find( QC == qCode.(keys{k}).code);
            if ~isempty( ind )
              line( X(ind), Y(ind),...
                'Tag', ['TAG_PLOT' num2str(plotNum) '_LINE_' para '_' keys{k}],...
                'LineStyle', lineType, 'Marker', markType,...
                'MarkerSize', markSize, 'Color', qCode.(keys{k}).color);
              %               if obj.debug
              %                 fprintf(1,'Code: %d, Color: %c, Label: %s, Ind: %d\n', ...
              %                   qCode.(keys{k}).code, qCode.(keys{k}).color, ...
              %                   qCode.(keys{k}).label, length(ind));
              %               end
            end
          end
        else % TODOS. Check if it is necessary
          if isempty(colVal)
            colVal = 'k';
          end
          line( X, Y, ...
            'Tag', ['TAG_PLOT' num2str(plotNum) '_LINE_' para],...
            'LineStyle', lineType, ...
            'Marker', markType, 'MarkerSize', markSize, 'Color', colVal);
        end
        obj.axesCommonProp;
        
        % write some 'Y' label
        set(obj.hdlPlotAxes(plotNum).YLabel, 'Interpreter', 'none', 'String', para);
        
      end
      
    end % end of plotParameter
    
    function axesCommonProp(obj)
      datetick(obj.hdlPlotAxes(1), 'x', 'keeplimits');
      datetick(obj.hdlPlotAxes(2), 'x', 'keeplimits');
      datetick(obj.hdlPlotAxes(3), 'x', 'keeplimits');
      
      % Make the axes visible
      set(obj.hdlPlotAxes(1), 'Visible', 'on' );
      set(obj.hdlPlotAxes(2), 'Visible', 'on' );
      set(obj.hdlPlotAxes(3), 'Visible', 'on' );
      
      % TODOS, check if necessary
      drawnow;
      
      % The 3 axes will behave identically when zoomed and panned
      if obj.hdlPlotAxes(2).XLim(1) ~= 0 && obj.hdlPlotAxes(3).XLim(1) ~= 0
        linkaxes([obj.hdlPlotAxes(1),obj.hdlPlotAxes(2),obj.hdlPlotAxes(3)], 'x');
      end
      
    end
    
    % Erase line children of axe hAxe
    % -------------------------------
    function eraseLine( obj, PlotNum )
      hLines = findobj( obj.hdlPlotAxes(PlotNum), '-regexp', ...
        'Tag', ['TAG_PLOT' num2str(PlotNum) '_LINE_']);
      if ~isempty( hLines )
        delete(hLines);
      end
      
    end
    
  end
  
end

