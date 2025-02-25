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
