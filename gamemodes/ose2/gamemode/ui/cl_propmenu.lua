--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]
include("cl_propsheet.lua")

--- @class OSEPropDefinition2 : OSEPropDefinition
--- @field Model string

--- @class OSEEntityDefinition2 : OSEEntityDefinition
--- @field Class string

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

	--- @type OSEEntityDefinition2[]
	local entities = {}
	for model, ent in pairs(list.Get("OSEEntities")) do
		ent["Class"] = model
		entities[#entities + 1] = ent
	end
	table.SortByMember(entities, "Name", true)

	for _, ent in ipairs(entities) do
		local class = ent.Class
		-- TODO: Should entities be in the "all" tab? Going with "no" to start off with
		-- allEnts:AddEnt(class, ent)
		local groupPanel = groups[ent.ModelGroup]
		if groupPanel then
			groupPanel:AddEntity(class, ent)
		else
			ErrorNoHalt("Entity ", class, " has invalid group '", ent.ModelGroup, "' set!")
			-- Gotta put it somewhere I guess
			allProps:AddEntity(class, ent)
		end
	end
end

vgui.Register("OSEPropMenu", PANEL, "DPropertySheet")
