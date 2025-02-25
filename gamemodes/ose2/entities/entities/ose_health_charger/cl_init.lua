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
