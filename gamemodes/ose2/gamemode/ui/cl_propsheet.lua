--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]
include("cl_entityicon.lua")
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

--- @param class string
--- @param ent OSEEntityDefinition
function PANEL:AddEntity(class, ent)
	local icon = vgui.Create("OSEEntityIcon", self)
	--- @cast icon OSEEntityIcon
	icon:Setup(class, ent)
	self:Add(icon)
end

vgui.Register("OSEPropSheet", PANEL, "DTileLayout")
