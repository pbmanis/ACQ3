function fig = pulse_editor_fig()
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
% This problem is solved by saving the output as a FIG-file.
%
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.
% 
% NOTE: certain newer features in MATLAB may not have been saved in this
% M-file due to limitations of this format, which has been superseded by
% FIG-files.  Figures which have been annotated using the plot editor tools
% are incompatible with the M-file/MAT-file format, and should be saved as
% FIG-files.

load pulse_editor_fig

h0 = figure('Color',[0.3 0.3 0.3], ...
	'Colormap',mat0, ...
	'FileName','C:\mat_datac\Acq\source\utility\pulse_editor.fig.m', ...
	'MenuBar','none', ...
	'Name','Pulse Editor: recovery', ...
	'NumberTitle','off', ...
	'PaperPosition',[18 180 576 432], ...
	'PaperUnits','points', ...
	'Position',[473 268 530 270], ...
	'ResizeFcn','doresize(gcbf)', ...
	'Tag','PEdit', ...
	'ToolBar','none', ...
	'DefaultaxesCreateFcn','plotedit(gcbf,''promoteoverlay''); ');
h1 = uimenu('Parent',h0, ...
	'HandleVisibility','off', ...
	'Tag','ScribeHGBinObject', ...
	'Visible','off');
h1 = uimenu('Parent',h0, ...
	'HandleVisibility','off', ...
	'Tag','ScribeFigObjStorage', ...
	'Visible','off');
h1 = axes('Parent',h0, ...
	'Units','pixels', ...
	'AmbientLightColor',[0 0 0], ...
	'CameraUpVector',[0 1 0], ...
	'Color',[0.501960784313725 0.501960784313725 0.501960784313725], ...
	'ColorOrder',mat1, ...
	'CreateFcn','', ...
	'FontSize',7, ...
	'NextPlot','add', ...
	'Position',[17 160 279 90], ...
	'Tag','PEdit_graph', ...
	'XColor',[0 0 0], ...
	'YColor',[0 0 0], ...
	'ZColor',[0 0 0]);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',mat2, ...
	'Tag','Axes1Text4', ...
	'VerticalAlignment','cap');
set(get(h2,'Parent'),'XLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[-23.38129496402878 48.31460674157303 17.32050807568877], ...
	'Rotation',90, ...
	'Tag','Axes1Text3', ...
	'VerticalAlignment','baseline');
set(get(h2,'Parent'),'YLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','right', ...
	'Position',mat3, ...
	'Tag','Axes1Text2', ...
	'Visible','off');
set(get(h2,'Parent'),'ZLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',mat4, ...
	'Tag','Axes1Text1', ...
	'VerticalAlignment','bottom');
set(get(h2,'Parent'),'Title',h2);
h2 = line('Parent',h1, ...
	'Color',[0 0 0], ...
	'Tag','PEdit_graphLine9', ...
	'XData',mat5, ...
	'YData',mat6);
h2 = line('Parent',h1, ...
	'Color',[0 0 0], ...
	'Tag','PEdit_graphLine8', ...
	'XData',mat7, ...
	'YData',mat8);
h2 = line('Parent',h1, ...
	'Color',[0 0 0], ...
	'Tag','PEdit_graphLine7', ...
	'XData',mat9, ...
	'YData',mat10);
h2 = line('Parent',h1, ...
	'Color',[0 0 0], ...
	'Tag','PEdit_graphLine6', ...
	'XData',mat11, ...
	'YData',mat12);
h2 = line('Parent',h1, ...
	'Color',[0 0 0], ...
	'Tag','PEdit_graphLine5', ...
	'XData',mat13, ...
	'YData',mat14);
h2 = line('Parent',h1, ...
	'Color',[0 0 0], ...
	'Tag','PEdit_graphLine4', ...
	'XData',mat15, ...
	'YData',mat16);
h2 = line('Parent',h1, ...
	'Color',[0 0 0], ...
	'Tag','PEdit_graphLine3', ...
	'XData',mat17, ...
	'YData',mat18);
h2 = line('Parent',h1, ...
	'Color',[0 0 0], ...
	'Tag','PEdit_graphLine2', ...
	'XData',mat19, ...
	'YData',mat20);
