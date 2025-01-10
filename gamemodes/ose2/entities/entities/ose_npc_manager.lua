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
local GENERATED_NPCS = {
	npc_fastzombie_torso = true,
	npc_headcrab = true,
	npc_headcrab_black = true,
	npc_headcrab_fast = true,
	npc_manhack = true,
	npc_zombie_torso = true,
}

--- @type boolean
ENT.m_DontSetRelationships = false
--- @type boolean
ENT.m_BattlePhase = false

function ENT:Initialize()
	hook.Add("BattlePhaseStarted", self, self._OnBattlePhase)
	hook.Add("BuildPhaseStarted", self, self._OnBuildPhase)
end

function ENT:_OnBattlePhase(round_number)
	self.m_BattlePhase = true
	self:TriggerOutput("OnSpawnEnabled", self, self)
end

function ENT:_OnBuildPhase(round_number)
	self.m_BattlePhase = false
	for ent in ents.Iterator() do
		--- @cast ent GEntity
		if ent["_oseNPC"] or GENERATED_NPCS[ent:GetClass()] then
			-- TODO: Fancier death
			ent:Remove()
		end
	end
end

---@param npc GNPC
function ENT:_HandleNPC(npc)
	npc["_oseNPC"] = true

	-- Would it be better to use custom collisions? Probably not.
	npc:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)

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
			self:_HandleNPC(activator)
		elseif value ~= nil then
			for _, ent in ipairs(ents.FindByName(value)) do
				if ent:IsNPC() then
					--- @cast ent GNPC
					self:_HandleNPC(ent)
				end
			end
		end
		return true
	elseif name == "PointTemplateSpawned" then
		-- TODO
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
