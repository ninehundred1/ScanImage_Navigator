function SMGetSaveCoordinates(eventName,eventData,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



 global state
        
 if state.navigator.useprevioussaves==0
        if state.files.fileCounter<length(state.navigator.xsaveyes)
            
            state.navigator.yPrevSaved=state.navigator.ysaveyes;
            state.navigator.xPrevSaved=state.navigator.xsaveyes;
            state.navigator.xsaveyes=[];
            state.navigator.ysaveyes=[];
            state.navigator.saveObject=[];
            state.navigator.zoomsaveyes=[];
            state.navigator.useprevioussaves=1;
        end
        
 end

        motorGetPosition();
        state.navigator.zsaveyes(state.files.fileCounter-1)=state.motor.absZPosition;%add new z to list
        state.navigator.xsaveyes(state.files.fileCounter-1)=state.motor.absXPosition;%add new x to  list
        state.navigator.ysaveyes(state.files.fileCounter-1)=state.motor.absYPosition;%add new y to list
        state.navigator.zoomsaveyes(state.files.fileCounter-1)=state.acq.zoomFactor;
        state.navigator.saveObject(state.files.fileCounter-1)=state.navigator.currentobj;
        
        
        
        
        
        
varName=state.navigator;
filenameVar = state.navigator.filenameVarTemp;


save (filenameVar, '-struct','varName' );
