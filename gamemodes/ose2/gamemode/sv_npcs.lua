--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- @type SGM
local BaseClass
DEFINE_BASECLASS("gamemode_base")

SF_NPC_NO_GRENADE_DROP = 131072
SF_NPC_NO_AR2_DROP = 262144
SF_MANHACK_USE_AIR_NODES = 262144

-- This is value Hammer uses if you pick "infinite greanades" from the options
-- list, however it doesn't seem to be an actual magic value, just so many
-- grenades that they might as well be infinite.
local INFINITE_GRENADES = "999999"

local DEFAULT_NPC_REWARD = 50

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
	"npc_headcrab_fast", "npc_manhack", "npc_zombie_torso", "npc_grenade_frag"
}

local NPC_MODELS = {
	"models/combine_soldier.mdl", "models/combine_super_soldier.mdl",
	"models/combine_soldier_prisonguard.mdl", "models/police.mdl",
	"models/hunter.mdl", "models/manhack.mdl", "models/zombie/classic.mdl",
	"models/zombie/fast.mdl", "models/zombie/zombie_soldier.mdl",
	"models/antlion.mdl", "models/headcrabclassic.mdl", "models/headcrab.mdl",
	"models/antlion_guard.mdl", "models/roller.mdl", "models/zombie/poison.mdl",
	"models/headcrabblack.mdl", "models/zombie/classic.mdl",
	"models/zombie/fast.mdl",
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

	for _, mdl in ipairs(NPC_MODELS) do
		util.PrecacheModel(mdl)
	end
end

--- Works out what type a NPC is
--- @param npc GNPC
--- @return string
function GM:GetNPCType(npc)
	local npcClass = npc:GetClass()
	-- There's some much more complex code in the base gamemode for handling
	-- other types of NPCs (eg citizen medics) but we don't have those as
	-- enemies so I'm going to worry about them (until it's a problem I guess)
	if npcClass == "npc_combine_s" then
		-- Try to figure out what kind of combine it actually was
		local model = npc:GetModel()
		local skin = npc:GetSkin()
		if model == "models/combine_soldier.mdl" and skin == 1 then
			npcClass = "ShotgunSoldier"
		elseif model == "models/combine_super_soldier.mdl" then
			npcClass = "CombineElite"
			-- The prison guards aren't actually in the NPC list
			-- elseif model == "models/combine_soldier_prisonguard.mdl" then
			-- 	if skin == 0 then
			-- 		npcClass = "CombinePrison"
			-- 	elseif skin == 1 then
			-- 		npcClass = "PrisonShotgunner"
			-- 	end
		end
	end
	return npcClass
end

function GM:OnNPCKilled(npc, attacker, inflictor)
	BaseClass.OnNPCKilled(self, npc, attacker, inflictor)

	-- I'm not bothering with the vehicle normalisation here because there are
	-- no vehicles in this gamemode

	if not IsValid(attacker) or not attacker:IsPlayer() then
		return
	elseif npc:Disposition(attacker) == D_LI then
		-- No reward for betrayals
		return
	end
	--- @cast attacker GPlayer

	-- Has the spawner helped us out?
	if isnumber(npc._oseReward) then
		attacker:AddMoney(npc._oseReward, "ose.money.reason.npc_killed", npc._oseName or "FUCK")
		return
	end

	-- Work out what the NPC is worth to the player
	--- @type string
	local npcClass = hook.Call("GetNPCType", self, npc)
	local reward = DEFAULT_NPC_REWARD
	--- @type NPCListDefinition
	local npcData = list.GetEntry("OSENPC", npcClass)

	local name
	if npcData then
		name = npcData.Name
		if npcData.Reward then
			reward = npcData.Reward
		end
	else
		name = "#" .. npcClass
	end
	attacker:AddMoney(reward, "ose.money.reason.npc_killed", name)
end
