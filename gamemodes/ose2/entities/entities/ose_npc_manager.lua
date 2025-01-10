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

local npcCvar = GetConVar("ose_max_npcs")
local hunterCvar = GetConVar("ose_max_hunters")
local hunterScaleCvar = GetConVar("ose_hunters_scale")
local manhackCvar = GetConVar("ose_max_manhacks")

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

--- @type integer
ENT.m_NPCCount = 0
--- @type boolean
ENT.m_NPCsEnabled = false
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

	hook.Add("BattlePhaseStarted", self, self._OnBattlePhase)
	hook.Add("BuildPhaseStarted", self, self._OnBuildPhase)
	hook.Add("NPCKilled", self, self._OnNPCKilled)
	hook.Add("PlayerInitialSpawn", self, self.CalculateHunterLimit)
	hook.Add("PlayerDisconnected", self, self.CalculateHunterLimit)

	cvars.AddChangeCallback(npcCvar:GetName(), function(name, old, new)
		if IsValid(self) then
			self:_OnNPCCvarChanged(new)
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

function ENT:_OnBattlePhase(roundNum)
	self.m_BattlePhase = true
	self:TriggerOutput("OnNPCLimitChanged", self, self, tostring(npcCvar:GetInt()))
	self:TriggerOutput("OnManhackLimitChanged", self, self, tostring(manhackCvar:GetInt()))
	self:TriggerOutput("OnHunterLimitChanged", self, self, tostring(self.m_HunterLimit))
	self:CheckNPCCount()
end

function ENT:_OnBuildPhase(roundNum)
	self.m_BattlePhase = false
	self.m_NPCsEnabled = false
	local generatedNPCs = list.GetForEdit("OSEGenerated")
	for ent in ents.Iterator() do
		--- @cast ent GEntity
		if ent["_oseNPC"] or generatedNPCs[ent:GetClass()] then
			-- TODO: Fancier death
			ent:Remove()
		end
	end
	self.m_NPCCount = 0
end

function ENT:_OnNPCCvarChanged(newValue)
	self:TriggerOutput("OnNPCLimitChanged", self, self, newValue)
	self:CheckNPCCount()
end

function ENT:_OnManhackCvarChanged(newValue)
	self:TriggerOutput("OnManhackLimitChanged", self, self, newValue)
end

---@param npc GNPC
function ENT:_OnNPCSpawned(npc)
	npc["_oseNPC"] = true

	-- Would it be better to use custom collisions? Probably not.
	npc:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

	self.m_NPCCount = self.m_NPCCount + 1
	self:CheckNPCCount()

	-- TODO: Other things go here

	if self.m_DontSetRelationships then
		return
	end

	local classname = npc:GetClass()

	-- Hate all players with maximum priority
	npc:AddRelationship("player DT_HT 99")
	-- Hate props a decent amount
	if list.HasEntry("OSEMelee", classname) then
		npc:AddRelationship("ose_be_gnd DT_HT 50")
	else
		npc:AddRelationship("ose_be_* DT_HT 50")
	end
	-- Like all the other NPCs that'll be around
	for _, otherClass in ipairs(NPC_BUDDIES) do
		if otherClass ~= classname then
			npc:AddRelationship(otherClass .. " DT_LI 1")
		end
	end
end

---@param npc GNPC
---@param attacker GEntity
---@param inflictor GEntity
function ENT:_OnNPCKilled(npc, attacker, inflictor)
	if npc["_oseNPC"] then
		self.m_NPCCount = self.m_NPCCount - 1
		self:CheckNPCCount()
	end
end

---@param name string
---@param activator GEntity
---@param caller GEntity
---@param value string | nil
---@return boolean
function ENT:AcceptInput(name, activator, caller, value)
	if BaseClass.AddOutputFromAcceptInput(self, name, value) then
		return true
	end

	if name == "NPCSpawned" then
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
	elseif name == "PointTemplateSpawned" then
		ErrorNoHalt("TODO: PointTemplateSpawned!!\n")
		return false
	end
	return false
end

---@param key string
---@param value string
function ENT:KeyValue(key, value)
	BaseClass.KeyValue(self, key, value)

	if key == "disablerelationships" then
		self.m_DontSetRelationships = tobool(value)
	end
end

function ENT:CheckNPCCount()
	local maxNPCs = npcCvar:GetInt()
	if self.m_NPCsEnabled then
		if self.m_NPCCount > maxNPCs then
			self.m_NPCsEnabled = false
			self:TriggerOutput("OnSpawnDisabled", self, self)
		end
	else
		if self.m_NPCCount < maxNPCs then
			self.m_NPCsEnabled = true
			self:TriggerOutput("OnSpawnEnabled", self, self)
		end
	end
end

function ENT:CalculateHunterLimit()
	local newLimit = hunterCvar:GetInt()

	if hunterScaleCvar:GetBool() then
		newLimit = newLimit + math.floor(player.GetCount() / 4)
	end

	if newLimit ~= self.m_HunterLimit then
		self.m_HunterLimit = newLimit
		self:TriggerOutput("OnHunterLimitChanged", self, self, tostring(self.m_HunterLimit))
	end
end
