--[[
 Copyright (C) 2025 Lexi Robinson

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as
 published by the Free Software Foundation, either version 3 of the
 License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.

 You should have received a copy of the GNU Affero General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
