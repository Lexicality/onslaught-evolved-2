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

--- @class OSEPlayerSupport : OSEPlayerBase
local PLAYER = {}

PLAYER.DisplayName = "#ose.player.support"
-- Zoop! Don't die!
PLAYER.WalkSpeed = 500
PLAYER.RunSpeed = 500
PLAYER.JumpPower = 220
PLAYER.MaxHealth = 90
PLAYER.StartHealth = 90


PLAYER.ValidAmmo = {
	-- TODO
}

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_pistol")
	self.Player:GiveAmmo(144, "Pistol")
	self.Player:Give("weapon_medkit")
	-- "repair grenade"??
	-- self.Player:Give("weapon_frag")
	-- self.Player:GiveAmmo(4, "grenade")
	self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass("player_support", PLAYER, "player_osebase")
