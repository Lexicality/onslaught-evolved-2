--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
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
