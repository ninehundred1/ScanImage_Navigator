function meyer_navigator(eventName,eventData,varargin)
%User ScanImage functions to show x/y positions of the stage/objective in a coordinate
%system. Documentation below.
%
%%  NOTE
%If you happen to close the window and want to reopen it, enter
%Meyer_NavigatorGUI; in the command line.

%For best use, select this m file in Settings>User Functions>appOpen>UserFCN Name.
%This will open the Navigator with each Startup of ScanImage.
%To enable the markings of the positions of images acquired ('Saved Positions')
%in the coordinate system, add the second m file (SMGetSaveCoordinates.m) to
%Settings>User Functions>acquisitionDone>UserFCN Name (then press 'save').
%DOCUMENTATION AND SETTING BELOW
%
%% CREDITS
%   Stephan Meyer, Rockefeller University, 2012
%   meyernsen@gmail.com
%% ***************************************************************************

global state

%GENERAL NOTE: For the Sutter MP285 it seems that if hitting the
%'Show Position' button or other buttons that read the position of
%the Sutter too fast/often, the Sutter might turn
%unresponsive and the motor has to be restored within ScanImage.
%That only requires to press the yellow 'restore motors' button that
%appears in the ScanImage motor controls, or to push the 'reset' button on
%the Sutter Conrol Module.

%DOCUMENTATION:
%%%%%%%%%%%%

%SHOW POSITION: displays the current motor position in the coordinate
%system in the center of crosshair.

%ADD CURRENT POSITION: marks the current position in the coordinate system.
%The color of the marking can be selected below.

%MOVE TO: select a position in the coordinate system. The motor will move
%to those coordinates in x and y. z will be kept at the same value as when
%the move was started. to ensure to not instruct the motor to move to
%positions outside its movement range (and the motor software to crash),
%specify the maximum movement range below, and its motor limits will be
%indicated with a black boundary box in the window.
%Selection can be aborted with a right click.
%If clicking on an already exisiting postion, the motor will move to that
%stored position in x, y and also z.

%TRACK: display the positions as you move the motors.
%The crosshair will folow the movements as they are made with a sampling
%speed given below (1Hz default, can be changed).
%if 'Enable Track Tracing' is ticked, a red line will be drawn along the sampled points,
%tracing the movement. During tracking, press STOP to abort. There is a
%chance that the Sutter controller will crash and the motor has to be
%reset if done for too long. Lowering the frequency might help.

%NAVIGATE MAP: Use the four buttons to move around the navigator map. The
%label of the buttons can be changed below to match your setup
%orientation/purpose (eg posterior, medial,..).

%ADD TEXT: Click to add text to annotate the map. Click once, then enter

%text in the corresponding field. Then click 'pick position' to select the
%position where the text should be displayed in the map. To cancel, right
%click after you clicked 'pick position'.

%UNDO TEXT: removed the last text entry


%CLEAR ALL DATA: Deletes all marked points, text, trace lines, save marks,
%from the navigator.


%ZERO: resets relative coordinates in the navigator window to 0. You can
%mark positions here (including z) for quick reference. The relative
%positions will be updates whenever the map position is updated (eg Show
%Position).

%UPDATE SCALE: Changes the resolution of the map to what value has been
%selected to the left of it (um per division).

%SHOW/UPDATE MAP: a secondary map is shown in a separate figure. In some cases this makes
%it easier to look around, zoom in and out and keep track of positions. The
%Map can be zoomed in and out with the standard matlab figure tools from
%the menus above. Click again to transfer changed made after first
%generating the map to update.

%SAVE: this saves a copy of the map you can display with the 'show map'
%command as a matlab fig file containing all positions and markings.
%If selected in Settings-Save Buttons saves.., it will also save all the raw data used to restore the state and display of
%the Navigator at a later time point using Load, or also saves a text file with the marked coordinates and
%text inputs for use in other programms, if that is desired (all can be changed in Settings-Save Buttons saves..).

%LOAD: will ask for a .mat file that is a currently saved state. If
%selected, the state will be restored as it was at the time. As mentioned
%below (see temp files documentation), certain parameters might overlap
%between sessions, especially the numbering system of the 'Saved
%Positions':
%If selected (tick at 'Saved Position' in the Annotation Menu), the
%Navigator will draw a white box in each position images
%have been acquired to keep track of where the imaging took place. The numbering will match the ScanImage 'Acquisition #'
%to help matching saved files to the locations.
%If, after a load, certain number positions are already present, the old positions are
%changed to 'L' (see below) instead of overwritten.
%You can always clear all data by clicking 'Clear All Data', bevor starting
%a new session.

%MENU ITEMS


%Menu OBJECTIVE- Select the currently used objective to adjust the size of the scan boundary box displayed.

%Menu ANNOTATIONS- Change what is currently shown on navigator map.

%Track Tacing: The red tracks recorded using Track while Record Track Movement was ticked.

%Saved Positions: The positions where images have been acquired, shown as a white box with the number matching the Acquisition # of ScanImage.
%This only gets the positions if (SMGetSaveCoordinates.m) is selected in ScanImage Settings>User Functions>acquisitionDone>UserFCN Name.

%Scan Boundaries: The rough outline of the area scanned. This assumes
%the scan area is straight, and is not accurate if you use a rotated
%scan configuration.

%Text: The text annotations entered using Add Text.

%Markings: The incremental positions added using Add Current Position.


%Menu SETTINGS- Change general settings.

%Save Button Saves: What to save upon clicking the Save button. This will not save itself. For that, click the Save button.

%Coordinates of Entries: Tick to save a text file containing the coordinates of the markings and texts.

%Map: Tick to save a fig file containing a copy of the map shown when Show Map is clicked.

%Navigator State: Tick to save a mat file containing the current state of the navigator that can be loaded again later.

%Show Motor Limitss: Tick to show the limits of the motor movement on map as a dashed line. Avoid clicking outside that box when using Move to.

%Show Crosshair: Tick to show a blue crosshair at the current position.'

%Autosave/restore Last Session: Tick to enable Autosaving and restoring that no data is lost in case the Navigator needs to be suddenly closed.

%Grid: Tick to show a grid.








%CHANGE PARAMETERS FOR FIRST SET-UP

% Minimum and maximim positions of manipulator (in micrometer). A black box
% is drawn around these coordinates to inform the user where the limits of
% the motor movements are, so that if 'move to' is used, no position
% outside the range of movement is selected. These are for the Sutter
% MP285. To set up, ideally, move all axes to their physical central positions using the
% Sutter controller. Then reset the axes (absolute coordinates) to 0. Now movement should be
% possible to roughly 12000um in each direction, which are the values
% entered here. You can check then, using the Sutter controller, moving
% the motor to their limits and showing the positions in the navigator.
% This might have to be reset every here and then, as it seems the Sutter
% changes it absolute 0 sometimes, thereby shifting the box.
% Alternatively, move the manipulator to the limits you prefer, then enter
% those below.
% To remove the box, change Settings-Motor Limits in the Navigator menu.

%(if changed settings to not have an effect, delete the filenameVarTemp file)

state.navigator.MotorlimitMinX=-12000; %(min x position in um)
state.navigator.MotorlimitMaxX=12000; %(max x position)
state.navigator.MotorlimitMinY=-12000; %(min y position)
state.navigator.MotorlimitMaxY=12000; %(max y position)


%Change orientation x/y, left/right button labels. This changes the labels
%of the Navigator button to make it easier to keep track of movement in
%what direction. Could be changed to eg. medial/lateral, etc.
%(if changed settings to not have an effect, delete the filenameVarTemp file)
state.navigator.TopButton='Right';
state.navigator.BottomButton='Left';
state.navigator.LeftButton='Back';
state.navigator.RightButton='Front';



%A temp file is generated and updated with all the changed values from the
%Navigator, so in case of a crash or other malfunction (or it was not
%saved), the data is not lost. If the last session has not finished with a save event,
%the temp file will automatically load upon startup, if 'Autosave/restore Last Session'
%is ticked in the Settings Menu of the Navigator. Press 'Clear All
%Data' to delete all data of the old session from the current session.
%If you enable 'Saved Positions', which shows the locations where you
%grabbed frames with the ScanImage Software, the number used to mark the
%Saved Position matches the number used by ScanImage for 'Acquisition #'.
%This way, the number of the saved image file can easily be traced back to
%the location marked with 'Saved Positions'. If an old session is present,
%these numbers might already be in use from the previous session, as
%ScanImage starts up using '1' as the Acquisition #. If an old '1' is
%present and a new '1' gets collected, the old will be replaced by 'L1'
%(for 'Last Session 1') so that information can be reused to eg revisit old
%sites.
%filenameVarTemp is the filename of the temp file and it will be saved in the currently used
%workspace folder. If a specific directory is to be used, change the
%'ScanImageNavigatorTemp.mat' variable to eg. 'C:\Documents and Settings\Administrator\ScanImageNavigatorTemp.mat'
%(if changed settings to not have an effect, delete the filenameVarTemp file)
state.navigator.filenameVarTemp = 'ScanImageNavigatorTemp.mat';





%boundaries of frame dimension displayed in navigator. If 'Scan Boundaries' is ticked
%in the Annotations Menu of the Navigator, a grey
%box will be drawn around the current position to indicate the area scanned
%at current zoom. Image dimensions have to be added for ImgSizeY2 and X2
%for y and z (in micrometer), respectively. this value (the area scanned) changes
%when changing objectives. Easy to measure by imaging a flurescent
%structure (eg cell body),moving it to one edge of the image by moving the objective, then
%setting the manipulator coordinates to 0 and moving the objective so the
%structure is at the opposing image edge and entering the value here.
%You can enter information for up to 5 objectives, names in the first line
%(eg '4x'), and the dimensions in micrometer are entered in the 3rd and 4th
%line of each block. The second line enables or disables that block from
%the menu. 1 means it will show up in the menu, 0, it will not.
%(if changed settings to not have an effect, delete the filenameVarTemp file)



state.navigator.objective1='4x';
state.navigator.objective1on=1;
state.navigator.objective1Y=4000;
state.navigator.objective1X=4000;

state.navigator.objective2='16x';
state.navigator.objective2on=0;
state.navigator.objective2Y=1000;
state.navigator.objective2X=1000;


state.navigator.objective3='20x';
state.navigator.objective3on=1;
state.navigator.objective3Y=500;
state.navigator.objective3X=500;

state.navigator.objective4='40x';
state.navigator.objective4on=1;
state.navigator.objective4Y=240;
state.navigator.objective4X=240;

state.navigator.objective5='100x';
state.navigator.objective5on=0;
state.navigator.objective5Y=100;
state.navigator.objective5X=100;







%change the speed of tracking. this value indicates the interval between
%each track in seconds when using the 'Track' function. 1 equals 1Hz tracking, 0.5 equals 2Hz tracking,
%etc.
%if set too low (eg 0.1) it might likely fail and interfere with basic
%ScanImage functions.
%(if changed settings to not have an effect, delete the filenameVarTemp file)
state.navigator.trackSpeed=1;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DON'T CHANGE BELOW HERE
state.navigator.colorindex=[];
state.navigator.ypos2=[];
state.navigator.xpos2=[];
state.navigator.yposReal=[];
state.navigator.xposReal=[];
state.navigator.y=[];
state.navigator.x=[];
state.navigator.offsetttt=[];
state.navigator.ypos=[];
state.navigator.xpos=[];
state.navigator.zpos=[];
state.navigator.colorchoice=[];
state.navigator.indexposition=[];
state.navigator.currentlengthText=[];
state.navigator.ydirect=[];
state.navigator.xdirect=[];
state.navigator.nav=[];
state.navigator.toggletext=1;
state.navigator.textList=cell(0);
state.navigator.xtextList=[];
state.navigator.ytextList=[];
state.navigator.textexport=cell(1,5);
state.navigator.textexport{1,1}='Position ROI-X';
state.navigator.textexport{1,2}='Position ROI-Y';
state.navigator.textexport{1,3}='Text ROI-X';
state.navigator.textexport{1,4}='Text ROI-Y';
state.navigator.textexport{1,5}='Text ROI content';
state.navigator.tracktoggle=0;
state.navigator.xposRelaOffset=0;
state.navigator.yposRelaOffset=0;
state.navigator.zposRelaOffset=0;
state.navigator.zRange=0;
state.navigator.xsaveyes=[];
state.navigator.ysaveyes=[];
state.navigator.zsaveyes=[];
state.navigator.saveObject=[];
state.navigator.zoomsaveyes=[];
state.navigator.saveyes=1;
state.navigator.startvalSave=1;
state.navigator.editsav=0;
state.navigator.tracktrack=0;
state.navigator.xtrackList=0;
state.navigator.ytrackList=[];
state.navigator.saveTemp=1;
state.navigator.ImgSizeY2=500;
state.navigator.ImgSizeX2=500;
state.navigator.u30toggle=0;
state.navigator.u31toggle=0;
state.navigator.u32toggle=0;
state.navigator.u33toggle=1;
state.navigator.u34toggle=1;
state.navigator.u35toggle=1;
state.navigator.motorlimit=1;
state.navigator.u20toggle=1;
state.navigator.u21toggle=1;
state.navigator.u22toggle=1;
state.navigator.u23toggle=1;
state.navigator.u24toggle=1;
state.navigator.u37toggle=1;
state.navigator.u38toggle=0;
state.navigator.u39toggle=0;
state.navigator.GridOn=1;
state.navigator.InvertX=0;
state.navigator.InvertY=0;
state.navigator.texton=1;
state.navigator.savedon=1;
state.navigator.trackon=1;
state.navigator.ImgBox=1;
state.navigator.markingon=1;
state.navigator.currentobj=1;
state.navigator.ImgSizeY3=500;
state.navigator.ImgSizeX3=500;
state.navigator.useprevioussaves=0;
state.navigator.yPrevSaved=[];
state.navigator.xPrevSaved=[];
state.navigator.minycross=4*state.navigator.MotorlimitMinY;
state.navigator.maxycross=4*state.navigator.MotorlimitMaxY;
state.navigator.minxcross=4*state.navigator.MotorlimitMinX;
state.navigator.maxxcross=4*state.navigator.MotorlimitMaxX;
state.navigator.crosshair=1;
state.navigator.loadTemp=1;
state.navigator.SaveMap=1;
state.navigator.SaveText=1;
state.navigator.SaveRaw=1;

