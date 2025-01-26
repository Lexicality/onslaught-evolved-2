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

SF_NPC_NO_GRENADE_DROP = 131072
SF_NPC_NO_AR2_DROP = 262144
SF_MANHACK_USE_AIR_NODES = 262144

-- This is value Hammer uses if you pick "infinite greanades" from the options
-- list, however it doesn't seem to be an actual magic value, just so many
-- grenades that they might as well be infinite.
local INFINITE_GRENADES = "999999"

--- This gets rid of some unhelpful defaults found in the base gmod npc list
--- @param npctab NPCListDefinition
local function cleanKVs(npctab)
	local kvs = npctab.KeyValues

	if kvs == nil then
		npctab.KeyValues = {}
		return
	end

	for key, _ in pairs(kvs) do
		-- Keyvalues are case insensitive, so helpfully all the values in the
		-- list are of random case and I have to normalise it to clean them out
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

-- These NPCs can only target props on the ground
local MELEE_ONLY_NPCS = {
	"npc_antlion", "npc_antlionguard", "npc_fastzombie", "npc_headcrab",
	"npc_headcrab_black", "npc_headcrab_fast", "npc_poisonzombie", "npc_zombie",
	"npc_zombine",
}

-- These NPCs should be given a massive damage boost to make them more dangerous
local WEAK_NPCS = {
	"npc_fastzombie", "npc_poisonzombie", "npc_zombie", "npc_zombine"
}

-- These NPCs may have been ambiently created and should be removed at the end of the round
local GENERATED_NPCS = {
	"npc_fastzombie_torso", "npc_headcrab", "npc_headcrab_black",
	"npc_headcrab_fast", "npc_manhack", "npc_zombie_torso",
}

--- Sets up the various NPC lists for the rest of the gamemode to use
function GM:SetupNPCs()
	--- Grab a copy of the base gmod NPC list
	--- @type {[string]: NPCListDefinition}
	local baseNPCs = list.Get("NPC")

	--- Store the specific NPCs we wish to have custom spawning in our own list
	--- @type {[string]: NPCListDefinition}
	local gmNPCs = list.GetForEdit("OSENPC")
	for _, key in ipairs(NPCS_TO_COPY) do
		local value = baseNPCs[key]
		cleanKVs(value)
		gmNPCs[key] = value
	end

	-- Make some quick lookup tables
	local meleeNPCs = list.GetForEdit("OSEMelee")
	for _, npc in ipairs(MELEE_ONLY_NPCS) do
		meleeNPCs[npc] = true
	end
	local weakNPCs = list.GetForEdit("OSEWeak")
	for _, npc in ipairs(WEAK_NPCS) do
		weakNPCs[npc] = true
	end
	local generatedNPCs = list.GetForEdit("OSEGenerated")
	for _, npc in ipairs(GENERATED_NPCS) do
		generatedNPCs[npc] = true
	end


	-- Apply our customisations
	local npctab;

	npctab = gmNPCs["npc_combine_s"]
	npctab.Reward = 100
	npctab.SpawnFlags = SF_NPC_NO_GRENADE_DROP
	npctab.KeyValues["tacticalvariant"] = "1"
	npctab.KeyValues["additionalequipment"] = "weapon_smg1"
	npctab.KeyValues["NumGrenades"] = INFINITE_GRENADES

	npctab = gmNPCs["CombineElite"]
	npctab.Reward = 140
	npctab.SpawnFlags = SF_NPC_NO_GRENADE_DROP + SF_NPC_NO_AR2_DROP
	npctab.KeyValues["tacticalvariant"] = "1"
	npctab.KeyValues["additionalequipment"] = "weapon_ar2"

	npctab = gmNPCs["ShotgunSoldier"]
	npctab.Reward = 120
	npctab.SpawnFlags = SF_NPC_NO_GRENADE_DROP
	npctab.KeyValues["tacticalvariant"] = "1"
	npctab.KeyValues["additionalequipment"] = "weapon_shotgun"
	npctab.KeyValues["NumGrenades"] = INFINITE_GRENADES

	npctab = gmNPCs["npc_metropolice"]
	npctab.Reward = 50
	npctab.SpawnFlags = 0
	npctab.KeyValues["additionalequipment"] = "weapon_pistol"

	npctab = gmNPCs["npc_hunter"]
	npctab.Reward = 500

	npctab = gmNPCs["npc_manhack"]
	npctab.Reward = 50
	npctab.SpawnFlags = SF_MANHACK_USE_AIR_NODES

	npctab = gmNPCs["npc_rollermine"]
	npctab.Reward = 175
	npctab.KeyValues["uniformsightdist"] = "1"

	npctab = gmNPCs["npc_zombie"]
	npctab.Reward = 75

	npctab = gmNPCs["npc_fastzombie"]
	npctab.Reward = 100

	npctab = gmNPCs["npc_zombine"]
	npctab.Reward = 100

	npctab = gmNPCs["npc_poisonzombie"]
	npctab.Reward = 125
	npctab.KeyValues["crabcount"] = "3"

	npctab = gmNPCs["npc_zombie_torso"]
	npctab.Reward = 50

	npctab = gmNPCs["npc_fastzombie_torso"]
	npctab.Reward = 75

	npctab = gmNPCs["npc_headcrab"]
	npctab.Reward = 33

	npctab = gmNPCs["npc_headcrab_fast"]
	npctab.Reward = 40

	npctab = gmNPCs["npc_headcrab_black"]
	npctab.Reward = 120

	npctab = gmNPCs["npc_antlion"]
	npctab.Reward = 100
	npctab.KeyValues["radius"] = "512"

	npctab = gmNPCs["npc_antlionguard"]
	npctab.Reward = 700
end
