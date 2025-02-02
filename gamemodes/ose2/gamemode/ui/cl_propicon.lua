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
include("sandbox/gamemode/gui/iconeditor.lua")

--- @class OSEPropIcon : VSpawnIcon
--- @field m_Model string
local PANEL = {}

--- @param model string
--- @param prop OSEPropDefinition
function PANEL:Setup(model, prop)
	self.m_Model = model
	self:SetModel(model)
	local price = hook.Run("LookupPropPrice", LocalPlayer(), model)
	local priceText = language.GetPhrase("ose.spawnmenu.price_tooltip")
	local name = language.GetPhrase(prop.Name)
	self:SetTooltip(string.format(priceText, name, price))
	self:InvalidateLayout(true)
end

function PANEL:DoClick()
	surface.PlaySound("ui/buttonclickrelease.wav")
	RunConsoleCommand("ose_spawn", self.m_Model)
end

function PANEL:OpenMenu()
	local menu = DermaMenu()
	--- @cast menu DMenu
	menu:AddOption("#spawnmenu.menu.rerender", function()
		if (IsValid(self)) then self:RebuildSpawnIcon() end
	end) --[[@as DMenuOption]]:SetIcon("icon16/picture.png")

	menu:AddOption("#spawnmenu.menu.edit_icon", function()
		if (! IsValid(self)) then return end

		local editor = vgui.Create("IconEditor")
		--- @cast editor VIconEditor
		editor:SetIcon(self)
		editor:Refresh()
		editor:MakePopup()
		editor:Center()
	end) --[[@as DMenuOption]]:SetIcon("icon16/pencil.png")

	menu:Open()
end

vgui.Register("OSEPropIcon", PANEL, "SpawnIcon")