if state.navigator.MotorlimitMinX==0 && state.navigator.crosshair==1
    
    
    state.navigator.minycross=4*-12000;
    state.navigator.maxycross=4*12000;
    state.navigator.minxcross=4*-12000;
    state.navigator.maxxcross=4*12000;
    
end



if state.navigator.crosshair==0
    
    
    state.navigator.minycross=0;
    state.navigator.maxycross=0;
    state.navigator.minxcross=0;
    state.navigator.maxxcross=0;
    
end


SMBuildNavigatorGUI;






function SMbNavUP(hObject, eventdata, handles)
% hObject    handle to pbNavUPSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global state




SMGetScale(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

if state.navigator.InvertX == 0
    
    state.navigator.xpos2=state.navigator.xpos2+state.navigator.nav;
else
    
    state.navigator.xpos2=state.navigator.xpos2-state.navigator.nav;
end

set(handles.axes3, 'ylim', [state.navigator.ypos2-state.navigator.offsetttt state.navigator.ypos2+state.navigator.offsetttt], 'xlim', [state.navigator.xpos2-state.navigator.offsetttt state.navigator.xpos2+state.navigator.offsetttt]);







function SMNavDWN(hObject, eventdata, handles)
% hObject    handle to pbNavDWNSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global state
SMGetScale(hObject, eventdata, handles);

SMPlotAll(hObject, eventdata, handles);

if state.navigator.InvertX == 0
    state.navigator.xpos2=state.navigator.xpos2-state.navigator.nav;
else
    state.navigator.xpos2=state.navigator.xpos2+state.navigator.nav;
end
set(handles.axes3, 'ylim', [state.navigator.ypos2-state.navigator.offsetttt state.navigator.ypos2+state.navigator.offsetttt], 'xlim', [state.navigator.xpos2-state.navigator.offsetttt state.navigator.xpos2+state.navigator.offsetttt]);



function SMNavLFT(hObject, eventdata, handles)
% hObject    handle to pbNavLFTSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global state

SMGetScale(hObject, eventdata, handles);

SMPlotAll(hObject, eventdata, handles);

if state.navigator.InvertY == 0
    state.navigator.ypos2=state.navigator.ypos2-state.navigator.nav;
else
    state.navigator.ypos2=state.navigator.ypos2+state.navigator.nav;
end


set(handles.axes3, 'ylim', [state.navigator.ypos2-state.navigator.offsetttt state.navigator.ypos2+state.navigator.offsetttt], 'xlim', [state.navigator.xpos2-state.navigator.offsetttt state.navigator.xpos2+state.navigator.offsetttt]);




function SMNavRGHT(hObject, eventdata, handles)
% hObject    handle to pbNavRGHTSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global state
SMGetScale(hObject, eventdata, handles);

SMPlotAll(hObject, eventdata, handles);


if state.navigator.InvertY == 0
    
    state.navigator.ypos2=state.navigator.ypos2+state.navigator.nav;
else
    state.navigator.ypos2=state.navigator.ypos2-state.navigator.nav;
end

set(handles.axes3, 'ylim', [state.navigator.ypos2-state.navigator.offsetttt state.navigator.ypos2+state.navigator.offsetttt], 'xlim', [state.navigator.xpos2-state.navigator.offsetttt state.navigator.xpos2+state.navigator.offsetttt]);



function SMZero(hObject, eventdata, handles)
% hObject    handle to pbZeroSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state


turnOffMotorButtons;
motorGetPosition();
turnOnMotorButtons;


state.navigator.xposReal=state.motor.lastPositionRead(1);
state.navigator.yposReal=state.motor.lastPositionRead(2);
state.navigator.zposReal=state.motor.lastPositionRead(3);


state.navigator.xposRelaOffset=state.navigator.xposReal;
state.navigator.yposRelaOffset=state.navigator.yposReal;
state.navigator.zposRelaOffset=state.navigator.zposReal;

state.navigator.xposRela=state.navigator.xposReal - state.navigator.xposRelaOffset;
state.navigator.yposRela=state.navigator.yposReal - state.navigator.yposRelaOffset;
state.navigator.zposRela=state.navigator.zposReal - state.navigator.zposRelaOffset;
state.navigator.zRange=((state.navigator.zposReal)./26000)*100;

set(handles.text23,'String',state.navigator.xposRela);
set(handles.text24,'String',state.navigator.yposRela);
set(handles.text25,'String',state.navigator.zposRela);

state.navigator.saveTemp=1;
SaveTempvar(hObject, eventdata, handles);


function SMUpdateScales(hObject, eventdata, handles)
% hObject    handle to pbUpdateScaleSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global state

state.navigator.yscale=get(handles.popuScaleSM,'Value');


switch state.navigator.yscale
    
    case 1
        
        
        state.navigator.offsetttt= 25000./2;
        
    case 2
        
        
        state.navigator.offsetttt= 12000./2;
        
    case 3
        
        
        state.navigator.offsetttt= 6000./2;
        
    case 4
        
        
        state.navigator.offsetttt= 2500./2;
        
    case 5
        
        
        state.navigator.offsetttt= 1250./2;
        
        
        
    case 6
        state.navigator.offsetttt= 250./2;
        
end


set(handles.axes3, 'ylim', [state.navigator.ypos2-state.navigator.offsetttt state.navigator.ypos2+state.navigator.offsetttt], 'xlim', [state.navigator.xpos2-state.navigator.offsetttt state.navigator.xpos2+state.navigator.offsetttt]);


SMPlotAll(hObject, eventdata, handles);


function SMUndoText(hObject, eventdata, handles)
% hObject    handle to pbUndoTextSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state


if length(state.navigator.ytextList)>0
    
    state.navigator.textList(end)=[];
    state.navigator.ytextList(end)=[];
    state.navigator.xtextList(end)=[];
    
else
    
    return
    
end


state.navigator.currentlengthText=(length(state.navigator.textList))-1;

SMPlotCurrent(hObject, eventdata, handles);

SMPlotAll(hObject, eventdata, handles);

state.navigator.saveTemp=1;
SaveTempvar(hObject, eventdata, handles);


function SMTrack(hObject, eventdata, handles)
% hObject    handle to pbTrackSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global state
state.navigator.tracktrack=state.navigator.tracktrack+1;





set(handles.tbTrackOffSM,'Visible','On');
set(handles.pbZeroSM,'Visible','off');
set(handles.pbDelteROIsSM,'Visible','off');
set(handles.pbTrackSM,'Visible','off');
set(handles.pbAddTextSM,'Visible','off');
set(handles.pbUndoTextSM,'Visible','off');
set(handles.pbExportSM,'Visible','off');
set(handles.pushbutton20,'Visible','off');
set(handles.pbShowMapSM,'Visible','off');
set(handles.pbNavLFTSM,'Visible','off');
set(handles.pbNavUPSM,'Visible','off');
set(handles.pbNavRGHTSM,'Visible','off');
set(handles.pbNavDWNSM,'Visible','off');
set(handles.pbShowPositionSM,'Visible','off');
set(handles.pbMoveToXYSM,'Visible','off');
set(handles.pbTextPositionSM,'Visible','off');





state.navigator.xtrackList(:,state.navigator.tracktrack)=0;
state.navigator.ytrackList(:,state.navigator.tracktrack)=0;



for tracks = 1:10000 %loop for tracking
    global state
    
    
    if state.navigator.tracktoggle==1
        break
    end
    
    turnOffMotorButtons;
    motorGetPosition();
    turnOnMotorButtons;
    
    state.navigator.xpos2=state.motor.lastPositionRead(1);
    state.navigator.ypos2=state.motor.lastPositionRead(2);
    
    state.navigator.xposReal=state.motor.lastPositionRead(1);
    state.navigator.yposReal=state.motor.lastPositionRead(2);
    
    
    state.navigator.DoTrack=get(handles.checkbTrace,'Value');
    if state.navigator.DoTrack==1;
        state.navigator.xtrackList(tracks,state.navigator.tracktrack)=state.navigator.xpos2;
        state.navigator.ytrackList(tracks,state.navigator.tracktrack)=state.navigator.ypos2;
        
        
        state.navigator.xtrackList(state.navigator.xtrackList==0)=nan;
        state.navigator.ytrackList(state.navigator.ytrackList==0)=nan;
    end
    
    
    SMGetScale(hObject, eventdata, handles);
    
    
    
    SMPlotCurrent(hObject, eventdata, handles);
    
    
    SMPlotAll(hObject, eventdata, handles);
    
    
    
    
    
    
    pause(state.navigator.trackSpeed);
    
    state.navigator.saveTemp=1;
    SaveTempvar(hObject, eventdata, handles);
    
end






set(handles.tbTrackOffSM,'Visible','Off');
set(handles.pbZeroSM,'Visible','on');
set(handles.pbDelteROIsSM,'Visible','on');
set(handles.pbTrackSM,'Visible','on');
set(handles.pbAddTextSM,'Visible','on');
set(handles.pbUndoTextSM,'Visible','on');
set(handles.pbExportSM,'Visible','on');
set(handles.pushbutton20,'Visible','on');
set(handles.pbShowMapSM,'Visible','on');
set(handles.pbNavLFTSM,'Visible','on');
set(handles.pbNavUPSM,'Visible','on');
set(handles.pbNavRGHTSM,'Visible','on');
set(handles.pbNavDWNSM,'Visible','on');
set(handles.pbShowPositionSM,'Visible','on');
set(handles.pbMoveToXYSM,'Visible','on');
set(handles.pbTextPositionSM,'Visible','on');


state.navigator.tracktoggle=0;




function SMToggleTextS(hObject, eventdata, handles)
% hObject    handle to pbToggleTextSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
if state.navigator.toggletext==1;
    state.navigator.toggletext=0;
    set(handles.pbToggleTextSM,'String','Text ON');
else
    state.navigator.toggletext=1;
    set(handles.pbToggleTextSM,'String','Text OFF');
end


SMPlotCurrent(hObject, eventdata, handles);


scatter(state.navigator.xposRela,state.navigator.yposRela);
set(handles.axes3, 'ylim', [state.navigator.ypos2-state.navigator.offsetttt state.navigator.ypos2+state.navigator.offsetttt], 'xlim', [state.navigator.xpos2-state.navigator.offsetttt state.navigator.xpos2+state.navigator.offsetttt]);



line([state.navigator.xposRela state.navigator.xposRela],[state.navigator.minycross state.navigator.maxycross]); %center crosshair for current
line([state.navigator.minxcross state.navigator.maxxcross],[state.navigator.yposRela state.navigator.yposRela]);




if state.navigator.ImgBox==1
    
    
    
    
    state.navigator.ImgSizeX=state.navigator.ImgSizeX2./state.acq.zoomFactor;
    state.navigator.ImgSizeY=state.navigator.ImgSizeY2./state.acq.zoomFactor;
    
    
    
    line([(state.navigator.xpos2+(state.navigator.ImgSizeX/2)) ((state.navigator.xpos2+state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2); %rough borders scan area
    line([(state.navigator.xpos2-(state.navigator.ImgSizeX/2)) (state.navigator.xpos2-(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
    
    line([(state.navigator.xpos2+(state.navigator.ImgSizeX/2)) (state.navigator.xpos2-(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2+(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
    line([(state.navigator.xpos2-(state.navigator.ImgSizeX/2)) (state.navigator.xpos2+(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2-(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
    
    
end


if state.navigator.motorlimit==1
    line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4); %rough borders of sutter movement
    line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
    line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
    line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
    
end





grid(gca,'minor')

if state.navigator.GridOn==0
    grid off
    
end

SMPlotAll(hObject, eventdata, handles);




function SMTextPosition(hObject, eventdata, handles)
% hObject    handle to pbTextPositionSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





global state







set(handles.pbZeroSM,'Visible','off');
set(handles.pbDelteROIsSM,'Visible','off');
set(handles.pbTrackSM,'Visible','off');
set(handles.pbAddTextSM,'Visible','off');
set(handles.pbUndoTextSM,'Visible','off');
set(handles.pbToggleTextSM,'Visible','off');
set(handles.pbAddPositionSM,'Visible','off');
set(handles.pbUpdateScaleSM,'Visible','off');
set(handles.pbExportSM,'Visible','off');
set(handles.pushbutton20,'Visible','off');
set(handles.pbShowMapSM,'Visible','off');
set(handles.pbNavLFTSM,'Visible','off');
set(handles.pbNavUPSM,'Visible','off');
set(handles.pbNavRGHTSM,'Visible','off');
set(handles.pbNavDWNSM,'Visible','off');
set(handles.pbShowPositionSM,'Visible','off');
set(handles.pbMoveToXYSM,'Visible','off');
set(handles.pbTextPositionSM,'Visible','off');
set(handles.popuScaleSM,'Visible','off');
set(handles.popupColorSM,'Visible','off');
set(handles.text1,'Visible','off');

set(handles.checkbox15,'Visible','off');
set(handles.checkbTrace,'Visible','off');










state.navigator.lasttext=get(handles.edEnterTextSM,'String');

state.navigator.currentlengthText=length(state.navigator.textList);

set(handles.text21,'String','Pick position. Right click to abort');

set(handles.text21,'Visible','On');

set(handles.edEnterTextSM,'Visible','Off');

[state.navigator.xtext,state.navigator.ytext buttonp] = ginput(1);


if buttonp~=1;
    
    
    set(handles.edEnterTextSM,'Visible','On');
    set(handles.pbZeroSM,'Visible','on');
    set(handles.pbDelteROIsSM,'Visible','on');
    set(handles.pbTrackSM,'Visible','on');
    set(handles.pbAddTextSM,'Visible','on');
    set(handles.pbUndoTextSM,'Visible','on');
    set(handles.pbToggleTextSM,'Visible','off');
    set(handles.pbAddPositionSM,'Visible','on');
    set(handles.pbUpdateScaleSM,'Visible','on');
    set(handles.pbExportSM,'Visible','on');
    set(handles.pushbutton20,'Visible','on');
    set(handles.pbShowMapSM,'Visible','on');
    set(handles.pbNavLFTSM,'Visible','on');
    set(handles.pbNavUPSM,'Visible','on');
    set(handles.pbNavRGHTSM,'Visible','on');
    set(handles.pbNavDWNSM,'Visible','on');
    set(handles.pbShowPositionSM,'Visible','on');
    set(handles.pbMoveToXYSM,'Visible','on');
    set(handles.pbTextPositionSM,'Visible','on');
    set(handles.popuScaleSM,'Visible','on');
    set(handles.popupColorSM,'Visible','on');
    set(handles.edEnterTextSM,'Visible','off');
    set(handles.text21,'Visible','off');
    set(handles.text1,'Visible','on');
    set(handles.checkbox15,'Visible','off');
    set(handles.checkbTrace,'Visible','on');
    
    
    if state.navigator.toggletext==1
        
        
        for indtext = 1:length(state.navigator.textList) %plots all saved text
            
            text(state.navigator.xtextList(indtext),state.navigator.ytextList(indtext),state.navigator.textList(indtext),'HorizontalAlignment','center','BackgroundColor',[1 1 1])
        end
    end
    
    
    
    return
    
else
    
    state.navigator.textList(state.navigator.currentlengthText+1)={state.navigator.lasttext};
    state.navigator.ytextList(state.navigator.currentlengthText+1)=state.navigator.ytext;
    state.navigator.xtextList(state.navigator.currentlengthText+1)=state.navigator.xtext;
    
    set(handles.edEnterTextSM,'Visible','On');
    set(handles.pbZeroSM,'Visible','on');
    set(handles.pbDelteROIsSM,'Visible','on');
    set(handles.pbTrackSM,'Visible','on');
    set(handles.pbAddTextSM,'Visible','on');
    set(handles.pbUndoTextSM,'Visible','on');
    set(handles.pbToggleTextSM,'Visible','off');
    set(handles.pbAddPositionSM,'Visible','on');
    set(handles.pbUpdateScaleSM,'Visible','on');
    set(handles.pbExportSM,'Visible','on');
    set(handles.pushbutton20,'Visible','on');
    set(handles.pbShowMapSM,'Visible','on');
    set(handles.pbNavLFTSM,'Visible','on');
    set(handles.pbNavUPSM,'Visible','on');
    set(handles.pbNavRGHTSM,'Visible','on');
    set(handles.pbNavDWNSM,'Visible','on');
    set(handles.pbShowPositionSM,'Visible','on');
    set(handles.pbMoveToXYSM,'Visible','on');
    set(handles.pbTextPositionSM,'Visible','on');
    set(handles.popuScaleSM,'Visible','on');
    set(handles.popupColorSM,'Visible','on');
    set(handles.edEnterTextSM,'Visible','off');
    set(handles.text21,'Visible','off');
    set(handles.text1,'Visible','on');
    set(handles.checkbox15,'Visible','off');
    set(handles.checkbTrace,'Visible','on');
    
    
    if state.navigator.toggletext==1
        
        
        for indtext = 1:length(state.navigator.textList) %plots all saved text
            
            text(state.navigator.xtextList(indtext),state.navigator.ytextList(indtext),state.navigator.textList(indtext),'HorizontalAlignment','center','BackgroundColor',[1 1 1])
        end
    end
end
state.navigator.saveTemp=1;
SaveTempvar(hObject, eventdata, handles);





function SMShowPosition(hObject, eventdata, handles)
% hObject    handle to pbShowPositionSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state


turnOffMotorButtons;
motorGetPosition();
turnOnMotorButtons;

state.navigator.xpos2=state.motor.lastPositionRead(1);
state.navigator.ypos2=state.motor.lastPositionRead(2);

state.navigator.xposReal=state.motor.lastPositionRead(1);
state.navigator.yposReal=state.motor.lastPositionRead(2);
state.navigator.zposReal=state.motor.lastPositionRead(3);


state.navigator.xposRela=state.navigator.xposReal - state.navigator.xposRelaOffset;
state.navigator.yposRela=state.navigator.yposReal - state.navigator.yposRelaOffset;
state.navigator.zposRela=state.navigator.zposReal - state.navigator.zposRelaOffset;
state.navigator.zRange=((state.navigator.zposReal)./26000)*100;

set(handles.text23,'String',state.navigator.xposRela);
set(handles.text24,'String',state.navigator.yposRela);
set(handles.text25,'String',state.navigator.zposRela);



state.navigator.yscale=get(handles.popuScaleSM,'Value');


switch state.navigator.yscale
    
    case 1
        
        
        state.navigator.offsetttt= 25000./2;
        
    case 2
        
        
        state.navigator.offsetttt= 12000./2;
        
    case 3
        
        
        state.navigator.offsetttt= 6000./2;
        
    case 4
        
        
        state.navigator.offsetttt= 2500./2;
        
    case 5
        
        
        state.navigator.offsetttt= 1250./2;
        
        
        
    case 6
        state.navigator.offsetttt= 250./2;
        
end




scatter(state.navigator.xpos2,state.navigator.ypos2);
set(handles.axes3, 'ylim', [state.navigator.ypos2-state.navigator.offsetttt state.navigator.ypos2+state.navigator.offsetttt], 'xlim', [state.navigator.xpos2-state.navigator.offsetttt state.navigator.xpos2+state.navigator.offsetttt]);





line([state.navigator.xpos2 state.navigator.xpos2],[state.navigator.minycross state.navigator.maxycross]); %center crosshair for current
line([state.navigator.minxcross state.navigator.maxxcross],[state.navigator.ypos2 state.navigator.ypos2]);



if state.navigator.ImgBox==1
    
    
    state.navigator.ImgSizeY2=state.navigator.ImgSizeY3;
    state.navigator.ImgSizeX2=state.navigator.ImgSizeX3;
    
    state.navigator.ImgSizeX=state.navigator.ImgSizeX2./state.acq.zoomFactor;
    state.navigator.ImgSizeY=state.navigator.ImgSizeY2./state.acq.zoomFactor;
    
    
    
    
    
    line([(state.navigator.xpos2+(state.navigator.ImgSizeX/2)) ((state.navigator.xpos2+state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2); %rough borders of image
    line([(state.navigator.xpos2-(state.navigator.ImgSizeX/2)) (state.navigator.xpos2-(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
    
    line([(state.navigator.xpos2+(state.navigator.ImgSizeX/2)) (state.navigator.xpos2-(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2+(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
    line([(state.navigator.xpos2-(state.navigator.ImgSizeX/2)) (state.navigator.xpos2+(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2-(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
    
    
end
if state.navigator.motorlimit==1
    line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4); %rough borders of sutter movement
    line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
    line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
    line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
end

SMPlotAll(hObject, eventdata, handles);

grid(gca,'minor')
if state.navigator.GridOn==0
    grid off
    
end


function SMShowMap(hObject, eventdata, handles)
% hObject    handle to pbShowMapSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state

state.navigator.windowpres=0;
if ishandle(100)
    state.navigator.windowpres=1;
end

figure(100);

if state.navigator.windowpres==0
    set(gcf,'Position',[50 50 900 700]);
end


scatter(state.navigator.xpos2,state.navigator.ypos2);
set(gca, 'xlim', [state.navigator.MotorlimitMinX state.navigator.MotorlimitMaxX], 'ylim', [state.navigator.MotorlimitMinY state.navigator.MotorlimitMaxY]);


if state.navigator.motorlimit==1
    line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4); %rough borders of sutter movement
    line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
    line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
    line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
end

SMPlotAll(hObject, eventdata, handles);

xlabel('micrometer (back/front)');
ylabel('micrometer (left/right)');


grid(gca,'minor')

if state.navigator.GridOn==0
    grid off
    
end
title(char(state.userSettingsName,datestr(now)),'FontSize',14);



function SMPlotCurrent(hObject, eventdata, handles)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
global state
scatter(state.navigator.xpos2,state.navigator.ypos2);
set(handles.axes3, 'ylim', [state.navigator.ypos2-state.navigator.offsetttt state.navigator.ypos2+state.navigator.offsetttt], 'xlim', [state.navigator.xpos2-state.navigator.offsetttt state.navigator.xpos2+state.navigator.offsetttt]);




line([state.navigator.xpos2 state.navigator.xpos2],[state.navigator.minycross state.navigator.maxycross]); %center crosshair for current
line([state.navigator.minxcross state.navigator.maxxcross],[state.navigator.ypos2 state.navigator.ypos2]);



if state.navigator.ImgBox==1
    
    
    state.navigator.ImgSizeY2=state.navigator.ImgSizeY3;
    state.navigator.ImgSizeX2=state.navigator.ImgSizeX3;
    
    
    state.navigator.ImgSizeX=state.navigator.ImgSizeX2./state.acq.zoomFactor;
    state.navigator.ImgSizeY=state.navigator.ImgSizeY2./state.acq.zoomFactor;
    
    
    
    
    
    line([(state.navigator.xpos2+(state.navigator.ImgSizeX/2)) ((state.navigator.xpos2+state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2); %rough borders of image
    
    line([(state.navigator.xpos2-(state.navigator.ImgSizeX/2)) (state.navigator.xpos2-(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
    
    line([(state.navigator.xpos2+(state.navigator.ImgSizeX/2)) (state.navigator.xpos2-(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2+(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
    line([(state.navigator.xpos2-(state.navigator.ImgSizeX/2)) (state.navigator.xpos2+(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2-(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
    
    
end



if state.navigator.motorlimit==1
    line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4); %rough borders of sutter movement
    line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
    line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
    line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
end





grid(gca,'minor')
if state.navigator.GridOn==0
    grid off
    
end



function SMPlotAll(hObject, eventdata, handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global state

if   state.navigator.markingon==1
    for ind = 1:length(state.navigator.x) %plots all saved ROIs
        if state.navigator.colorindex(ind)==1 %gray
            text(state.navigator.x(ind),state.navigator.y(ind),num2str(ind),'HorizontalAlignment','center','BackgroundColor',[0.5 0.5 0.5])
        end
        if state.navigator.colorindex(ind)==2 %green
            text(state.navigator.x(ind),state.navigator.y(ind),num2str(ind),'HorizontalAlignment','center','BackgroundColor',[0 1 0])
        end
        if state.navigator.colorindex(ind)==3 %red
            text(state.navigator.x(ind),state.navigator.y(ind),num2str(ind),'HorizontalAlignment','center','BackgroundColor',[1 0 0])
        end
        if state.navigator.colorindex(ind)==4 %blue
            text(state.navigator.x(ind),state.navigator.y(ind),num2str(ind),'HorizontalAlignment','center','BackgroundColor',[0 1 1])
        end
    end
    
end
%plot SAVED


if length(state.navigator.xsaveyes)>0
    
    %state.navigator.saveyes=get(handles.checkbox15,'Value');
    
    
    
    if state.navigator.editsav==1
        if (state.navigator.startvalSave+1)~=state.files.fileCounter
            state.navigator.startvalSave=state.files.fileCounter-1;
        end
        state.navigator.editsav=0;
    end
    
    state.navigator.xsaveyes(state.navigator.xsaveyes==0)=nan;
    state.navigator.ysaveyes(state.navigator.ysaveyes==0)=nan;
    
    if   state.navigator.savedon==1
        
        if   state.navigator.startvalSave:length(state.navigator.xsaveyes)~=0
            for sy = state.navigator.startvalSave:length(state.navigator.xsaveyes)
                
                
                
                
                
                
                if state.navigator.ImgBox==1
                    
                    switch state.navigator.saveObject(sy)
                        
                        case 1
                            state.navigator.ImgSizeY2=state.navigator.objective1Y;
                            state.navigator.ImgSizeX2=state.navigator.objective1X;
                        case 2
                            state.navigator.ImgSizeY2=state.navigator.objective2Y;
                            state.navigator.ImgSizeX2=state.navigator.objective2X;
                        case 3
                            state.navigator.ImgSizeY2=state.navigator.objective3Y;
                            state.navigator.ImgSizeX2=state.navigator.objective3X;
                        case 4
                            state.navigator.ImgSizeY2=state.navigator.objective4Y;
                            state.navigator.ImgSizeX2=state.navigator.objective4X;
                        case 5
                            state.navigator.ImgSizeY2=state.navigator.objective5Y;
                            state.navigator.ImgSizeX2=state.navigator.objective5X;
                            
                        otherwise
                            return
                    end
                    
                    
                    savedzoomX=state.navigator.ImgSizeX2;
                    savedzoomY=state.navigator.ImgSizeY2;
                    savedzoomX=savedzoomX./state.navigator.zoomsaveyes(sy);
                    savedzoomY=savedzoomY./state.navigator.zoomsaveyes(sy);
                    
                    
                    
                    line([(state.navigator.xsaveyes(sy)+(savedzoomX/2)) ((state.navigator.xsaveyes(sy)+(savedzoomX/2)))],[(state.navigator.ysaveyes(sy)-(savedzoomY/2)) (state.navigator.ysaveyes(sy)+(savedzoomY/2))],'Color',[0.65 0.65 0.65],'LineWidth',1.5); %rough borders of image
                    line([(state.navigator.xsaveyes(sy)-(savedzoomX/2)) (state.navigator.xsaveyes(sy)-(savedzoomX/2))],[(state.navigator.ysaveyes(sy)-(savedzoomY/2)) (state.navigator.ysaveyes(sy)+(savedzoomY/2))],'Color',[0.65 0.65 0.65],'LineWidth',1.5);
                    
                    line([(state.navigator.xsaveyes(sy)+(savedzoomX/2)) (state.navigator.xsaveyes(sy)-(savedzoomX/2))],[(state.navigator.ysaveyes(sy)+(savedzoomY/2)) (state.navigator.ysaveyes(sy)+(savedzoomY/2))],'Color',[0.65 0.65 0.65],'LineWidth',1.5);
                    line([(state.navigator.xsaveyes(sy)-(savedzoomX/2)) (state.navigator.xsaveyes(sy)+(savedzoomX/2))],[(state.navigator.ysaveyes(sy)-(savedzoomY/2)) (state.navigator.ysaveyes(sy)-(savedzoomY/2))],'Color',[0.65 0.65 0.65],'LineWidth',1.5);
                end
                text(state.navigator.xsaveyes(sy),state.navigator.ysaveyes(sy),num2str(sy),'HorizontalAlignment','center','BackgroundColor',[1 1 1],'EdgeColor','black')
                
                
                
                
                
            end
        end
        
        
        
        if state.navigator.useprevioussaves==1
            
            for syp = 1:length(state.navigator.yPrevSaved)
                
                
                text(state.navigator.xPrevSaved(syp),state.navigator.yPrevSaved(syp),['L',num2str(syp)],'HorizontalAlignment','center','BackgroundColor',[1 1 1],'EdgeColor','black')
            end
            
        end
        
        
        
        
        
        
    end
    
    %plot SAVED
end

if state.navigator.toggletext==1
    
    if   state.navigator.texton==1
        
        for indtext = 1:length(state.navigator.textList) %plots all saved text
            
            
            
            text(state.navigator.xtextList(indtext),state.navigator.ytextList(indtext),state.navigator.textList(indtext),'HorizontalAlignment','center','BackgroundColor',[1 1 1])
        end
        
    end
end

set(handles.axes3,'YGrid','on')
set(handles.axes3,'XGrid','on')

if state.navigator.GridOn==0
    grid off
    
end

if state.navigator.toggletext==1
    
    if   state.navigator.trackon==1
        
        if state.navigator.xtrackList(1)~=0
            
            
            hold on
            
            
            for tra = 1:state.navigator.tracktrack
                trackp=plot(state.navigator.xtrackList(:,tra),state.navigator.ytrackList(:,tra),'r');
            end
            set(trackp, 'LineWidth', 2);
            
            hold off
        end
    end
end



if state.navigator.InvertX == 1 && state.navigator.InvertY == 1
    
    set(gca,'xdir','reverse','ydir','reverse');
    
elseif state.navigator.InvertX == 1
    
    set(gca,'xdir','reverse');
    
elseif state.navigator.InvertY == 1
    
    set(gca,'ydir','reverse');
    
end






function SMMoveToXY(hObject, eventdata, handles)
% hObject    handle to pbMoveToXYSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global state






set(handles.text21,'String','Pick position. Right click to abort');

set(handles.text21,'Visible','on');





set(handles.pbZeroSM,'Visible','off');
set(handles.pbDelteROIsSM,'Visible','off');
set(handles.pbTrackSM,'Visible','off');
set(handles.pbAddTextSM,'Visible','off');
set(handles.pbUndoTextSM,'Visible','off');
set(handles.pbToggleTextSM,'Visible','off');
set(handles.pbAddPositionSM,'Visible','off');
set(handles.pbUpdateScaleSM,'Visible','off');
set(handles.pbExportSM,'Visible','off');
set(handles.pushbutton20,'Visible','off');
set(handles.pbShowMapSM,'Visible','off');
set(handles.pbNavLFTSM,'Visible','off');
set(handles.pbNavUPSM,'Visible','off');
set(handles.pbNavRGHTSM,'Visible','off');
set(handles.pbNavDWNSM,'Visible','off');
set(handles.pbShowPositionSM,'Visible','off');
set(handles.pbMoveToXYSM,'Visible','off');
set(handles.pbTextPositionSM,'Visible','off');
set(handles.popuScaleSM,'Visible','off');
set(handles.popupColorSM,'Visible','off');
set(handles.text1,'Visible','off');
set(handles.checkbox15,'Visible','off');
set(handles.checkbTrace,'Visible','off');


[state.navigator.ydirect,state.navigator.xdirect buttonp] = ginput(1);

set(handles.text21,'Visible','off');
if buttonp~=1;
    
    set(handles.pbZeroSM,'Visible','on');
    set(handles.pbDelteROIsSM,'Visible','on');
    set(handles.pbTrackSM,'Visible','on');
    set(handles.pbAddTextSM,'Visible','on');
    set(handles.pbUndoTextSM,'Visible','on');
    set(handles.pbToggleTextSM,'Visible','off');
    set(handles.pbAddPositionSM,'Visible','on');
    set(handles.pbUpdateScaleSM,'Visible','on');
    set(handles.pbExportSM,'Visible','on');
    set(handles.pushbutton20,'Visible','on');
    set(handles.pbShowMapSM,'Visible','on');
    set(handles.pbNavLFTSM,'Visible','on');
    set(handles.pbNavUPSM,'Visible','on');
    set(handles.pbNavRGHTSM,'Visible','on');
    set(handles.pbNavDWNSM,'Visible','on');
    set(handles.pbTextPositionSM,'Visible','on');
    set(handles.pbShowPositionSM,'Visible','on');
    set(handles.pbMoveToXYSM,'Visible','on');
    set(handles.popuScaleSM,'Visible','on');
    set(handles.popupColorSM,'Visible','on');
    set(handles.text1,'Visible','on');
    set(handles.checkbox15,'Visible','off');
    set(handles.checkbTrace,'Visible','on');
    
    return
    
else
    
    if length(state.navigator.xdirect)== 0;
        return
    else
        
        
        if state.navigator.xdirect > 12000
            set(handles.text21,'Visible','on');
            pause(1.5);
            set(handles.text21,'Visible','off');
            return
        end
        
        if state.navigator.xdirect < -12000
            set(handles.text21,'Visible','on');
            pause(1.5);
            set(handles.text21,'Visible','off');
            return
        end
        
        if state.navigator.ydirect > 12000
            set(handles.text21,'Visible','on');
            pause(1.5);
            set(handles.text21,'Visible','off');
            return
        end
        if state.navigator.ydirect < -12000
            set(handles.text21,'Visible','on');
            pause(1.5);
            set(handles.text21,'Visible','off');
            return
        end
        
        
        
        
        
        
        turnOffMotorButtons;
        motorGetPosition();
        turnOnMotorButtons;
        
        
        
        
        
        
        
        
        
        
        
        
        state.navigator.yscale=get(handles.popuScaleSM,'Value');
        
        
        
        switch state.navigator.yscale
            
            case 1
                
                state.navigator.offsetttt= 25000./2;
                state.navigator.boxsizedirectxmin= state.navigator.xdirect-1000;
                state.navigator.boxsizedirectxmax= state.navigator.xdirect+1000;
                state.navigator.boxsizedirectymin= state.navigator.ydirect-500;
                state.navigator.boxsizedirectymax= state.navigator.ydirect+500;
                
                
                
                
            case 2
                
                
                state.navigator.offsetttt= 12000./2;
                
                
                state.navigator.boxsizedirectxmin= state.navigator.xdirect-400;
                state.navigator.boxsizedirectxmax= state.navigator.xdirect+400;
                state.navigator.boxsizedirectymin= state.navigator.ydirect-200;
                state.navigator.boxsizedirectymax= state.navigator.ydirect+200;
                
                
            case 3
                
                
                state.navigator.offsetttt= 6000./2;
                
                
                state.navigator.boxsizedirectxmin= state.navigator.xdirect-200;
                state.navigator.boxsizedirectxmax= state.navigator.xdirect+200;
                state.navigator.boxsizedirectymin= state.navigator.ydirect-100;
                state.navigator.boxsizedirectymax= state.navigator.ydirect+100;
                
            case 4
                
                
                state.navigator.offsetttt= 2500./2;
                
                
                state.navigator.boxsizedirectxmin= state.navigator.xdirect-100;
                state.navigator.boxsizedirectxmax= state.navigator.xdirect+100;
                state.navigator.boxsizedirectymin= state.navigator.ydirect-50;
                state.navigator.boxsizedirectymax= state.navigator.ydirect+50;
                
            case 5
                
                
                state.navigator.offsetttt= 1250./2;
                
                
                
                state.navigator.boxsizedirectxmin= state.navigator.xdirect-40;
                state.navigator.boxsizedirectxmax= state.navigator.xdirect+40;
                state.navigator.boxsizedirectymin= state.navigator.ydirect-20;
                state.navigator.boxsizedirectymax= state.navigator.ydirect+20;
                
            case 6
                
                state.navigator.offsetttt= 250./2;
                
                
                
                state.navigator.boxsizedirectxmin= state.navigator.xdirect-10;
                state.navigator.boxsizedirectxmax= state.navigator.xdirect+10;
                state.navigator.boxsizedirectymin= state.navigator.ydirect-5;
                state.navigator.boxsizedirectymax= state.navigator.ydirect+5;
                
        end
        
        
        
        
        state.motor.absZPosition=state.motor.lastPositionRead(3); %this moves in x and y, but uses the z of the last position the motor was at
        state.motor.absXPosition=state.navigator.ydirect(1);
        state.motor.absYPosition=state.navigator.xdirect(1);
        
        
        
        
        
        
        [state.navigator.ispresentdirectx]=find((state.navigator.boxsizedirectxmin < state.navigator.y) & (state.navigator.y < state.navigator.boxsizedirectxmax)); %looks in allsaved ROIs for match
        [state.navigator.ispresentdirecty]=find((state.navigator.boxsizedirectymin < state.navigator.x) & (state.navigator.x < state.navigator.boxsizedirectymax));
        
        
        for checklength = 1:length(state.navigator.ispresentdirectx) %checks existing ROIs to find if match with target position
            for checklength2 = 1:length(state.navigator.ispresentdirecty) %checks existing ROIs to find if match with target position
                
                
                if state.navigator.ispresentdirectx(checklength)==state.navigator.ispresentdirecty(checklength2)
                    
                    
                    
                    state.motor.absZPosition=state.navigator.z(state.navigator.ispresentdirecty(checklength2)); %select the position that matched x and y from the direct input.
                    state.motor.absXPosition=state.navigator.x(state.navigator.ispresentdirecty(checklength2));
                    state.motor.absYPosition=state.navigator.y(state.navigator.ispresentdirecty(checklength2));
                    indexpositionroi=state.navigator.ispresentdirecty(checklength2);
                    set(handles.text21,'String',['moving to position ' num2str(indexpositionroi) '..']);
                    
                    
                    
                    set(handles.text21,'Visible','on');
                end
            end
            
        end
        
        
        [state.navigator.ispresentdirectx]=find((state.navigator.boxsizedirectxmin < state.navigator.ysaveyes) & (state.navigator.ysaveyes < state.navigator.boxsizedirectxmax)); %looks in allsaved ROIs for match
        [state.navigator.ispresentdirecty]=find((state.navigator.boxsizedirectymin < state.navigator.xsaveyes) & (state.navigator.xsaveyes < state.navigator.boxsizedirectymax));
        
        
        
        for checklength = 1:length(state.navigator.ispresentdirectx) %checks existing ROIs to find if match with target position
            for checklength2 = 1:length(state.navigator.ispresentdirecty) %checks existing ROIs to find if match with target position
                
                
                if state.navigator.ispresentdirectx(checklength)==state.navigator.ispresentdirecty(checklength2)
                    
                    
                    
                    state.motor.absZPosition=state.navigator.zsaveyes(state.navigator.ispresentdirecty(checklength2)); %select the position that matched x and y from the direct input.
                    state.motor.absXPosition=state.navigator.xsaveyes(state.navigator.ispresentdirecty(checklength2));
                    state.motor.absYPosition=state.navigator.ysaveyes(state.navigator.ispresentdirecty(checklength2));
                    indexPosition=state.navigator.ispresentdirecty(checklength2);
                    set(handles.text21,'String',['moving to position SAVED ' num2str(indexPosition) '..']);
                    
                    
                    
                    set(handles.text21,'Visible','on');
                end
            end
            
        end
        
        
        
        
        
        
        
        motorStartMove()
        newPosn = [state.motor.absXPosition state.motor.absYPosition state.motor.absZPosition state.motor.absZZPosition];
        if state.motor.motorOn
            
        end
        
        pause(1);
        
        set(handles.text21,'Visible','off');
        set(handles.text21,'String','Click within black borders of map');
        
        
        
        
        
        
        
        scatter(state.motor.absXPosition,state.motor.absYPosition);
        set(handles.axes3, 'ylim', [state.navigator.ypos2-state.navigator.offsetttt state.navigator.ypos2+state.navigator.offsetttt], 'xlim', [state.navigator.xpos2-state.navigator.offsetttt state.navigator.xpos2+state.navigator.offsetttt]);
        
        
        
        
        line([state.motor.absXPosition state.motor.absXPosition],[state.navigator.minxcross state.navigator.maxxcross]); %center crosshair for current
        line([state.navigator.minycross state.navigator.maxycross],[state.motor.absYPosition state.motor.absYPosition]);
        
        
        
        if state.navigator.ImgBox==1
            
            
            
            
            state.navigator.ImgSizeX=state.navigator.ImgSizeX2./state.acq.zoomFactor;
            state.navigator.ImgSizeY=state.navigator.ImgSizeY2./state.acq.zoomFactor;
            
            
            
            
            
            line([(state.motor.absXPosition-(state.navigator.ImgSizeX/2)) ((state.motor.absXPosition+state.navigator.ImgSizeX/2))],[(state.motor.absYPosition-(state.navigator.ImgSizeY/2)) (state.motor.absYPosition-(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2); %rough borders of image
            line([(state.motor.absXPosition+(state.navigator.ImgSizeX/2)) ((state.motor.absXPosition+state.navigator.ImgSizeX/2))],[(state.motor.absYPosition+(state.navigator.ImgSizeY/2)) (state.motor.absYPosition-(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
            
            line([(state.motor.absXPosition-(state.navigator.ImgSizeX/2)) ((state.motor.absXPosition-state.navigator.ImgSizeX/2))],[(state.motor.absYPosition-(state.navigator.ImgSizeY/2)) (state.motor.absYPosition+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
            line([(state.motor.absXPosition+(state.navigator.ImgSizeX/2)) ((state.motor.absXPosition-state.navigator.ImgSizeX/2))],[(state.motor.absYPosition+(state.navigator.ImgSizeY/2)) (state.motor.absYPosition+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
            
            
            
        end
        
        
        if state.navigator.motorlimit==1
            line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4); %rough borders of sutter movement
            line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
            line([state.navigator.MotorlimitMinX state.navigator.MotorlimitMaxX],[state.navigator.MotorlimitMinY state.navigator.MotorlimitMinY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
            line([state.navigator.MotorlimitMaxX state.navigator.MotorlimitMinX],[state.navigator.MotorlimitMaxY state.navigator.MotorlimitMaxY],'Color',[0 0 0],'LineStyle','--','LineWidth',4);
            
        end
        
        
        
        SMPlotAll(hObject, eventdata, handles);
        
        grid(gca,'minor')
        if state.navigator.GridOn==0
            grid off
            
        end
        
    end
    
    
    
    
    
end
set(handles.pbZeroSM,'Visible','on');
set(handles.pbDelteROIsSM,'Visible','on');
set(handles.pbTrackSM,'Visible','on');
set(handles.pbAddTextSM,'Visible','on');
set(handles.pbUndoTextSM,'Visible','on');
set(handles.pbToggleTextSM,'Visible','off');
set(handles.pbAddPositionSM,'Visible','on');
set(handles.pbUpdateScaleSM,'Visible','on');
set(handles.pbExportSM,'Visible','on');
set(handles.pushbutton20,'Visible','on');
set(handles.pbShowMapSM,'Visible','on');
set(handles.pbNavLFTSM,'Visible','on');
set(handles.pbNavUPSM,'Visible','on');
set(handles.pbNavRGHTSM,'Visible','on');
set(handles.pbNavDWNSM,'Visible','on');
set(handles.pbTextPositionSM,'Visible','on');
set(handles.pbShowPositionSM,'Visible','on');
set(handles.pbMoveToXYSM,'Visible','on');
set(handles.popuScaleSM,'Visible','on');
set(handles.popupColorSM,'Visible','on');
set(handles.text1,'Visible','on');
set(handles.checkbox15,'Visible','off');
set(handles.checkbTrace,'Visible','on');


function SMGetScale(hObject, eventdata, handles)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


global state

state.navigator.yscale=get(handles.popuScaleSM,'Value');

switch state.navigator.yscale
    
    case 1
        state.navigator.offsetttt= 25000./2;
        state.navigator.nav=1000;
        
    case 2
        
        
        state.navigator.offsetttt= 12000./2;
        state.navigator.nav=400;
        
        
    case 3
        
        
        state.navigator.offsetttt= 6000./2;
        state.navigator.nav=200;
        
    case 4
        
        
        state.navigator.offsetttt= 2500./2;
        state.navigator.nav=100;
        
        
    case 5
        
        
        state.navigator.offsetttt= 1250./2;
        state.navigator.nav=40;
        
        
    case 6
        
        
        state.navigator.offsetttt= 250./2;
        state.navigator.nav=10;
end






function SMExport(hObject, eventdata, handles)
% hObject    handle to pbExportSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state



state.navigator.textexport=cell(1,5);
state.navigator.textexport{1,1}='Position ROI-X';
state.navigator.textexport{1,2}='Position ROI-Y';
state.navigator.textexport{1,3}='Text ROI-X';
state.navigator.textexport{1,4}='Text ROI-Y';
state.navigator.textexport{1,5}='Text ROI content';


state.navigator.indexposition=length(state.navigator.x);
state.navigator.currentlengthText=length(state.navigator.xtextList);

state.navigator.textexport(2:state.navigator.indexposition+1,1)=num2cell(state.navigator.y(1:state.navigator.indexposition));
state.navigator.textexport(2:state.navigator.indexposition+1,2)=num2cell(state.navigator.x(1:state.navigator.indexposition));

state.navigator.textexport(2:state.navigator.currentlengthText+1,3)=num2cell(state.navigator.ytextList(1:state.navigator.currentlengthText));
state.navigator.textexport(2:state.navigator.currentlengthText+1,4)=num2cell(state.navigator.xtextList(1:state.navigator.currentlengthText));
state.navigator.textexport(2:state.navigator.currentlengthText+1,5)=(state.navigator.textList(1:state.navigator.currentlengthText));





[file,path] = uiputfile('*.txt','Save Map Coordinates As');

if file==0
    return
    
end


pathsave=(fullfile(path,file));
pathsaveshort=(fullfile(path,file));
pathsaveshort(end-3:end)=[] ;
fileshort=file;
fileshort(end-3:end)=[];

if state.navigator.SaveText==1
    outfid = fopen(pathsave, 'wt');
    
    if outfid < 0
        error('file creation failed');
    end
    fwrite(outfid, evalc('disp(state.navigator.textexport)'));
    fclose(outfid);
    
end







if state.navigator.SaveMap==1
    
    if ishandle(100)
        
        figure(100);
        title(char(state.userSettingsName,fileshort,datestr(now)),'FontSize',14);
        
        
        filenameVarmap = [num2str(fileshort),'.fig '];
        
        
        
        
        
        saveas(figure(100),pathsaveshort);
        
        disp(['Saved as:',path, filenameVarmap]);
        
        
        
        
        
    else
        
        
        
        current=figure;
        
        
        set(gca, 'xlim', [-15000 15000], 'ylim', [-15000 15000]);
        
        
        
        line([(state.navigator.xpos2+(state.navigator.ImgSizeX/2)) ((state.navigator.xpos2+state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2); %rough borders of sutter movement
        line([(state.navigator.xpos2-(state.navigator.ImgSizeX/2)) (state.navigator.xpos2-(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
        
        line([(state.navigator.xpos2+(state.navigator.ImgSizeX/2)) (state.navigator.xpos2-(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2+(state.navigator.ImgSizeY/2)) (state.navigator.ypos2+(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
        line([(state.navigator.xpos2-(state.navigator.ImgSizeX/2)) (state.navigator.xpos2+(state.navigator.ImgSizeX/2))],[(state.navigator.ypos2-(state.navigator.ImgSizeY/2)) (state.navigator.ypos2-(state.navigator.ImgSizeY/2))],'Color',[0.5 0.5 0.5],'LineWidth',2);
        
        
        SMPlotAll(hObject, eventdata, handles);
        
        xlabel('micrometer (back/front)');
        ylabel('micrometer (left/right)');
        
        
        grid(gca,'minor')
        
        if state.navigator.GridOn==0
            grid off
            
        end
        
        
        title(char(state.userSettingsName,fileshort,datestr(now)),'FontSize',14);
        
        saveas(current,pathsaveshort);
        
        
        filenameVarmap = [num2str(fileshort),'.fig '];
        
        disp(['Saved as:',path, filenameVarmap]);
        
        
        
        filenameVar = state.navigator.filenameVarTemp;
        
        try delete(filenameVar);
        catch return
        end
        
        
        
        
        close(current);
    end
    
end
if state.navigator.SaveText==1
    disp(['Saved as:',path, file]);
end


if state.navigator.SaveRaw==1
    %save variables
    varName=state.navigator;
    filenameVar = [num2str(fileshort),'.mat '];
    
    
    save (filenameVar, '-struct','varName' );
    
    state.navigator.saveTemp=0;
    
    disp(['Saved as:',path, filenameVar]);
end


function SMDelteROIs(hObject, eventdata, handles)
% hObject    handle to pbDelteROIsSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global state





choice = questdlg('Delete all Navigator Data?', ...
    'Clear All', ...
    'Yes','No','Yes');

switch choice
    case 'No'
        return
    case 'Yes'
end



state.navigator.xsaveyes=[];
state.navigator.ysaveyes=[];

state.navigator.x=[];
state.navigator.y=[];
state.navigator.z=[];
state.navigator.colorindex=[];
state.navigator.currentlengthText=0;
state.navigator.textList={0};
state.navigator.ytextList=[];
state.navigator.xtextList=[];

state.navigator.textList(end)=[];

state.navigator.startvalSave=state.files.fileCounter;
state.navigator.editsav=1;

state.navigator.xtrackList=0;
state.navigator.ytrackList=[];
state.navigator.tracktrack=0;
state.navigator.textexport=cell(1,5);
state.navigator.textexport{1,1}='Position ROI-X';
state.navigator.textexport{1,2}='Position ROI-Y';
state.navigator.textexport{1,3}='Text ROI-X';
state.navigator.textexport{1,4}='Text ROI-Y';
state.navigator.textexport{1,5}='Text ROI content';
state.navigator.tracktoggle=0;

SMGetScale(hObject, eventdata, handles);



SMPlotCurrent(hObject, eventdata, handles);

state.navigator.saveTemp=1;
SaveTempvar(hObject, eventdata, handles);







function SMAddText(hObject, eventdata, handles)
% hObject    handle to pbAddTextSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pbAddTextSM,'Visible','Off');
set(handles.pbUndoTextSM,'Visible','Off');
set(handles.pbToggleTextSM,'Visible','Off');
set(handles.pbShowPositionSM,'Visible','Off');

set(handles.edEnterTextSM,'Visible','On');
set(handles.pbTextPositionSM,'Visible','On');
set(handles.text21,'Visible','On');
set(handles.text21,'String','Enter Text. Click "Pick Position"');


set(handles.pbZeroSM,'Visible','off');
set(handles.pbDelteROIsSM,'Visible','off');
set(handles.pbTrackSM,'Visible','off');
set(handles.pbAddTextSM,'Visible','off');
set(handles.pbUndoTextSM,'Visible','off');
set(handles.pbToggleTextSM,'Visible','off');
set(handles.pbExportSM,'Visible','off');
set(handles.pushbutton20,'Visible','off');
set(handles.pbShowMapSM,'Visible','off');
set(handles.pbMoveToXYSM,'Visible','off');








function SMAddPositionSM(hObject, eventdata, handles)
% hObject    handle to pbAddPositionSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global state
turnOffMotorButtons;
motorGetPosition();
turnOnMotorButtons;

state.navigator.xpos=state.motor.lastPositionRead(1);
state.navigator.ypos=state.motor.lastPositionRead(2);
state.navigator.zpos=state.motor.lastPositionRead(3);

[state.navigator.ispresent]=find(state.navigator.x==state.navigator.xpos);

for checklength = 1:length(state.navigator.ispresent) %checks existing ROIs so not to duplicate ROI
    if state.navigator.y(state.navigator.ispresent(checklength))==state.navigator.ypos
        
        return
        
    end
    
end

state.navigator.colorchoice=get(handles.popupColorSM,'Value'); %get color choice

state.navigator.indexposition=length(state.navigator.x);

state.navigator.x(state.navigator.indexposition+1)=state.navigator.xpos;%add new x to ROI list
%x=[];
state.navigator.y(state.navigator.indexposition+1)=state.navigator.ypos;%add new y to ROI
%x=[];
state.navigator.z(state.navigator.indexposition+1)=state.navigator.zpos;%add new z to ROI

state.navigator.colorindex(state.navigator.indexposition+1)=state.navigator.colorchoice;%add new color to ROI list



state.navigator.yscale=get(handles.popuScaleSM,'Value');


switch state.navigator.yscale
    
    case 1
        
        state.navigator.offsetttt= 25000./2;
        
    case 2
        
        
        state.navigator.offsetttt= 12000./2;
        
    case 3
        
        
        state.navigator.offsetttt= 6000./2;
        
    case 4
        
        
        state.navigator.offsetttt= 2500./2;
        
    case 5
        
        
        state.navigator.offsetttt= 1250./2;
        
    case 6
        
        
        state.navigator.offsetttt= 250./2;
        
end





for ind = 1:length(state.navigator.x) %plots all saved ROIs
    switch state.navigator.colorindex(ind)
        case 1 %gray
            text(state.navigator.x(ind),state.navigator.y(ind),num2str(ind),'HorizontalAlignment','center','BackgroundColor',[0.5 0.5 0.5])
            
        case 2 %green
            text(state.navigator.x(ind),state.navigator.y(ind),num2str(ind),'HorizontalAlignment','center','BackgroundColor',[0 1 0])
            
        case 3 %red
            text(state.navigator.x(ind),state.navigator.y(ind),num2str(ind),'HorizontalAlignment','center','BackgroundColor',[1 0 0])
            
        case 4 %blue
            text(state.navigator.x(ind),state.navigator.y(ind),num2str(ind),'HorizontalAlignment','center','BackgroundColor',[0 1 1])
    end
end




if state.navigator.toggletext==1
    
    
    for indtext = 1:length(state.navigator.textList) %plots all saved text
        
        text(state.navigator.xtextList(indtext),state.navigator.ytextList(indtext),state.navigator.textList(indtext),'HorizontalAlignment','center','BackgroundColor',[1 1 1])
    end
    
end

text(state.navigator.x(ind),state.navigator.y(ind),num2str(ind),'HorizontalAlignment','center','EdgeColor','black'); %last ROI added


set(handles.axes3,'YGrid','on')
set(handles.axes3,'XGrid','on')

if state.navigator.GridOn==0
    grid off
    
end
state.navigator.saveTemp=1;
SaveTempvar(hObject, eventdata, handles);





function varargout = SMBuildNavigatorGUI(varargin)
% SMBUILDNAVIGATORGUI MATLAB code for SMBuildNavigatorGUI.fig
%      SMBUILDNAVIGATORGUI, by itself, creates a new SMBUILDNAVIGATORGUI or raises the existing
%      singleton*.
%
%      H = SMBUILDNAVIGATORGUI returns the handle to a new SMBUILDNAVIGATORGUI or the handle to
%      the existing singleton*.
%
%      SMBUILDNAVIGATORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SMBUILDNAVIGATORGUI.M with the given input arguments.
%
%      SMBUILDNAVIGATORGUI('Property','Value',...) creates a new SMBUILDNAVIGATORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SMBuildNavigatorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SMBuildNavigatorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SMBuildNavigatorGUI

% Last Modified by GUIDE v2.5 30-Aug-2012 15:08:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SMBuildNavigatorGUI_OpeningFcn, ...
    'gui_OutputFcn',  @SMBuildNavigatorGUI_OutputFcn, ...
    'gui_LayoutFcn',  @SMBuildNavigatorGUI_LayoutFcn, ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SMBuildNavigatorGUI is made visible.
function SMBuildNavigatorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SMBuildNavigatorGUI (see VARARGIN)

% Choose default command line output for SMBuildNavigatorGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initializeStuff(hObject, eventdata, handles)

function initializeStuff(hObject, eventdata, handles)
global state

loadTempvar(hObject, eventdata, handles);



SMShowPosition(hObject, eventdata, handles);




try switch state.navigator.currentobj
        
        case 1
            
            Untitled_3_Callback(hObject, eventdata, handles)
            
        case 2
            
            Untitled_5_Callback(hObject, eventdata, handles)
            
        case 3
            
            Untitled_7_Callback(hObject, eventdata, handles)
            
        case 4
            
            Untitled_9_Callback(hObject, eventdata, handles)
            
            
        case 5
            
            Untitled_11_Callback(hObject, eventdata, handles)
            
    end
    
    
catch
    
    return
    
end

if state.navigator.loadTemp==0
    SMReset(hObject, eventdata, handles);
end

if state.navigator.SaveMap==1
    set(handles.Untitled_31,'Checked','on');
end

if state.navigator.SaveText==1
    set(handles.Untitled_30,'Checked','on');
end

if state.navigator.SaveRaw==1
    set(handles.Untitled_32,'Checked','on');
end

if state.navigator.motorlimit==1;
    set(handles.Untitled_33,'Checked','on');
end

if state.navigator.loadTemp==1;
    set(handles.Untitled_35,'Checked','on');
end

if state.navigator.crosshair==1;
    set(handles.Untitled_34,'Checked','on');
end


if state.navigator.texton==1;
    set(handles.Untitled_23,'Checked','on');
end

if state.navigator.savedon==1;
    set(handles.Untitled_21,'Checked','on');
end

if state.navigator.trackon==1;
    
    set(handles.Untitled_20,'Checked','on');
end


if state.navigator.ImgBox==1;
    
    set(handles.Untitled_22,'Checked','on');
end

if state.navigator.markingon==1;
    
    set(handles.Untitled_24,'Checked','on');
end



if state.navigator.GridOn==1;
    
    set(handles.Untitled_37,'Checked','on');
end


set(handles.pbNavRGHTSM,'String',state.navigator.TopButton);
set(handles.pbNavDWNSM,'String',state.navigator.LeftButton);
set(handles.pbNavUPSM,'String',state.navigator.RightButton);
set(handles.pbNavLFTSM,'String',state.navigator.BottomButton);




state.navigator.useprevioussaves=0;







% UIWAIT makes SMBuildNavigatorGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function SMReset(hObject, eventdata, handles);

global state






state.navigator.xsaveyes=[];
state.navigator.ysaveyes=[];

state.navigator.x=[];
state.navigator.y=[];
state.navigator.z=[];
state.navigator.colorindex=[];
state.navigator.currentlengthText=0;
state.navigator.textList={0};
state.navigator.ytextList=[];
state.navigator.xtextList=[];

state.navigator.textList(end)=[];

state.navigator.startvalSave=state.files.fileCounter;
state.navigator.editsav=1;

state.navigator.xtrackList=0;
state.navigator.ytrackList=[];
state.navigator.tracktrack=0;
state.navigator.textexport=cell(1,5);
state.navigator.textexport{1,1}='Position ROI-X';
state.navigator.textexport{1,2}='Position ROI-Y';
state.navigator.textexport{1,3}='Text ROI-X';
state.navigator.textexport{1,4}='Text ROI-Y';
state.navigator.textexport{1,5}='Text ROI content';
state.navigator.tracktoggle=0;

SMGetScale(hObject, eventdata, handles);



SMPlotCurrent(hObject, eventdata, handles);

state.navigator.saveTemp=1;
SaveTempvar(hObject, eventdata, handles);


% --- Outputs from this function are returned to the command line.
function varargout = SMBuildNavigatorGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15


% --- Executes on button press in pbDelteROIsSM.
function pbDelteROIsSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbDelteROIsSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMDelteROIs(hObject, eventdata, handles);



% --- Executes on button press in pbZeroSM.
function pbZeroSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbZeroSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMZero(hObject, eventdata, handles);


% --- Executes on selection change in popuScaleSM.
function popuScaleSM_Callback(hObject, eventdata, handles)
% hObject    handle to popuScaleSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popuScaleSM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popuScaleSM


% --- Executes during object creation, after setting all properties.
function popuScaleSM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popuScaleSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbUpdateScaleSM.
function pbUpdateScaleSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbUpdateScaleSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMUpdateScales(hObject, eventdata, handles);


% --- Executes on button press in pbExportSM.
function pbExportSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbExportSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMExport(hObject, eventdata, handles);


% --- Executes on button press in pbShowMapSM.
function pbShowMapSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbShowMapSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMShowMap(hObject, eventdata, handles);


% --- Executes on button press in tbTrackOffSM.
function tbTrackOffSM_Callback(hObject, eventdata, handles)
% hObject    handle to tbTrackOffSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state.navigator.tracktoggle=1;


% --- Executes on button press in pbMoveToXYSM.
function pbMoveToXYSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbMoveToXYSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMMoveToXY(hObject, eventdata, handles);


% --- Executes on button press in pbTrackSM.
function pbTrackSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbTrackSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMTrack(hObject, eventdata, handles);

% --- Executes on button press in pbAddTextSM.
function pbAddTextSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddTextSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMAddText(hObject, eventdata, handles);


% --- Executes on button press in pbUndoTextSM.
function pbUndoTextSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbUndoTextSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMUndoText(hObject, eventdata, handles);


% --- Executes on button press in pbToggleTextSM.
function pbToggleTextSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbToggleTextSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMToggleTextS(hObject, eventdata, handles);



function edEnterTextSM_Callback(hObject, eventdata, handles)
% hObject    handle to edEnterTextSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edEnterTextSM as text
%        str2double(get(hObject,'String')) returns contents of edEnterTextSM as a double


% --- Executes during object creation, after setting all properties.
function edEnterTextSM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edEnterTextSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbTextPositionSM.
function pbTextPositionSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbTextPositionSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMTextPosition(hObject, eventdata, handles);


% --- Executes on button press in pbShowPositionSM.
function pbShowPositionSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbShowPositionSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMShowPosition(hObject, eventdata, handles);



% --- Executes on button press in pbAddPositionSM.
function pbAddPositionSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddPositionSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMAddPositionSM(hObject, eventdata, handles);


% --- Executes on selection change in popupColorSM.
function popupColorSM_Callback(hObject, eventdata, handles)
% hObject    handle to popupColorSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupColorSM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupColorSM


% --- Executes during object creation, after setting all properties.
function popupColorSM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupColorSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbNavRGHTSM.
function pbNavRGHTSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbNavRGHTSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMNavRGHT(hObject, eventdata, handles);


% --- Executes on button press in pbNavDWNSM.
function pbNavDWNSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbNavDWNSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMNavDWN(hObject, eventdata, handles);


% --- Executes on button press in pbNavUPSM.
function pbNavUPSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbNavUPSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMbNavUP(hObject, eventdata, handles);


% --- Executes on button press in pbNavLFTSM.
function pbNavLFTSM_Callback(hObject, eventdata, handles)
% hObject    handle to pbNavLFTSM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SMNavLFT(hObject, eventdata, handles);



% --- Executes on button press in checkbTrace.
function checkbTrace_Callback(hObject, eventdata, handles)
% hObject    handle to checkbTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbTrace


% --- Executes on button press in pbAddTextSM.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state

filenameVars = uigetfile('*.mat');

state.navigator = load(filenameVars);
SMPlotAll(hObject, eventdata, handles);



% --------------------------------------------------------------------
function objectiveMenu_Callback(hObject, eventdata, handles)
% hObject    handle to objectiveMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global state
set(handles.Untitled_3,'Visible','off');
set(handles.Untitled_5,'Visible','off');
set(handles.Untitled_7,'Visible','off');
set(handles.Untitled_9,'Visible','off');
set(handles.Untitled_11,'Visible','off');



if state.navigator.objective1on==1;
    set(handles.Untitled_3,'Visible','on');
    set(handles.Untitled_3,'Label',state.navigator.objective1);
end

if state.navigator.objective2on==1;
    set(handles.Untitled_5,'Visible','on');
    set(handles.Untitled_5,'Label',state.navigator.objective2);
end


if state.navigator.objective3on==1;
    set(handles.Untitled_7,'Visible','on');
    set(handles.Untitled_7,'Label',state.navigator.objective3);
end


if state.navigator.objective4on==1;
    set(handles.Untitled_9,'Visible','on');
    set(handles.Untitled_9,'Label',state.navigator.objective4);
end


if state.navigator.objective5on==1;
    set(handles.Untitled_11,'Visible','on');
    set(handles.Untitled_11,'Label',state.navigator.objective5);
end








% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
set(handles.Untitled_3,'Checked','on');
set(handles.Untitled_5,'Checked','off');
set(handles.Untitled_7,'Checked','off');
set(handles.Untitled_9,'Checked','off');
set(handles.Untitled_11,'Checked','off');
set(handles.tCurrentObj,'String',state.navigator.objective1);
state.navigator.currentobj=1;
state.navigator.ImgSizeY2=state.navigator.objective1Y;
state.navigator.ImgSizeX2=state.navigator.objective1X;
state.navigator.ImgSizeY3=state.navigator.objective1Y;
state.navigator.ImgSizeX3=state.navigator.objective1X;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);



% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
set(handles.Untitled_3,'Checked','off');
set(handles.Untitled_5,'Checked','on');
set(handles.Untitled_7,'Checked','off');
set(handles.Untitled_9,'Checked','off');
set(handles.Untitled_11,'Checked','off');
set(handles.tCurrentObj,'String',state.navigator.objective2);
state.navigator.currentobj=2;
state.navigator.ImgSizeY2=state.navigator.objective2Y;
state.navigator.ImgSizeX2=state.navigator.objective2X;
state.navigator.ImgSizeY3=state.navigator.objective2Y;
state.navigator.ImgSizeX3=state.navigator.objective2X;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);




% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
set(handles.Untitled_3,'Checked','off');
set(handles.Untitled_5,'Checked','off');
set(handles.Untitled_7,'Checked','on');
set(handles.Untitled_9,'Checked','off');
set(handles.Untitled_11,'Checked','off');
set(handles.tCurrentObj,'String',state.navigator.objective3);
state.navigator.currentobj=3;
state.navigator.ImgSizeY2=state.navigator.objective3Y;
state.navigator.ImgSizeX2=state.navigator.objective3X;
state.navigator.ImgSizeY3=state.navigator.objective3Y;
state.navigator.ImgSizeX3=state.navigator.objective3X;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);



% --------------------------------------------------------------------
function Untitled_9_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
set(handles.Untitled_3,'Checked','off');
set(handles.Untitled_5,'Checked','off');
set(handles.Untitled_7,'Checked','off');
set(handles.Untitled_9,'Checked','on');
set(handles.Untitled_11,'Checked','off');
set(handles.tCurrentObj,'String',state.navigator.objective4);
state.navigator.currentobj=4;
state.navigator.ImgSizeY2=state.navigator.objective4Y;
state.navigator.ImgSizeX2=state.navigator.objective4X;
state.navigator.ImgSizeY3=state.navigator.objective4Y;
state.navigator.ImgSizeX3=state.navigator.objective4X;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);


% --------------------------------------------------------------------
function Untitled_11_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
set(handles.Untitled_3,'Checked','off');
set(handles.Untitled_5,'Checked','off');
set(handles.Untitled_7,'Checked','off');
set(handles.Untitled_9,'Checked','off');
set(handles.Untitled_11,'Checked','on');
set(handles.tCurrentObj,'String',state.navigator.objective5);
state.navigator.currentobj=5;
state.navigator.ImgSizeY2=state.navigator.objective5Y;
state.navigator.ImgSizeX2=state.navigator.objective5X;
state.navigator.ImgSizeY3=state.navigator.objective5Y;
state.navigator.ImgSizeX3=state.navigator.objective5X;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --------------------------------------------------------------------
function Untitled_18_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Untitled_19_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --------------------------------------------------------------------
function Untitled_33_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



global state
state.navigator.motorlimit=1;

set(handles.Untitled_33,'Checked','on');

if state.navigator.u33toggle==0
    state.navigator.motorlimit=0;
    set(handles.Untitled_33,'Checked','off');
    state.navigator.u33toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u33toggle=0;

SaveTempvar(hObject, eventdata, handles);
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);





% --------------------------------------------------------------------
function Untitled_34_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



global state
state.navigator.crosshair=1;

set(handles.Untitled_34,'Checked','on');

if state.navigator.u34toggle==0
    state.navigator.crosshair=0;
    set(handles.Untitled_34,'Checked','off');
    state.navigator.u34toggle=1;
    
    
    if state.navigator.crosshair==0
        
        
        state.navigator.minycross=0;
        state.navigator.maxycross=0;
        state.navigator.minxcross=0;
        state.navigator.maxxcross=0;
        
    end
    
    
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u34toggle=0;

if state.navigator.crosshair==1
    
    
    state.navigator.minycross=4*-12000;
    state.navigator.maxycross=4*12000;
    state.navigator.minxcross=4*-12000;
    state.navigator.maxxcross=4*12000;
    
end

SaveTempvar(hObject, eventdata, handles);
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);


% --------------------------------------------------------------------
function Untitled_35_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



global state
state.navigator.loadTemp = 1;

set(handles.Untitled_35,'Checked','on');

if state.navigator.u35toggle==0
    state.navigator.loadTemp=0;
    set(handles.Untitled_35,'Checked','off');
    state.navigator.u35toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u35toggle=0;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

SaveTempvar(hObject, eventdata, handles);



% --------------------------------------------------------------------
function Untitled_20_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



global state
state.navigator.trackon=1;

set(handles.Untitled_20,'Checked','on');

if state.navigator.u20toggle==0
    state.navigator.trackon=0;
    set(handles.Untitled_20,'Checked','off');
    state.navigator.u20toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u20toggle=0;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

SaveTempvar(hObject, eventdata, handles);



% --------------------------------------------------------------------
function Untitled_21_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state.navigator.savedon=1;

set(handles.Untitled_21,'Checked','on');

if state.navigator.u21toggle==0
    state.navigator.savedon=0;
    set(handles.Untitled_21,'Checked','off');
    state.navigator.u21toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u21toggle=0;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

SaveTempvar(hObject, eventdata, handles);


% --------------------------------------------------------------------
function Untitled_22_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state.navigator.ImgBox=1;

set(handles.Untitled_22,'Checked','on');

if state.navigator.u22toggle==0
    state.navigator.ImgBox=0;
    set(handles.Untitled_22,'Checked','off');
    state.navigator.u22toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u22toggle=0;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

SaveTempvar(hObject, eventdata, handles);




% --------------------------------------------------------------------
function Untitled_23_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state.navigator.texton=1;

set(handles.Untitled_23,'Checked','on');

if state.navigator.u23toggle==0
    state.navigator.texton=0;
    set(handles.Untitled_23,'Checked','off');
    state.navigator.u23toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u23toggle=0;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

SaveTempvar(hObject, eventdata, handles);


% --------------------------------------------------------------------
function Untitled_24_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state.navigator.markingon=1;

set(handles.Untitled_24,'Checked','on');

if state.navigator.u24toggle==0
    state.navigator.markingon=0;
    set(handles.Untitled_24,'Checked','off');
    state.navigator.u24toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u24toggle=0;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

SaveTempvar(hObject, eventdata, handles);




% --------------------------------------------------------------------
function Untitled_30_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global state
state.navigator.SaveText=1;

set(handles.Untitled_30,'Checked','on');

if state.navigator.u30toggle==0
    state.navigator.SaveText=0;
    set(handles.Untitled_30,'Checked','off');
    state.navigator.u30toggle=1;
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u30toggle=0;
SaveTempvar(hObject, eventdata, handles);





% --------------------------------------------------------------------
function Untitled_31_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global state
state.navigator.SaveMap=1;

set(handles.Untitled_31,'Checked','on');

if state.navigator.u31toggle==0
    state.navigator.SaveMap=0;
    set(handles.Untitled_31,'Checked','off');
    state.navigator.u31toggle=1;
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u31toggle=0;
SaveTempvar(hObject, eventdata, handles);

% --------------------------------------------------------------------
function Untitled_32_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state.navigator.SaveRaw=1;

set(handles.Untitled_32,'Checked','on');

if state.navigator.u32toggle==0
    state.navigator.SaveRaw=0;
    set(handles.Untitled_32,'Checked','off');
    state.navigator.u32toggle=1;
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u32toggle=0;
SaveTempvar(hObject, eventdata, handles);




% --------------------------------------------------------------------
function Untitled_37_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state.navigator.GridOn=1;

set(handles.Untitled_37,'Checked','on');

if state.navigator.u37toggle==0
    state.navigator.GridOn=0;
    set(handles.Untitled_37,'Checked','off');
    state.navigator.u37toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u37toggle=0;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

SaveTempvar(hObject, eventdata, handles);

function Untitled_38_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state.navigator.InvertY=1;
set(handles.Untitled_38,'Checked','on');

if state.navigator.u38toggle==0
    state.navigator.InvertY=0;
    set(handles.Untitled_38,'Checked','off');
    state.navigator.u38toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u38toggle=0;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

SaveTempvar(hObject, eventdata, handles);

function Untitled_39_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global state
state.navigator.InvertX=1;
set(handles.Untitled_39,'Checked','on');

if state.navigator.u39toggle==0
    state.navigator.InvertX=0;
    set(handles.Untitled_39,'Checked','off');
    state.navigator.u39toggle=1;
    SMPlotCurrent(hObject, eventdata, handles);
    SMPlotAll(hObject, eventdata, handles);
    SaveTempvar(hObject, eventdata, handles);
    return
end
state.navigator.u39toggle=0;
SMPlotCurrent(hObject, eventdata, handles);
SMPlotAll(hObject, eventdata, handles);

SaveTempvar(hObject, eventdata, handles);




function loadTempvar(hObject, eventdata, handles)
global state



filenameVar = state.navigator.filenameVarTemp;
try
        state.navigator = load(filenameVar);
        state.navigator.useprevioussaves=0;
catch
    return
end

function SaveTempvar(hObject, eventdata, handles)
global state

if state.navigator.saveTemp==1;
    varName=state.navigator;
    filenameVar = state.navigator.filenameVarTemp;
    
    
    save (filenameVar, '-struct','varName' );
end




% --- Creates and returns a handle to the GUI figure.
function h1 = SMBuildNavigatorGUI_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', 217.002075195313, ...
    'taginfo', struct(...
    'figure', 2, ...
    'uipanel', 5, ...
    'axes', 2, ...
    'popupmenu', 3, ...
    'text', 9, ...
    'pushbutton', 20, ...
    'edit', 2, ...
    'listbox', 2, ...
    'checkbox', 2), ...
    'override', 0, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0, ...
    'lastSavedFile', 'C:\ScanImage\SCANIMAGE_r3.8RC1\Samples\Meyer_Navigator\SMBuildNavigatorGUI.m', ...
    'lastFilename', 'C:\ScanImage\SCANIMAGE_r3.8RC1\Samples\Meyer_Navigator\SMBuildNavigator.fig');
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
    'Units','characters',...
    'Color',[0.87843137254902 0.874509803921569 0.890196078431373],...
    'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
    'IntegerHandle','off',...
    'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
    'MenuBar','none',...
    'Name','NAVIGATOR',...
    'NumberTitle','off',...
    'PaperPosition',get(0,'defaultfigurePaperPosition'),...
    'Position',[103.8 28.3846153846154 102.4 33.3846153846154],...
    'Resize','off',...
    'HandleVisibility','callback',...
    'UserData',[],...
    'Tag','figure1',...
    'Visible','on',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel13';

h2 = uipanel(...
    'Parent',h1,...
    'Units','characters',...
    'Title','Navigator',...
    'Tag','uipanel13',...
    'Clipping','on',...
    'Position',[0.4 0.0769230769230769 101.8 28.5384615384615],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'axes3';

h3 = axes(...
    'Parent',h2,...
    'Units','characters',...
    'Position',[8.6 3.84615384615384 60.8 22.8461538461538],...
    'CameraPosition',[0.5 0.5 9.16025403784439],...
    'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
    'Color',get(0,'defaultaxesColor'),...
    'ColorOrder',get(0,'defaultaxesColorOrder'),...
    'LooseInset',[9.256 2.40307692307692 6.764 1.63846153846154],...
    'XColor',get(0,'defaultaxesXColor'),...
    'YColor',get(0,'defaultaxesYColor'),...
    'ZColor',get(0,'defaultaxesZColor'),...
    'Tag','axes3',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.SerializedAnnotationV7 = struct(...
    'LegendInformation', struct(...
    'IconDisplayStyle', 'on'));

h4 = get(h3,'title');

set(h4,...
    'Parent',h3,...
    'Units','data',...
    'FontUnits','points',...
    'BackgroundColor','none',...
    'Color',[0 0 0],...
    'DisplayName',blanks(0),...
    'EdgeColor','none',...
    'EraseMode','normal',...
    'DVIMode','auto',...
    'FontAngle','normal',...
    'FontName','Helvetica',...
    'FontSize',10,...
    'FontWeight','normal',...
    'HorizontalAlignment','center',...
    'LineStyle','-',...
    'LineWidth',0.5,...
    'Margin',2,...
    'Position',[0.498355263157895 1.02188552188552 1.00005459937205],...
    'Rotation',0,...
    'String',blanks(0),...
    'Interpreter','tex',...
    'VerticalAlignment','bottom',...
    'ButtonDownFcn',[],...
    'CreateFcn', {@local_CreateFcn, [], appdata} ,...
    'DeleteFcn',[],...
    'BusyAction','queue',...
    'HandleVisibility','off',...
    'HelpTopicKey',blanks(0),...
    'HitTest','on',...
    'Interruptible','on',...
    'SelectionHighlight','on',...
    'Serializable','on',...
    'Tag',blanks(0),...
    'UserData',[],...
    'Visible','on',...
    'XLimInclude','on',...
    'YLimInclude','on',...
    'ZLimInclude','on',...
    'CLimInclude','on',...
    'ALimInclude','on',...
    'IncludeRenderer','on',...
    'Clipping','off');

appdata = [];
appdata.SerializedAnnotationV7 = struct(...
    'LegendInformation', struct(...
    'IconDisplayStyle', 'on'));

h5 = get(h3,'xlabel');

set(h5,...
    'Parent',h3,...
    'Units','data',...
    'FontUnits','points',...
    'BackgroundColor','none',...
    'Color',[0 0 0],...
    'DisplayName',blanks(0),...
    'EdgeColor','none',...
    'EraseMode','normal',...
    'DVIMode','auto',...
    'FontAngle','normal',...
    'FontName','Helvetica',...
    'FontSize',10,...
    'FontWeight','normal',...
    'HorizontalAlignment','center',...
    'LineStyle','-',...
    'LineWidth',0.5,...
    'Margin',2,...
    'Position',[0.498355263157895 -0.0791245791245792 1.00005459937205],...
    'Rotation',0,...
    'String',blanks(0),...
    'Interpreter','tex',...
    'VerticalAlignment','cap',...
    'ButtonDownFcn',[],...
    'CreateFcn', {@local_CreateFcn, [], appdata} ,...
    'DeleteFcn',[],...
    'BusyAction','queue',...
    'HandleVisibility','off',...
    'HelpTopicKey',blanks(0),...
    'HitTest','on',...
    'Interruptible','on',...
    'SelectionHighlight','on',...
    'Serializable','on',...
    'Tag',blanks(0),...
    'UserData',[],...
    'Visible','on',...
    'XLimInclude','on',...
    'YLimInclude','on',...
    'ZLimInclude','on',...
    'CLimInclude','on',...
    'ALimInclude','on',...
    'IncludeRenderer','on',...
    'Clipping','off');

appdata = [];
appdata.SerializedAnnotationV7 = struct(...
    'LegendInformation', struct(...
    'IconDisplayStyle', 'on'));

h6 = get(h3,'ylabel');

set(h6,...
    'Parent',h3,...
    'Units','data',...
    'FontUnits','points',...
    'BackgroundColor','none',...
    'Color',[0 0 0],...
    'DisplayName',blanks(0),...
    'EdgeColor','none',...
    'EraseMode','normal',...
    'DVIMode','auto',...
    'FontAngle','normal',...
    'FontName','Helvetica',...
    'FontSize',10,...
    'FontWeight','normal',...
    'HorizontalAlignment','center',...
    'LineStyle','-',...
    'LineWidth',0.5,...
    'Margin',2,...
    'Position',[-0.09375 0.496632996632997 1.00005459937205],...
    'Rotation',90,...
    'String',blanks(0),...
    'Interpreter','tex',...
    'VerticalAlignment','bottom',...
    'ButtonDownFcn',[],...
    'CreateFcn', {@local_CreateFcn, [], appdata} ,...
    'DeleteFcn',[],...
    'BusyAction','queue',...
    'HandleVisibility','off',...
    'HelpTopicKey',blanks(0),...
    'HitTest','on',...
    'Interruptible','on',...
    'SelectionHighlight','on',...
    'Serializable','on',...
    'Tag',blanks(0),...
    'UserData',[],...
    'Visible','on',...
    'XLimInclude','on',...
    'YLimInclude','on',...
    'ZLimInclude','on',...
    'CLimInclude','on',...
    'ALimInclude','on',...
    'IncludeRenderer','on',...
    'Clipping','off');

appdata = [];
appdata.SerializedAnnotationV7 = struct(...
    'LegendInformation', struct(...
    'IconDisplayStyle', 'on'));

h7 = get(h3,'zlabel');

set(h7,...
    'Parent',h3,...
    'Units','data',...
    'FontUnits','points',...
    'BackgroundColor','none',...
    'Color',[0 0 0],...
    'DisplayName',blanks(0),...
    'EdgeColor','none',...
    'EraseMode','normal',...
    'DVIMode','auto',...
    'FontAngle','normal',...
    'FontName','Helvetica',...
    'FontSize',10,...
    'FontWeight','normal',...
    'HorizontalAlignment','right',...
    'LineStyle','-',...
    'LineWidth',0.5,...
    'Margin',2,...
    'Position',[-0.15625 1.27777777777778 1.00005459937205],...
    'Rotation',0,...
    'String',blanks(0),...
    'Interpreter','tex',...
    'VerticalAlignment','middle',...
    'ButtonDownFcn',[],...
    'CreateFcn', {@local_CreateFcn, [], appdata} ,...
    'DeleteFcn',[],...
    'BusyAction','queue',...
    'HandleVisibility','off',...
    'HelpTopicKey',blanks(0),...
    'HitTest','on',...
    'Interruptible','on',...
    'SelectionHighlight','on',...
    'Serializable','on',...
    'Tag',blanks(0),...
    'UserData',[],...
    'Visible','off',...
    'XLimInclude','on',...
    'YLimInclude','on',...
    'ZLimInclude','on',...
    'CLimInclude','on',...
    'ALimInclude','on',...
    'IncludeRenderer','on',...
    'Clipping','off');

appdata = [];
appdata.lastValidTag = 'popuScaleSM';

h8 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'BackgroundColor',[1 1 1],...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('popuScaleSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[1.2 0.384615384615385 10 1.69230769230769],...
    'String',{  '1000'; '400'; '200'; '100'; '40'; '10' },...
    'Style','popupmenu',...
    'Value',1,...
    'tooltip','Select Scale',...
    'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)SMBuildNavigatorGUI('popuScaleSM_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
    'Tag','popuScaleSM');


appdata = [];
appdata.lastValidTag = 'text1';

h9 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Position',[11.2 0.538461538461517 11 1.15384615384615],...
    'String','um/division',...
    'Style','text',...
    'Tag','text1',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbUpdateScaleSM';

h10 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbUpdateScaleSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[22.4 0.384615384615385 15.8 1.69230769230769],...
    'String','Update Scale',...
    'Tag','pbUpdateScaleSM',...
    'tooltip','Apply sacle select on the left to the current display.',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbExportSM';

h11 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbExportSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[60 0.384615384615385 7.6 1.69230769230769],...
    'String','Save',...
    'Tag','pbExportSM',...
    'tooltip','Saves current data (what is saved is specified in the Setting menu bar).',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


appdata = [];
appdata.lastValidTag = 'pbShowMapSM';

h12 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbShowMapSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[38.6 0.384615384615385 21.2 1.69230769230769],...
    'String','Show/Update Map',...
    'tooltip','Opens new window containing the same data for easier viewing. Use Matlab menu tools to zoom in, etc.',...
    'Tag','pbShowMapSM',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'tbTrackOffSM';

h13 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'BackgroundColor',[0.847058823529412 0.16078431372549 0],...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('tbTrackOffSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[72.4 22.8461538461538 23 3.07692307692308],...
    'String','Stop Tracking',...
    'tooltip','Click to stop tracking.',...
    'Tag','tbTrackOffSM',...
    'Visible','off',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbMoveToXYSM';

h14 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'BackgroundColor',[0.8 0.8 1],...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbMoveToXYSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[70.8 22.8461538461538 11 3],...
    'String','Move to',...
    'tooltip','Click and select a point anywhere on graph (within motor range) to move objective to. Z will be kept as current.',...
    'Tag','pbMoveToXYSM',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbTrackSM';

h15 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbTrackSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[86.4 22.8461538461538 11 3],...
    'String','Track',...
    'tooltip','Click to update position as you move. Tick Record Track Movements to draw a red line following your move.',...
    'Tag','pbTrackSM',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel2';

h16 = uipanel(...
    'Parent',h2,...
    'Units','characters',...
    'Title','Navigate Map',...
    'Tag','uipanel2',...
    'Clipping','on',...
    'Position',[70.6 12.3846153846154 27.4 9.69230769230769],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbNavRGHTSM';

h17 = uicontrol(...
    'Parent',h16,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbNavRGHTSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[9.60000000000002 5.69230769230769 8.2 2.53846153846154],...
    'String','Right',...
    'Tag','pbNavRGHTSM',...
    'tooltip','Click to move the map around.',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbNavDWNSM';

h18 = uicontrol(...
    'Parent',h16,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbNavDWNSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[2 3.23076923076923 8.2 2.5],...
    'String','Back',...
    'Tag','pbNavDWNSM',...
    'tooltip','Click to move the map around.',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbNavUPSM';

h19 = uicontrol(...
    'Parent',h16,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbNavUPSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[17 3.15384615384615 8.2 2.5],...
    'String','Front',...
    'Tag','pbNavUPSM',...
    'tooltip','Click to move the map around.',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbNavLFTSM';

h20 = uicontrol(...
    'Parent',h16,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbNavLFTSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[9.60000000000002 0.769230769230768 8.2 2.53846153846154],...
    'String','Left',...
    'Tag','pbNavLFTSM',...
    'tooltip','Click to move the map around.',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbAddTextSM';

h21 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbAddTextSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[71 10.3846153846154 11.6 2],...
    'String','Add Text',...
    'Tag','pbAddTextSM',...
    'tooltip','Click to add a text annotation at the position picked.',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbUndoTextSM';

h22 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbUndoTextSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[84.8 10.3846153846154 12.8 2],...
    'String','Undo Text',...
    'tooltip','Click to delete your last text annotation.',...
    'Tag','pbUndoTextSM',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbToggleTextSM';

h23 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbToggleTextSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[77.4000000000002 8.23076923076922 13.8 2],...
    'String','Text on/off',...
    'Visible','off',...
    'Tag','pbToggleTextSM',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edEnterTextSM';

h24 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'BackgroundColor',[1 1 1],...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('edEnterTextSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[71 10.3076923076923 26.8 2],...
    'String','Enter Text here',...
    'Style','edit',...
    'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)SMBuildNavigatorGUI('edEnterTextSM_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
    'Tag','edEnterTextSM',...
    'Visible','off');

appdata = [];
appdata.lastValidTag = 'pbTextPositionSM';

h25 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'BackgroundColor',[0.749019607843137 0.749019607843137 0],...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbTextPositionSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[79.6000000000001 4.99999999999998 16.4 2.61538461538462],...
    'String','Pick Position',...
    'tooltip','Click to pick the position on map for text to be displayed.',...
    'Tag','pbTextPositionSM',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbShowPositionSM';

h26 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'BackgroundColor',[1 1 0.6],...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbShowPositionSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[78.8000000000001 4.92307692307691 18.4 2.76923076923077],...
    'String','Show Position',...
    'tooltip','Click to center the crosshair on the current objective position.',...
    'Tag','pbShowPositionSM',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbAddPositionSM';

h27 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbAddPositionSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[76.2000000000001 2.76923076923075 23.2 2],...
    'String','Add Current Position',...
    'tooltip','Click to add an incrementing marking at the current objective position in the color picked below.',...
    'Tag','pbAddPositionSM',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popupColorSM';

h28 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'BackgroundColor',[1 1 1],...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('popupColorSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[87.2000000000001 0.769230769230744 11 1.7],...
    'String',{  'gray'; 'green'; 'red'; 'blue' },...
    'Style','popupmenu',...
    'tooltip','Select the color to be used for Add Current Position.',...
    'Value',1,...
    'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)SMBuildNavigatorGUI('popupColorSM_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
    'Tag','popupColorSM');

appdata = [];
appdata.lastValidTag = 'uipanel4';

h29 = uipanel(...
    'Parent',h2,...
    'Units','characters',...
    'Title',blanks(0),...
    'Tag','uipanel4',...
    'Clipping','on',...
    'Position',[75.6 0.384615384615363 24.4 7.61538461538462],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text21';

h30 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'FontWeight','bold',...
    'Position',[60.2 27.4615384615385 40.2 1.15384615384615],...
    'String','Click within black borders of map',...
    'Style','text',...
    'Tag','text21',...
    'Visible','off',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel3';

h31 = uipanel(...
    'Parent',h1,...
    'Units','characters',...
    'Title','Relative',...
    'Tag','uipanel3',...
    'Clipping','on',...
    'Position',[0.4 28.6923076923077 45 4.53846153846154],...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbZeroSM';

h32 = uicontrol(...
    'Parent',h31,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbZeroSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[2 1 13.8 1.84615384615385],...
    'String','Zero',...
    'Tag','pbZeroSM',...
    'tooltip','Click to set the Relative coordinates shown on the right to 0.',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text3';

h33 = uicontrol(...
    'Parent',h31,...
    'Units','characters',...
    'Position',[19.8 2.53846153846154 4.8 1.07692307692308],...
    'String','X:',...
    'Style','text',...
    'Tag','text3',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text4';

h34 = uicontrol(...
    'Parent',h31,...
    'Units','characters',...
    'Position',[20.4 1.07692307692308 3.8 1.38461538461538],...
    'String','Y:',...
    'Style','text',...
    'Tag','text4',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text5';

h35 = uicontrol(...
    'Parent',h31,...
    'Units','characters',...
    'Position',[20.8 0.307692307692308 2.8 1.1],...
    'String','Z:',...
    'Style','text',...
    'Tag','text5',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text23';

h36 = uicontrol(...
    'Parent',h31,...
    'Units','characters',...
    'FontWeight','bold',...
    'Position',[29.8 2.61538461538462 10.4 1.07692307692308],...
    'String','-',...
    'Style','text',...
    'Tag','text23',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text24';

h37 = uicontrol(...
    'Parent',h31,...
    'Units','characters',...
    'FontWeight','bold',...
    'Position',[29.8 1.53846153846154 10.4 1.07692307692308],...
    'String','-',...
    'Style','text',...
    'Tag','text24',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text25';

h38 = uicontrol(...
    'Parent',h31,...
    'Units','characters',...
    'FontWeight','bold',...
    'Position',[29.8 0.461538461538462 10.4 1.07692307692308],...
    'String','-',...
    'Style','text',...
    'Tag','text25',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'checkbox15';

h39 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('checkbox15_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[52.6000000000002 28.8461538461539 41.6 1.76923076923077],...
    'String','Display Saved Positions (white box)',...
    'Style','checkbox',...
    'Visible','off',...
    'Value',1,...
    'Tag','checkbox15',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pbDelteROIsSM';


h40 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pbDelteROIsSM_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[52.6000000000002 30.9230769230769 17.2 1.69230769230769],...
    'String','Clear All Data',...
    'Tag','pbDelteROIsSM',...
    'tooltip','Click to delete all the annotations entered in the navigator.',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'checkbTrace';

h41 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('checkbTrace_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[46.6000000000002 28.6923076923077 34 1.76923076923077],...
    'String','Record Track Movements',...
    'Style','checkbox',...
    'Tag','checkbTrace',...
    'tooltip','Tick box to draw a red movement path while tracing with the Track button. Can be changed while tracking.',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'pushbutton20';

h42 = uicontrol(...
    'Parent',h2,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('pushbutton20_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[67.8 0.384615384615385 7.4 1.69230769230769],...
    'String','Load',...
    'Tag','pushbutton20',...
    'tooltip','Click to load previous annotation data (.mat files).',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );




appdata = [];
appdata.lastValidTag = 'objectiveMenu';

h43 = uimenu(...
    'Parent',h1,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('objectiveMenu_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Objectives',...
    'Tag','objectiveMenu',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_3';

h44 = uimenu(...
    'Parent',h43,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_3_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','20x',...
    'Tag','Untitled_3',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_5';

h45 = uimenu(...
    'Parent',h43,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_5_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','40x',...
    'Tag','Untitled_5',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_7';


h46 = uimenu(...
    'Parent',h43,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_7_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','100x',...
    'Tag','Untitled_7',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_9';



h72 = uimenu(...
    'Parent',h43,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_9_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','16x',...
    'Tag','Untitled_9',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_11';

h71 = uimenu(...
    'Parent',h43,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_11_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','4x',...
    'Tag','Untitled_11',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


%%%%


h47 = uimenu(...
    'Parent',h1,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_6_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Annotations',...
    'Tag','Untitled_6',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_20';

h48 = uimenu(...
    'Parent',h47,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_20_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Track Tracing',...
    'Tag','Untitled_20',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_21';

h49 = uimenu(...
    'Parent',h47,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_21_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Saved Positions',...
    'Tag','Untitled_21',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_22';

h50 = uimenu(...
    'Parent',h47,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_22_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Scan Boundaries',...
    'Tag','Untitled_22',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );



appdata = [];
appdata.lastValidTag = 'Untitled_23';

h51 = uimenu(...
    'Parent',h47,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_23_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Text',...
    'Tag','Untitled_23',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );



appdata = [];
appdata.lastValidTag = 'Untitled_24';

h61 = uimenu(...
    'Parent',h47,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_24_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Markings',...
    'Tag','Untitled_24',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


appdata = [];
appdata.lastValidTag = 'Untitled_18';

h52 = uimenu(...
    'Parent',h1,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_18_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Settings',...
    'Tag','Untitled_18',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_19';

h53 = uimenu(...
    'Parent',h52,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_19_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Save Button saves..',...
    'Tag','Untitled_19',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_30';

h54 = uimenu(...
    'Parent',h53,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_30_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Coordinates Of Entries (.txt)',...
    'Tag','Untitled_30',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_31';

h55 = uimenu(...
    'Parent',h53,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_31_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Map (.fig)',...
    'Tag','Untitled_31',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_32';

h56 = uimenu(...
    'Parent',h53,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_32_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Navigator State (.mat)',...
    'Tag','Untitled_32',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_33';

h57 = uimenu(...
    'Parent',h52,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_33_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Show Motor Limits',...
    'Tag','Untitled_33',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_34';

h58 = uimenu(...
    'Parent',h52,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_34_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Show Crosshair',...
    'Tag','Untitled_34',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_35';

h59 = uimenu(...
    'Parent',h52,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_35_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Autosave/restore Last Session',...
    'Tag','Untitled_35',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


appdata = [];
appdata.lastValidTag = 'Untitled_37';

h62 = uimenu(...
    'Parent',h52,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_37_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Grid On',...
    'Tag','Untitled_37',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_38';

h63 = uimenu(...
    'Parent',h52,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_38_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Invert Y axis',...
    'Tag','Untitled_38',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'Untitled_39';

h64 = uimenu(...
    'Parent',h52,...
    'Callback',@(hObject,eventdata)SMBuildNavigatorGUI('Untitled_39_Callback',hObject,eventdata,guidata(hObject)),...
    'Label','Invert X axis',...
    'Tag','Untitled_39',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );



appdata = [];
appdata.lastValidTag = 'tCurrentObj';

h60 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'FontSize',14,...
    'Position',[82.8 29.3076923076923 10.4 2.03076923076923],...
    'String','20x',...
    'Style','text',...
    'Tag','tCurrentObj',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

pdata = [];
appdata.lastValidTag = 'text10';

h61 = uicontrol(...
    'Parent',h1,...
    'Units','characters',...
    'Position',[78.2000000000001 31.2307692307692 18.2 1.07692307692308],...
    'String','Current Objective:',...
    'Style','text',...
    'Tag','text10',...
    'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );
hsingleton = h1;


% --- Set application data first then calling the CreateFcn.
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
    names = fieldnames(appdata);
    for i=1:length(names)
        name = char(names(i));
        setappdata(hObject, name, getfield(appdata,name));
    end
end

if ~isempty(createfcn)
    if isa(createfcn,'function_handle')
        createfcn(hObject, eventdata);
    else
        eval(createfcn);
    end
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error(message('MATLAB:guide:StateFieldNotFound', gui_StateFields{ i }, gui_Mfile));
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % SMBUILDNAVIGATORGUI
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % SMBUILDNAVIGATORGUI(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % SMBUILDNAVIGATORGUI('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % SMBUILDNAVIGATORGUI(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~ishghandle(fig,'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
    
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishghandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end
    
    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end
        
        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.
    
    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);
        
        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')
        
        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end
    
    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);
    
    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;
    
    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end
        
        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end
    
    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end
        
        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end
    
    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end
    
    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});
    
    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure);
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
        
        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end
        
        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end
        
        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end
    
    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end
    
    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);
    %workaround for CreateFcn not called to create ActiveX
    if feature('HGUsingMATLABClasses')
        peers=findobj(findall(allchild(gui_hFigure)),'type','uicontrol','style','text');
        for i=1:length(peers)
            if isappdata(peers(i),'Control')
                actxproxy(peers(i));
            end
        end
    end
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
        && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
        (ischar(varargin{1}) ...
        && isequal(ishghandle(varargin{2}), 1) ...
        && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
        ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end








