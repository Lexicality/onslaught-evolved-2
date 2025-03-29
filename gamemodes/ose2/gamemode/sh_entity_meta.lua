--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

AddCSLuaFile()

--- @class GEntity
local entMeta = FindMetaTable("Entity")

function entMeta:SetCreator(ply)
	-- Nominally I could get away with this:
	-- self:SetDTEntity(31, ply)
	-- But that runs the risk of causing chaos when running on other people's
	-- servers with arbitrary whatever code interacting in strange ways

	-- NOTE: The wiki says it's dangerous to run this on Lua entities, so check
	-- `base_oseanim` for where I'm overriding this for all of OSE2's entities.
	-- If you include your own entities, dealing with this is your problem.
	self:SetNW2Entity("Creator", ply)
end

function entMeta:GetCreator()
	return self:GetNW2Entity("Creator", NULL)
end
