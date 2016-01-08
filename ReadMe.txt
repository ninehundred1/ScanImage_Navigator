User ScanImage functions to show x/y positions of the stage/objective in a coordinate
system.

Add the two files (Meyer_NavigatorGUI & SMGetSaveCoordinates) to your Matlab path.

For best use, in ScanImage, select the Meyer_NavigatorGUI.m file in 
Settings>User Functions>appOpen>UserFCN Name. 
This will open the Navigator with each Startup of ScanImage.
To enable the automatic markings of the positions of images acquired ('Saved Positions') 
in the coordinate system, add the second m file (SMGetSaveCoordinates.m) to 
Settings>User Functions>acquisitionDone>UserFCN Name (then press 'save'). 

DOCUMENTATION AND SETTINGS ARE EXPLAINED IN THE Meyer_NavigatorGUI.m FILE HEADER. 
FOR A MANUAL SEE MeyerNavigatorMANUAL.jpg


--
Stephan Meyer, Rockefeller University 2012
meyernsen@gmail.com
