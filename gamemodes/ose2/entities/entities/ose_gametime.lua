--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- @class SENT_OSEGameTime : SENT_OSEBasePoint
local ENT = ENT --[[@as SENT_OSEGameTime]]
--- @type SENT_OSEBasePoint
local BaseClass
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
