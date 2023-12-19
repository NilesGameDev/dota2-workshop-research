-- Generated from template

if CCustomNavSystem == nil then
    CCustomNavSystem = class({})
end

function Precache(context)
    --[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

require("ECS")
require("pathing.advanced_nav_system")
require("game_setup")

-- Create the game mode when we activate
function Activate()
    GameRules.AddonTemplate = CCustomNavSystem()
    GameRules.AddonTemplate:InitGameMode()
end

function CCustomNavSystem:InitGameMode()
    print("Template addon is loaded.")
    GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 2)
    GameRules.AdvancedNavSystem = CAdvancedNavSystem()
    GameRules.AdvancedNavSystem:Activate()
    GameSetup:init()
end

-- Evaluate the state of the game
function CCustomNavSystem:OnThink()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        --print( "Template addon script is running." )
    elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    return 1
end
