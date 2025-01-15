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

DEFINE_BASECLASS("base_osepoint");

function ENT:Initialize()
	self:SetupHooks()
end

function ENT:OnReloaded()
	self:SetupHooks()
end

function ENT:SetupHooks()
	hook.Add("BuildStarted", self, self._OnRoundStart)
	hook.Add("BattleStarted", self, self._OnRoundStart)
	hook.Add("RoundSecond", self, self._OnRoundSecond)
end

---@param roundLength number
function ENT:_OnRoundStart(roundLength)
	self:TriggerOutput("OnRoundStart", self, tostring(math.floor(roundLength)))
end

---@param timeLeft number
function ENT:_OnRoundSecond(timeLeft)
	self:TriggerOutput("OnroundSecond", self, tostring(math.floor(timeLeft)))
end
