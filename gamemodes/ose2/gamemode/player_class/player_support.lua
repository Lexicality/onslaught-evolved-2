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
	-- TODO: Healthcharge
	-- "repair grenade"??
	-- self.Player:Give("weapon_frag")
	-- self.Player:GiveAmmo(4, "grenade")
	self.Player:SwitchToDefaultWeapon()
end

player_manager.RegisterClass("player_support", PLAYER, "player_osebase")
