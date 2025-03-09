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
