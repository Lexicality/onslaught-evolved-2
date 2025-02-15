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

--- @class SENT_OSEGameRules : SENT_OSEBasePoint
local ENT = ENT --[[@as SENT_OSEGameRules]]
--- @type SENT_OSEBasePoint
local BaseClass
DEFINE_BASECLASS("base_osepoint");

--- @type boolean
ENT.m_BattlePhase = false

function ENT:Initialize()
	if #ents.FindByClass(self:GetClass()) > 1 then
		ErrorNoHalt("Two NPC managers! Map is corrupted!\n")
		self:Remove()
		return
	end
	self:SetupHooks()
end

function ENT:OnReloaded()
	self:SetupHooks()
end

function ENT:SetupHooks()
	hook.Add("BattlePhaseStarted", self, self._OnBattlePhase)
	hook.Add("PrepPhaseStarted", self, self._OnPrepPhase)
	hook.Add("BuildPhaseStarted", self, self._OnBuildPhase)
	hook.Add("RoundWon", self, function(self)
		self:TriggerOutput("OnWin", self)
	end)
	hook.Add("RoundLost", self, function(self)
		self:TriggerOutput("OnLose", self)
	end)
end

function ENT:_OnBattlePhase(roundNum)
	self.m_BattlePhase = true
	self:TriggerOutput("OnBattle", self, tostring(roundNum))
end

function ENT:_OnPrepPhase(roundNum)
	self:TriggerOutput("OnPrep", self, tostring(roundNum))
end

function ENT:_OnBuildPhase(roundNum)
	self.m_BattlePhase = false
	self:TriggerOutput("OnBuild", self, tostring(roundNum))
end

function ENT:AcceptInput(name, activator, caller, value)
	if BaseClass.AddOutputFromAcceptInput(self, name, value) then
		return true
	end

	return false
end

function ENT:KeyValue(key, value)
	BaseClass.KeyValue(self, key, value)

	if key == "credits" then
		SetGlobal2String("MapCredits", value)
	end
end
