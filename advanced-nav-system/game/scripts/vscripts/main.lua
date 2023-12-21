if Main == nil then
    Main = class({})
end

require("pathing.advanced_nav_system")
require("core.game_setup")

function Main:main()
    GameRules.AdvancedNavSystem = CAdvancedNavSystem()
    GameRules.AdvancedNavSystem:Activate()
    GameSetup:init()
end