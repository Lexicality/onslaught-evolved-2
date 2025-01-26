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
include("cl_propicon.lua")

--- @class OSEPropSheet : DTileLayout
local PANEL = {}

--- @param model string
--- @param prop OSEPropDefinition
function PANEL:AddProp(model, prop)
	local icon = vgui.Create("OSEPropIcon", self)
	--- @cast icon OSEPropIcon
	icon:Setup(model, prop)
	self:Add(icon)
end

vgui.Register("OSEPropSheet", PANEL, "DTileLayout")
