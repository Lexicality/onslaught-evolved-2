--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- @class SENT_OSEBasePoint : SENT
local ENT = ENT --[[@as SENT_OSEBasePoint]]
--- @type SENT
local BaseClass
DEFINE_BASECLASS("base_point")

function ENT:AcceptInput(name, activator, caller, value)
	if BaseClass.AddOutputFromAcceptInput(self, name, value) then
		return true
	end

	return false
end

function ENT:KeyValue(key, value)
	BaseClass.AddOutputFromKeyValue(self, key, value)
end
