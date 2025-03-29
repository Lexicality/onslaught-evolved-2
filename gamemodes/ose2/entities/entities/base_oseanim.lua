--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

AddCSLuaFile()

--- @class SENT_OSEBaseAnim : SENT
local ENT = ENT --[[@as SENT_OSEBaseAnim]]
--- @type SENT
local BaseClass
DEFINE_BASECLASS("base_anim")

function ENT:SetupDataTables()
	-- The wiki says it's not safe to use the NW2 vars on Lua entities so we're
	-- gonna overwrite the Get/SetCreator methods in sh_entity_meta.lua here
	-- with the rather more efficient DTVar system
	self:NetworkVar("Entity", 0, "Creator")
end

function ENT:AcceptInput(name, activator, caller, value)
	if BaseClass.AddOutputFromAcceptInput(self, name, value) then
		return true
	end

	return false
end

function ENT:KeyValue(key, value)
	if self.SetNetworkKeyValue and self:SetNetworkKeyValue(key, value) then
		return
	end
	BaseClass.AddOutputFromKeyValue(self, key, value)
end
