--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- @class OSEEntityIcon : OSEPropIcon
--- @field m_Class string
local PANEL = {}

--- @param class string
--- @param ent OSEEntityDefinition
function PANEL:Setup(class, ent)
	self.m_Class = class
	self:SetModel(ent.DisplayModel, ent.DisplaySkin)
	local price = hook.Run("LookupEntityPrice", LocalPlayer(), class, ent)
	local priceText = language.GetPhrase("ose.spawnmenu.price_tooltip")
	local name = language.GetPhrase(ent.Name)
	self:SetTooltip(string.format(priceText, name, price))
	self:InvalidateLayout(true)
end

function PANEL:DoClick()
	surface.PlaySound("ui/buttonclickrelease.wav")
	RunConsoleCommand("ose_spawnent", self.m_Class)
end

vgui.Register("OSEEntityIcon", PANEL, "OSEPropIcon")
