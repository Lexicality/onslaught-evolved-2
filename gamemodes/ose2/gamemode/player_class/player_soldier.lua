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

--- @class OSEPlayerSoldier : OSEPlayerBase
local PLAYER = {}

PLAYER.DisplayName = "#ose.player.soldier"
-- No running or jumping allowed
PLAYER.WalkSpeed = 280
PLAYER.RunSpeed = 280
PLAYER.JumpPower = 160
-- Tank tho
PLAYER.MaxHealth = 200
PLAYER.StartHealth = 200
PLAYER.MaxArmor = 100
PLAYER.StartArmor = 100

PLAYER.ValidAmmo = {
	"ammo_ar2",
	"ammo_pistol",
	"ammo_ar2alt",
	"ammo_grenade",
}

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_pistol")
	self.Player:GiveAmmo(144, "Pistol")
	self.Player:Give("weapon_ar2")
	self.Player:GiveAmmo(240, "AR2")
	self.Player:GiveAmmo(4, "AR2AltFire")
	self.Player:Give("weapon_frag")
	self.Player:GiveAmmo(4, "grenade")
	self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass("player_soldier", PLAYER, "player_osebase")
