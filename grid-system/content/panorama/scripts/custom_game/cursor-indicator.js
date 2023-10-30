const FIXED_PER_SECOND = 0.03;

var cursorPerFrame = null;
function updateCursor() {
    var mousePos = GameUI.GetCursorPosition();
    if (mousePos) {
        var worldPos = GameUI.GetScreenWorldPosition(mousePos);
        var sendData = {
            "MouseWorldPos": worldPos
        };
        GameEvents.SendCustomGameEventToServer("PanoramaMouseHoverGridEvent", sendData);
    }
    cursorPerFrame = $.Schedule(FIXED_PER_SECOND, updateCursor);
}
updateCursor();

// Cancel if needed
// if (cursorPerFrame) {
//     CancelScheduled(cursorPerFrame);
// }