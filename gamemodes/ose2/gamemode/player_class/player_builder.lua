--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]
AddCSLuaFile()

--- @type OSEPlayerBase
local BaseClass
DEFINE_BASECLASS("player_osebase")

--- @class OSEPlayerBuilder : OSEPlayerBase
local PLAYER = {}

PLAYER.DisplayName = "#ose.player.builder"

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("weapon_physgun")
end

player_manager.RegisterClass("player_builder", PLAYER, "player_osebase")
