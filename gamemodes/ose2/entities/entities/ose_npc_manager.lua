--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

local npcCvar = GetConVar("ose_max_npcs")
local hunterCvar = GetConVar("ose_max_hunters")
local hunterScaleCvar = GetConVar("ose_hunters_scale")
local manhackCvar = GetConVar("ose_max_manhacks")
local zombieCvar = GetConVar("ose_zombie_max_npcs")

--- @class SENT_OSENPCManager : SENT_OSEBasePoint
local ENT = ENT --[[@as SENT_OSENPCManager]]
--- @type SENT_OSEBasePoint
local BaseClass
DEFINE_BASECLASS("base_osepoint");

-- This list is duplicated for performance reasons, but also because I love
-- causing problems for myself in the future
local NPC_BUDDIES = {
	"npc_antlion", "npc_antlionguard", "npc_combine_s", "npc_fastzombie",
	"npc_fastzombie_torso", "npc_headcrab", "npc_headcrab_black",
	"npc_headcrab_fast", "npc_hunter", "npc_manhack", "npc_metropolice",
	"npc_poisonzombie", "npc_rollermine", "npc_zombie", "npc_zombie_torso",
	"npc_zombine",
}

--- @type boolean
ENT.m_ZombieMode = false
--- @type integer
ENT.m_NPCCount = 0
--- @type boolean
ENT.m_NPCsEnabled = false
--- @type integer
ENT.m_NPCLimit = 28
--- @type integer
ENT.m_HunterLimit = 2
--- @type boolean
ENT.m_DontSetRelationships = false
--- @type boolean
ENT.m_BattlePhase = false

function ENT:Initialize()
	if #ents.FindByClass(self:GetClass()) > 1 then
		ErrorNoHalt("Two NPC managers! Map is corrupted!\n")
		self:Remove()
		return
	end

	self:SetupHooks()
	self:TriggerAllLimitChanges()
end

function ENT:OnReloaded()
	self:SetupHooks()
	self:TriggerAllLimitChanges()
end

function ENT:SetupHooks()
	hook.Add("BattlePhaseStarted", self, self._OnBattlePhase)
	hook.Add("BuildPhaseStarted", self, self._OnBuildPhase)
	hook.Add("OnNPCKilled", self, self._OnNPCKilled)
	hook.Add("PlayerInitialSpawn", self, self.CalculateHunterLimit)
	hook.Add("PlayerDisconnected", self, self.CalculateHunterLimit)

	cvars.AddChangeCallback(npcCvar:GetName(), function(name, old, new)
		if IsValid(self) then
			self:CalculateHunterLimit()
		end
	end, "ose_npc_manager")
	cvars.AddChangeCallback(manhackCvar:GetName(), function(name, old, new)
		if IsValid(self) then
			self:_OnManhackCvarChanged(new)
		end
	end, "ose_npc_manager")
	cvars.AddChangeCallback(hunterCvar:GetName(), function(name, old, new)
		if IsValid(self) then
			self:CalculateHunterLimit()
		end
	end, "ose_npc_manager")
end

function ENT:TriggerAllLimitChanges()
	self:CalculateHunterLimit(true)
	self:TriggerOutput("OnNPCLimitChanged", self, tostring(self.m_NPCLimit))
	self:TriggerOutput("OnManhackLimitChanged", self, tostring(manhackCvar:GetInt()))
	self:TriggerOutput("OnHunterLimitChanged", self, tostring(self.m_HunterLimit))
end

function ENT:_OnBattlePhase(roundNum)
	self.m_BattlePhase = true
	self:TriggerAllLimitChanges()
end

function ENT:_OnBuildPhase(roundNum)
	self.m_BattlePhase = false
	self:TriggerOutput("OnNPCSpawnDisabled", self)
	self.m_NPCsEnabled = false
	local generatedNPCs = list.GetForEdit("OSEGenerated")
	for _, ent in ents.Iterator() do
		--- @cast ent GEntity
		if ent._oseNPC or generatedNPCs[ent:GetClass()] then
			-- (most) NPCs don't make death noises if they think they're dissolving
			ent:AddFlags(FL_DISSOLVING)
			-- It might be possible to make a lua effect for this but we can't
			-- use the env_entity_dissolver for this because you can't stop it
			-- very noisily assigning kills
			ent:Remove()
		end
	end
	self.m_NPCCount = 0
