--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

include("shared.lua")

--- @class SENT_OSEHealthCharger : SENT_OSEProp
--- @field m_CAngle number # Current yaw
--- @field m_COffset number # Current inout offset
local ENT = ENT --[[@as SENT_OSEHealthCharger]]
--- @type SENT_OSEProp
local BaseClass
DEFINE_BASECLASS("ose_prop")

function ENT:Initialize()
	self:SetModel(self._model)
	self.m_CAngle = 0
	self.m_COffset = 0
	BaseClass.Initialize(self)
end

local BONE = 2
local ROT_SPEED = 50
local IO_SPEED = 5

function ENT:Think()
	if not self:IsActive() then
		return
	end
	local ft = FrameTime()
	self.m_CAngle = (self.m_CAngle + ft * ROT_SPEED) % 360
	self.m_COffset = self.m_COffset + ft * IO_SPEED
	self:ManipulateBoneAngles(BONE, Angle(0, self.m_CAngle, 0))
	-- Between 0 and -1
	local amt = (math.cos(self.m_COffset) / 4) - 0.25
	self:ManipulateBonePosition(BONE, Vector(0, 0, amt))
end
