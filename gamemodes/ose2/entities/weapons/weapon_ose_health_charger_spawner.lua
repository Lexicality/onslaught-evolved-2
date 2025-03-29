--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

AddCSLuaFile()

--- @class SWEP_OSEHealthChargerSpawner : SWEP_OSEBaseSpawner
local SWEP = SWEP --[[@as SWEP_OSEHealthChargerSpawner]]
--- @type SWEP_OSEBaseSpawner
local BaseClass
DEFINE_BASECLASS("weapon_ose_base_spawner")

SWEP.UseHands = true
SWEP.PrintName = "#weapon_ose_health_charger_spawner"
SWEP.Slot = 2
SWEP.EntityClass = "ose_health_charger"
