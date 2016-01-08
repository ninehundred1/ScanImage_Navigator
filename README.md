### ScanImage Microscope Navigator


ScanImage GUI plugin to read the stepper motors and show x/y positions of the microscope stage/objective in a coordinate
system. You can move the microscope to any location you click in the GUI, track movements and annotate and store as many coordinates as you like.


##### Setup:

Add the two files (Meyer_NavigatorGUI & SMGetSaveCoordinates) to your Matlab path.

For best use, in ScanImage, select the Meyer_NavigatorGUI.m file in 
Settings>User Functions>appOpen>UserFCN Name. 
This will open the Navigator with each Startup of ScanImage.
To enable the automatic markings of the positions of images acquired ('Saved Positions') 
in the coordinate system, add the second m file (SMGetSaveCoordinates.m) to 
Settings>User Functions>acquisitionDone>UserFCN Name (then press 'save'). 

##### DOCUMENTATION AND SETTINGS ARE EXPLAINED IN THE Meyer_NavigatorGUI.m FILE HEADER. 
FOR A MANUAL SEE MeyerNavigatorMANUAL.jpg






##### Preview:

![alt text](http://i.imgur.com/ERdce7K.jpg "Navigator")