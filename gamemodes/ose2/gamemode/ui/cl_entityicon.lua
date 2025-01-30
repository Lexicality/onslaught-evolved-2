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

--- @class OSEEntityIcon : OSEPropIcon
--- @field m_Class string
local PANEL = {}

--- @param class string
--- @param ent OSEEntityDefinition
function PANEL:Setup(class, ent)
	self.m_Class = class
	self:SetModel(ent.DisplayModel, ent.DisplaySkin)
	-- TODO: calculate cost
	self:SetTooltip(ent.Name)
	self:InvalidateLayout(true)
end

function PANEL:DoClick()
	surface.PlaySound("ui/buttonclickrelease.wav")
	RunConsoleCommand("ose_spawnent", self.m_Class)
end

vgui.Register("OSEEntityIcon", PANEL, "OSEPropIcon")
