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

DEFINE_BASECLASS("base_osepoint");

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
	hook.Add("RoundWon", self, function(self)
		self:TriggerOutput("OnWin", self, self)
	end)
	hook.Add("RoundLost", self, function(self)
		self:TriggerOutput("OnLose", self, self)
	end)
end

function ENT:_OnBattlePhase(roundNum)
	self.m_BattlePhase = true
	self:TriggerOutput("OnBattle", self, self, tostring(roundNum))
end

function ENT:_OnBuildPhase(roundNum)
	self.m_BattlePhase = false
	self:TriggerOutput("OnBuild", self, self, tostring(roundNum))
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

	return false
end

---@param key string
---@param value string
function ENT:KeyValue(key, value)
	BaseClass.KeyValue(self, key, value)

	if key == "credits" then
		SetGlobal2String("MapCredits", value)
	end
end
