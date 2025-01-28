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

--- @class OSEPropDefinition2 : OSEPropDefinition
--- @field Model string

--- @class OSEPropMenu : DPropertySheet
local PANEL = {}

function PANEL:Init()
	local allProps = vgui.Create("OSEPropSheet", self)
	--- @cast allProps OSEPropSheet
	self:AddSheet("#ose.group.all", allProps, "icon16/bricks.png")
	--- @type OSEPropSheet[]
	local groups = {}
	for i, group in ipairs(list.Get("OSEGroups")) do
		--- @cast group OSEPropGroupDefinition
		local groupPanel = vgui.Create("OSEPropSheet", self)
		--- @cast groupPanel OSEPropSheet
		self:AddSheet(group.Name, groupPanel, group.Icon, nil, nil, group.Tooltip)
		groups[i] = groupPanel
	end
	-- Provide consistent sorting for props
	--- @type OSEPropDefinition2[]
	local props = {}
	for model, prop in pairs(list.Get("OSEProps")) do
		prop["Model"] = model
		props[#props + 1] = prop
	end
	table.SortByMember(props, "Name", true)

	for _, prop in ipairs(props) do
		local model = prop.Model
		allProps:AddProp(model, prop)
		local groupPanel = groups[prop.ModelGroup]
		if groupPanel then
			groupPanel:AddProp(model, prop)
		end
	end
end

vgui.Register("OSEPropMenu", PANEL, "DPropertySheet")
