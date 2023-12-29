"use strict";

var gridNavDataEventListener = function(event) {
    // $.Msg(event)
    var gridData = event["data"];
    var gridDataAsString = `Grid Position (X = ${gridData.x}, Y = ${gridData.y})`;
    $("#gridnavCoord").text = gridDataAsString;
};

var perFrameMousePos = null;
function startDetectingMousePos() {
    var cursorPos = GameUI.GetCursorPosition();
    if (cursorPos) {
        var mouseWorldPos = GameUI.GetScreenWorldPosition(cursorPos);
        var sendData = {
            "MouseWorldPosition": mouseWorldPos
        };
        
        GameEvents.SendCustomGameEventToServer("PanoramaMouseMoveEvent", sendData)
    }
    
    perFrameMousePos = $.Schedule(0.03, startDetectingMousePos);
}

// startDetectingMousePos();
GameEvents.Subscribe("GridNavData", gridNavDataEventListener);