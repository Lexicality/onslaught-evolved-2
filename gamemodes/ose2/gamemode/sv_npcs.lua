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

--- @class NPCListDefinition
--- @field Class string
--- @field KeyValues? {[string]: string}
--- @field Material? string
--- @field Model? string
--- @field Name string
--- @field Reward integer
--- @field Skin? integer
--- @field SpawnFlags? integer

SF_NPC_NO_GRENADE_DROP = 131072
SF_NPC_NO_AR2_DROP = 262144
SF_MANHACK_USE_AIR_NODES = 262144

local INFINITE_GRENADES = "999999"

---@param npctab NPCListDefinition
local function cleanKVs(npctab)
	local kvs = npctab.KeyValues

	if kvs == nil then
		npctab.KeyValues = {}
		return
	end

	for key, _ in pairs(kvs) do
		local lowkey = string.lower(key)
		if lowkey == "squadname" or lowkey == "numgrenades" then
			kvs[key] = nil
		end
	end
end

local NPCS_TO_COPY = {
	"CombineElite", "ShotgunSoldier", "npc_antlion", "npc_antlionguard",
	"npc_combine_s", "npc_fastzombie", "npc_fastzombie_torso", "npc_headcrab",
	"npc_headcrab_black", "npc_headcrab_fast", "npc_hunter", "npc_manhack",
	"npc_metropolice", "npc_poisonzombie", "npc_rollermine", "npc_zombie",
	"npc_zombie_torso", "npc_zombine",
}

function GM:SetupNPCs()
	-- We can safely edit this table to our heart's content because list.Get
	-- returns a deep copy
	--- @type {[string]: NPCListDefinition}
	local baseNPCs = list.Get("NPC")
	--- @type {[string]: NPCListDefinition}
	local gmNPCs = list.GetForEdit("OSENPC")
	for _, key in ipairs(NPCS_TO_COPY) do
		local value = baseNPCs[key]
		cleanKVs(value)
		gmNPCs[key] = value
	end

	local npctab;

	npctab = baseNPCs["npc_combine_s"]
	npctab.Reward = 100
	npctab.SpawnFlags = SF_NPC_NO_GRENADE_DROP
	npctab.KeyValues["tacticalvariant"] = "1"
	npctab.KeyValues["additionalequipment"] = "weapon_smg1"
	npctab.KeyValues["NumGrenades"] = INFINITE_GRENADES

	npctab = baseNPCs["CombineElite"]
	npctab.Reward = 140
	npctab.SpawnFlags = SF_NPC_NO_GRENADE_DROP + SF_NPC_NO_AR2_DROP
	npctab.KeyValues["tacticalvariant"] = "1"
	npctab.KeyValues["additionalequipment"] = "weapon_ar2"

	npctab = baseNPCs["ShotgunSoldier"]
	npctab.Reward = 120
	npctab.SpawnFlags = SF_NPC_NO_GRENADE_DROP
	npctab.KeyValues["tacticalvariant"] = "1"
	npctab.KeyValues["additionalequipment"] = "weapon_shotgun"
	npctab.KeyValues["NumGrenades"] = INFINITE_GRENADES

	npctab = baseNPCs["npc_metropolice"]
	npctab.Reward = 50
	npctab.SpawnFlags = 0
	npctab.KeyValues["additionalequipment"] = "weapon_pistol"

	npctab = baseNPCs["npc_hunter"]
	npctab.Reward = 500

	npctab = baseNPCs["npc_manhack"]
	npctab.Reward = 50
	npctab.SpawnFlags = SF_MANHACK_USE_AIR_NODES

	npctab = baseNPCs["npc_rollermine"]
	npctab.Reward = 175
	npctab.KeyValues["uniformsightdist"] = "1"

	npctab = baseNPCs["npc_zombie"]
	npctab.Reward = 75

	npctab = baseNPCs["npc_fastzombie"]
	npctab.Reward = 100

	npctab = baseNPCs["npc_zombine"]
	npctab.Reward = 100

	npctab = baseNPCs["npc_poisonzombie"]
	npctab.Reward = 125
	npctab.KeyValues["crabcount"] = "3"

	npctab = baseNPCs["npc_zombie_torso"]
	npctab.Reward = 50

	npctab = baseNPCs["npc_fastzombie_torso"]
	npctab.Reward = 75

	npctab = baseNPCs["npc_headcrab"]
	npctab.Reward = 33

	npctab = baseNPCs["npc_headcrab_fast"]
	npctab.Reward = 40

	npctab = baseNPCs["npc_headcrab_black"]
	npctab.Reward = 120

	npctab = baseNPCs["npc_antlion"]
	npctab.Reward = 100
	npctab.KeyValues["radius"] = "512"

	npctab = baseNPCs["npc_antlionguard"]
	npctab.Reward = 700
end
