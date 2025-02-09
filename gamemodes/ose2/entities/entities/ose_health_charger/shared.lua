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

--- @class SENT_OSEHealthCharger : SENT_OSEProp
--- @field SetActive fun(self, active: boolean)
--- @field GetActive fun(self): boolean
local ENT = ENT --[[@as SENT_OSEHealthCharger]]
--- @type SENT_OSEProp
local BaseClass
DEFINE_BASECLASS("ose_prop")

-- Precaching jiggerypokery
ENT._model = Model("models/props_combine/health_charger001.mdl")
ENT._denySound = Sound("WallHealth.Deny")
ENT._startSound = Sound("WallHealth.Start")
ENT._chargeSound = Sound("WallHealth.LoopingContinueCharge")

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Bool", 0, "Active")
end

--- @return boolean
function ENT:IsActive()
	return self:GetActive()
end
