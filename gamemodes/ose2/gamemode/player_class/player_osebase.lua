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

--- @type GPlayerClass
local BaseClass
DEFINE_BASECLASS("player_default")

--- @class OSEPlayerBase : GPlayerClass
local PLAYER = {}

--- @type string[]
PLAYER.ValidAmmo = {}

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Int", 0, "MoneyVar")
	self.Player:NetworkVar("Int", 1, "TargetClassID")
end

function PLAYER:Init()
	-- Ensure the money var is up to date
	self.Player:GetMoney(true)
end

--- Checks if this class can buy this ammo type
--- @param ammoName string
--- @param ammoData OSEAmmoDefinition
--- @return boolean
function PLAYER:CanBuyAmmo(ammoName, ammoData)
	return table.Find(self.ValidAmmo, ammoName) ~= nil
end

player_manager.RegisterClass("player_osebase", PLAYER, "player_default")