h2 = line('Parent',h1, ...
	'Color',[1 0 0], ...
	'Tag','PEdit_graphLine1', ...
	'XData',mat21, ...
	'YData',mat22);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'Callback','pulse_edit(''update'')', ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[29.25 93 52.5 16.5], ...
	'String','Update', ...
	'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'Callback','pulse_edit(''addchannel'')', ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[29.25 70.5 52.5 16.5], ...
	'String','AddChannel', ...
	'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'Callback','pulse_edit(''open'')', ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[89.25 93 52.5 16.5], ...
	'String','Open', ...
	'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'Callback','pulse_edit(''save'')', ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[89.25 70.5 52.5 16.5], ...
	'String','Save', ...
	'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'Callback','pulse_edit(''PV'')', ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[149.25 93 52.5 16.5], ...
	'String','PV', ...
	'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'Callback','pulse_edit(''exit'')', ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[149.25 70.5 52.5 16.5], ...
	'String','Exit', ...
	'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''npulse'')', ...
	'ListboxTop',0, ...
	'Position',[270 172.5 45 15], ...
	'String','20', ...
	'Style','edit', ...
	'Tag','PEdit_npulse');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''ipi'')', ...
	'ListboxTop',0, ...
	'Position',[270 157.5 45 15], ...
	'String','    5.0', ...
	'Style','edit', ...
	'Tag','PEdit_ipi');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''durp1'')', ...
	'ListboxTop',0, ...
	'Position',[270 142.5 45 15], ...
	'String','    0.1', ...
	'Style','edit', ...
	'Tag','PEdit_durp1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''durp2'')', ...
	'ListboxTop',0, ...
	'Position',[270 127.5 45 15], ...
	'String','    0.1', ...
	'Style','edit', ...
	'Tag','PEdit_durp2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''l1l2'')', ...
	'ListboxTop',0, ...
	'Position',[270 112.5 45 15], ...
	'String','-1', ...
	'Style','edit', ...
	'Tag','PEdit_l1l2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''level'')', ...
	'ListboxTop',0, ...
	'Position',[270 97.5 45 15], ...
	'String',' 100.00', ...
	'Style','edit', ...
	'Tag','PEdit_level');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''seqpar'')', ...
	'ListboxTop',0, ...
	'Position',[270 82.5 45 15], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','PEdit_Seqpar');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''seqparn'')', ...
	'ListboxTop',0, ...
	'Position',[270 67.5 45 15], ...
	'String','1', ...
	'Style','edit', ...
	'Tag','PEdit_seqparn');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''sequence'')', ...
	'ListboxTop',0, ...
	'Position',[270 52.5 66.75 15], ...
	'String','105;255/20', ...
	'Style','edit', ...
	'Tag','PEdit_sequence');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 52.5 45 15], ...
	'String','Sequence', ...
	'Style','text', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''scale'')', ...
	'ListboxTop',0, ...
	'Position',[270 36 45 15], ...
	'String','0.01', ...
	'Style','edit', ...
	'Tag','PEdit_scale');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 36 45 15], ...
	'String','Scale', ...
	'Style','text', ...
	'Tag','EditText2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 67.5 45 15], ...
	'String','SeqParN', ...
	'Style','text', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 82.5 45 15], ...
	'String','Seqpar', ...
	'Style','text', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'Callback','pulse_edit(''level'')', ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 97.5 45 15], ...
	'String','Level (uA)', ...
	'Style','text', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 112.5 45 15], ...
	'String','L1/L2 (rel)', ...
	'Style','text', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 127.5 45 15], ...
	'String','Dur P2 (ms)', ...
	'Style','text', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 142.5 45 15], ...
	'String','Dur P1 (ms)', ...
	'Style','text', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 157.5 45 15], ...
	'String','IPI (ms)', ...
	'Style','text', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[225 172.5 45 15], ...
	'String','# Pulses', ...
	'Style','text', ...
	'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'Callback','pulse_edit(''slider'')', ...
	'ListboxTop',0, ...
	'Max',1000, ...
	'Position',[345 37.5 22.5 142.5], ...
	'String','slider', ...
	'Style','slider', ...
	'Tag','PEdit_slider', ...
	'Value',100);
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'ForegroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[329.25 180.75 52.5 15], ...
	'String','Level (uA)', ...
	'Style','text', ...
	'Tag','StaticText1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0 0], ...
	'Callback','pulse_edit(''changesign'')', ...
	'ForegroundColor',[1 1 1], ...
	'HorizontalAlignment','right', ...
	'ListboxTop',0, ...
	'Position',[232.5 20 82.5 15], ...
	'String','Negative Leading', ...
	'Style','checkbox', ...
	'Tag','PEdit_negative');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0.501960784313725 0], ...
	'ListboxTop',0, ...
	'Position',[12 6.75 180 36], ...
	'Style','frame', ...
	'Tag','Frame1');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0.501960784313725 0], ...
	'ListboxTop',0, ...
	'Position',[21 24.75 45 15], ...
	'String','Level', ...
	'Style','text', ...
	'Tag','StaticText2');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0.501960784313725 0], ...
	'ListboxTop',0, ...
	'Position',[77.25 24.75 45 15], ...
	'String','Duration', ...
	'Style','text', ...
	'Tag','StaticText3');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0.501960784313725 0], ...
	'ListboxTop',0, ...
	'Position',[138.75 24.75 45 15], ...
	'String','Delay', ...
	'Style','text', ...
	'Tag','StaticText3');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''testlevel'')', ...
	'ListboxTop',0, ...
	'Position',[21 9.75 45 15], ...
	'String','99', ...
	'Style','edit', ...
	'Tag','PEdit_TestLevel');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''testduration'')', ...
	'ListboxTop',0, ...
	'Position',[76.5 9.75 45 15], ...
	'String','0.25', ...
	'Style','edit', ...
	'Tag','PEdit_TestDuration');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Callback','pulse_edit(''testdelay'')', ...
	'ListboxTop',0, ...
	'Position',[138.75 9.75 45 15], ...
	'String','115', ...
	'Style','edit', ...
	'Tag','PEdit_TestDelay');
