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

DEFINE_BASECLASS("player_default")

--- @class OSEPlayerScout : GPlayerClass
local PLAYER = {}

PLAYER.DisplayName = "#ose.player.scout"
-- Gotta go fast
PLAYER.WalkSpeed = 650
PLAYER.RunSpeed = 650
PLAYER.JumpPower = 260


function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_pistol")
	self.Player:GiveAmmo(144, "Pistol")
	-- TODO Scattergun goes here
	self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass("player_scout", PLAYER, "player_default")
