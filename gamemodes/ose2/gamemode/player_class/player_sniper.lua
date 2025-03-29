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

--- @class OSEPlayerSniper : OSEPlayerBase
local PLAYER = {}

PLAYER.DisplayName = "#ose.player.sniper"
-- You're not expected to move much
PLAYER.WalkSpeed = 270
PLAYER.RunSpeed = 270
PLAYER.JumpPower = 160
-- Don't die
PLAYER.MaxHealth = 80
PLAYER.StartHealth = 80

PLAYER.ValidAmmo = {
	"ammo_357",
	"ammo_crossbow",
}


function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_357")
	self.Player:GiveAmmo(36, "357")
	-- TODO: custom crossbow SWEP? I'm not entirely sure why you would
	self.Player:Give("weapon_crossbow")
	self.Player:GiveAmmo(40, "xbowbolt")
	-- TODO: Wailgun?
	self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass("player_sniper", PLAYER, "player_osebase")
