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

--- @class OSEPlayerEngineer : OSEPlayerBase
local PLAYER = {}

PLAYER.DisplayName = "#ose.player.engineer"
-- No running or jumping allowed
PLAYER.WalkSpeed = 300
PLAYER.RunSpeed = 300
PLAYER.JumpPower = 160
-- Very slight boost in health
PLAYER.MaxHealth = 120
PLAYER.StartHealth = 120

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()
	self.Player:Give("weapon_pistol")
	self.Player:GiveAmmo(144, "Pistol")
	self.Player:Give("weapon_shotgun")
	self.Player:GiveAmmo(64, "Buckshot")
	self.Player:Give("weapon_physcannon")
	-- TODO: Engineering tools go here
	self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass("player_engineer", PLAYER, "player_osebase")
