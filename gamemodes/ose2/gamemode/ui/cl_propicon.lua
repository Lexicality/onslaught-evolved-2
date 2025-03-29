--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
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
