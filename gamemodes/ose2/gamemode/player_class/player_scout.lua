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

--- @class OSEPlayerScout : OSEPlayerBase
local PLAYER = {}

PLAYER.DisplayName = "#ose.player.scout"
-- Gotta go fast
PLAYER.WalkSpeed = 650
PLAYER.RunSpeed = 650
PLAYER.JumpPower = 260

PLAYER.ValidAmmo = {
	"ammo_pistol",
	"ammo_heavy_buckshot",
}


function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_pistol")
	self.Player:GiveAmmo(144, "Pistol")
	self.Player:Give("weapon_ose_super_shotgun")
	self.Player:GiveAmmo(64, "HeavyBuckshot")
	self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass("player_scout", PLAYER, "player_osebase")
