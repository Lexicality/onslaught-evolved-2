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
include("cl_propsheet.lua")

--- @class OSEPropMenu : DPropertySheet
local PANEL = {}

function PANEL:Init()
	local allProps = vgui.Create("OSEPropSheet", self)
	--- @cast allProps OSEPropSheet
	self:AddSheet("#ose.group.all", allProps, "icon16/bricks.png")
	--- @type OSEPropSheet[]
	local groups = {}
	for i, group in pairs(list.Get("OSEGroups")) do
		--- @cast group OSEPropGroupDefinition
		local groupPanel = vgui.Create("OSEPropSheet", self)
		--- @cast groupPanel OSEPropSheet
		self:AddSheet(group.Name, groupPanel, group.Icon, nil, nil, group.Tooltip)
		groups[i] = groupPanel
	end
	for model, prop in pairs(list.Get("OSEProps")) do
		--- @cast model string
		--- @cast prop OSEPropDefinition
		allProps:AddProp(model, prop)
		local groupPanel = groups[prop.ModelGroup]
		if groupPanel then
			groupPanel:AddProp(model, prop)
		end
	end
end

vgui.Register("OSEPropMenu", PANEL, "DPropertySheet")
