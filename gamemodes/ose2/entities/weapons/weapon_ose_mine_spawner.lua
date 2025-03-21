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

--- @class SWEP_OSEMineSpawner : SWEP_OSEBaseSpawner
local SWEP = SWEP --[[@as SWEP_OSEMineSpawner]]
--- @type SWEP_OSEBaseSpawner
local BaseClass
DEFINE_BASECLASS("weapon_ose_base_spawner")

SWEP.UseHands = true
SWEP.PrintName = "#weapon_ose_mine_spawner"
SWEP.Slot = 5
SWEP.EntityClass = "ose_mine"