end

function ENT:_OnManhackCvarChanged(newValue)
	self:TriggerOutput("OnManhackLimitChanged", self, newValue)
end

---@param npc GNPC
function ENT:_OnNPCSpawned(npc)
	npc._oseNPC = true

	-- Would it be better to use custom collisions? Probably not.
	npc:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

	self.m_NPCCount = self.m_NPCCount + 1
	self:CheckNPCCount()

	if self.m_DontSetRelationships then
		return
	end

	local classname = npc:GetClass()

	-- Hate all players with maximum priority
	npc:AddRelationship("player D_HT 99")
	-- Hate props a decent amount
	if list.HasEntry("OSEMelee", classname) then
		npc:AddRelationship("ose_be_gnd D_HT 50")
	else
		npc:AddRelationship("ose_be_* D_HT 50")
	end
	-- Like all the other NPCs that'll be around
	for _, otherClass in ipairs(NPC_BUDDIES) do
		if otherClass ~= classname then
			npc:AddRelationship(otherClass .. " D_LI 1")
		end
	end
end

---@param npc GNPC
---@param attacker GEntity
---@param inflictor GEntity
function ENT:_OnNPCKilled(npc, attacker, inflictor)
	if npc._oseNPC then
		self.m_NPCCount = self.m_NPCCount - 1
		self:CheckNPCCount()
	end
end

function ENT:AcceptInput(name, activator, caller, value)
	if BaseClass.AddOutputFromAcceptInput(self, name, value) then
		return true
	end

	name = string.lower(name)

	if name == "npcspawned" then
		if IsValid(activator) and activator:IsNPC() then
			--- @cast activator GNPC
			self:_OnNPCSpawned(activator)
		elseif value ~= nil then
			for _, ent in ipairs(ents.FindByName(value)) do
				if ent:IsNPC() then
					--- @cast ent GNPC
					self:_OnNPCSpawned(ent)
				end
			end
		end
		return true
	elseif name == "pointtemplatespawned" then
		ErrorNoHalt("TODO: PointTemplateSpawned!!\n")
		return false
	end
	return false
end

function ENT:KeyValue(key, value)
	BaseClass.KeyValue(self, key, value)

	key = string.lower(key)

	if key == "disablerelationships" then
		self.m_DontSetRelationships = tobool(value)
	elseif key == "zombiemode" then
		self.m_ZombieMode = tobool(value)
	end
end

function ENT:CheckNPCCount()
	if not self.m_BattlePhase then return end

	local maxNPCs = self.m_NPCLimit + self.m_HunterLimit
	if self.m_NPCsEnabled then
		if self.m_NPCCount > maxNPCs then
			self.m_NPCsEnabled = false
			self:TriggerOutput("OnNPCSpawnDisabled", self)
		end
	else
		if self.m_NPCCount < maxNPCs then
			self.m_NPCsEnabled = true
			self:TriggerOutput("OnNPCSpawnEnabled", self)
		end
	end
end

---comment
--- @param noEmit? boolean Prevents the output being triggered
function ENT:CalculateHunterLimit(noEmit)
	local newLimit = hunterCvar:GetInt()

	if hunterScaleCvar:GetBool() then
		newLimit = newLimit + math.floor(player.GetCount() / 4)
	end

	if newLimit ~= self.m_HunterLimit and not noEmit then
		self:TriggerOutput("OnHunterLimitChanged", self, tostring(self.m_HunterLimit))
	end
	self.m_HunterLimit = newLimit

	local newNPCLimit = npcCvar:GetInt() - newLimit
	if newNPCLimit ~= self.m_NPCLimit and not noEmit then
		self:TriggerOutput("OnNPCLimitChanged", self, tostring(self.m_NPCLimit))
	end
	self.m_NPCLimit = newNPCLimit
	self:CheckNPCCount()
end
