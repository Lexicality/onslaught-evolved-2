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
