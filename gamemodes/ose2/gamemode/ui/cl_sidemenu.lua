--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

include("sandbox/gamemode/spawnmenu/controlpanel.lua")
include("sandbox/gamemode/spawnmenu/toolpanel.lua")
include("cl_classquickmenu.lua")

-- HACK, the tool menus depend on this existing no matter what
CreateClientConVar("gmod_toolmode", "")

--- @class OSESideMenu : DPropertySheet
--- @field m_ToolPanels GPanel[]
local PANEL = {}

function PANEL:Init()
	self:AddSheet(
		"#ose.spawnmenu.tab.class",
		vgui.Create("OSEClassQuickMenu"),
		"icon16/user.png"
	)
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