h1 = uicontrol('Parent',h0, ...
	'Units','points', ...
	'BackgroundColor',[0 0.501960784313725 0], ...
	'ListboxTop',0, ...
	'Position',[12 43 180 15], ...
	'String','Test Pulse', ...
	'Style','text', ...
	'Tag','StaticText4');
h1 = axes('Parent',h0, ...
	'CameraUpVector',[0 1 0], ...
	'Color','none', ...
	'ColorOrder',mat23, ...
	'CreateFcn','', ...
	'HandleVisibility','off', ...
	'HitTest','off', ...
	'Position',[0.2981132075471698 0.1666666666666667 1 1], ...
	'Tag','ScribeOverlayAxesActive', ...
	'Visible','off', ...
	'XColor',[0.8 0.8 0.8], ...
	'XLimMode','manual', ...
	'XTickMode','manual', ...
	'YColor',[0.8 0.8 0.8], ...
	'YLimMode','manual', ...
	'YTickMode','manual', ...
	'ZColor',[0 0 0]);
h2 = text('Parent',h1, ...
	'Color',[0.8 0.8 0.8], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',[0.4990548204158791 -0.02973977695167285 9.160254037844386], ...
	'VerticalAlignment','cap', ...
	'Visible','off');
set(get(h2,'Parent'),'XLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0.8 0.8 0.8], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',mat24, ...
	'Rotation',90, ...
	'VerticalAlignment','baseline', ...
	'Visible','off');
set(get(h2,'Parent'),'YLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','right', ...
	'Position',[-0.3005671077504726 0.8289962825278811 9.160254037844386], ...
	'Visible','off');
set(get(h2,'Parent'),'ZLabel',h2);
h2 = text('Parent',h1, ...
	'Color',[0 0 0], ...
	'HandleVisibility','off', ...
	'HorizontalAlignment','center', ...
	'Position',mat25, ...
	'VerticalAlignment','bottom', ...
	'Visible','off');
set(get(h2,'Parent'),'Title',h2);
if nargout > 0, fig = h0; end
