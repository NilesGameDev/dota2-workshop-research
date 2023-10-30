const CONSUME_EVENT = true;
const CONTINUE_PROCESSING_EVENT = false;

function GetMouseCastTarget() {
    var mouseEntities = GameUI.FindScreenEntities(GameUI.GetCursorPosition());
    var localHeroIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());

    mouseEntities.forEach(ent => $.Msg("In function OnLeftButtonPressed(): ", ent));

    mouseEntities = mouseEntities.filter(function (e) { return e.entityIndex !== localHeroIndex; });

    // TODO: Extract to check for bridge entity at another function instead
    for (var ent of mouseEntities) {
        if (!ent.accurateCollision) continue;

        var isBuilding = Entities.IsBuilding(ent.entityIndex);
        if (!isBuilding) continue;

        var unitName = Entities.GetUnitName(ent.entityIndex);
        $.Msg("Current selected unit name: ", unitName);
        if (unitName !== "npc_dota_bridge") continue;

        return ent.entityIndex;
    }

    for (var ent of mouseEntities) {
        return ent.entityIndex;
    }

    return -1;
}

function BeginMoveState() {
    var order = {
        OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position: [0, 0, 0],
        QueueBehavior: OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
        ShowEffects: false
    };
    (function tic() {
        if (GameUI.IsMouseDown(0)) {
            $.Schedule(1.0 / 30.0, tic);
            var mouseWorldPos = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
            if (mouseWorldPos !== null) {
                if (GameUI.IsMouseDown(1) || GameUI.IsMouseDown(2)) {
                    return;
                }
                order.Position = mouseWorldPos;
                Game.PrepareUnitOrders(order);
            }
        }
    })();
}

function OnLeftButtonPressed() {
    var targetIndex = GetMouseCastTarget();
    if (targetIndex === -1) {
        var cursorPos = GameUI.GetCursorPosition()
        var worldPos = GameUI.GetScreenWorldPosition(cursorPos);
        var sendData = { 
            "HeroId": Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
            "TargetPoint": worldPos,
            "CursorOrigin": GameUI.GetCursorPosition(),
            "ScreenCursorOrigin": Game.ScreenXYToWorld(cursorPos[0], cursorPos[1])
        };
        
        GameEvents.SendCustomGameEventToServer("PanoramaClickEvent", sendData);
    } else {
        var sendData = { 
            "HeroId": Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()),
            "BridgeIndex": targetIndex
        };

        GameEvents.SendCustomGameEventToServer("PanoramaClickPlatformEvent", sendData);
    }
}

// Register game mouse event callback
GameUI.SetMouseCallback(function (eventName, mouseButton) {
    if (GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE)
        return CONTINUE_PROCESSING_EVENT;

    if (eventName === "pressed") {

        // If it is left mouse pressed
        if (mouseButton === 0) {
            OnLeftButtonPressed();
            return CONSUME_EVENT;
        }
    }

    return CONTINUE_PROCESSING_EVENT;
});