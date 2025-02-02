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
include("sandbox/gamemode/spawnmenu/controlpanel.lua")
include("sandbox/gamemode/spawnmenu/toolpanel.lua")
-- HACK, the tool menus depend on this existing no matter what
CreateClientConVar("gmod_toolmode", "")

--- @class OSESideMenu : DPropertySheet
--- @field m_ToolPanels GPanel[]
local PANEL = {}

function PANEL:Init()
	self:SetupTools()
end

function PANEL:SetupTools()
	local tools = {}
	for i, table in ipairs(spawnmenu.GetTools()) do
		tools[i] = self:AddToolPanel(i, table)
	end
	self.m_ToolPanels = tools
end

local ACTUAL_TOOL_TAB = "AAAAAAA_Main"

--- @param id integer
--- @param toolTable ToolTabDefinition
--- @return GPanel?
function PANEL:AddToolPanel(id, toolTable)
	if toolTable.Name == ACTUAL_TOOL_TAB then
		-- We don't have a toolgun! No tools for you!
		return nil
	end
	local panel = vgui.Create("ToolPanel")
	panel["LoadToolsFromTable"](panel, toolTable.Items)
	local sheet = self:AddSheet(toolTable.Label, panel, toolTable.Icon)
	-- For some unknowable reason, the ToolPanel can't activate its own panels
	-- and we have to do a comedy dance with the `spawnmenu` module where it
	-- does its own clicking for some mad reason
	panel["PropertySheet"] = self
	panel["PropertySheetTab"] = sheet.Tab
	return panel
end

--- Sandbox nonsense
--- @param id integer
--- @return GPanel?
function PANEL:GetToolPanel(id)
	return self.m_ToolPanels[id]
end

vgui.Register("OSESideMenu", PANEL, "DPropertySheet")
