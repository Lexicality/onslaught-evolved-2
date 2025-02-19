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


--- @class OSEAmmoDefinition2 : OSEAmmoDefinition
--- @field Class string

--- @class OSEAmmoMenu : DFrame
--- @field m_AmmoCrate SENT_OSEAmmoCrate
--- @field SetAmmoCrate fun(self, GEntity)
local PANEL = {}

AccessorFunc(PANEL, "m_AmmoCrate", "AmmoCrate")

function PANEL:Init()
	self:SetDeleteOnClose(true)
	self:SetBackgroundBlur(true)
	self:ShowCloseButton(true)
	self:SetScreenLock(true)
	self:SetTitle("#ose_ammo_crate")
	self:SetIcon("icon16/cart.png")
	self:SetSizable(true)

	hook.Add("OnPauseMenuShow", self, self._onEscape)

	--- @type {[string]: OSEAmmoDefinition2}
	local allAmmo = list.Get("OSEAmmo")
	--- @type OSEAmmoDefinition2[]
	local selectableAmmo = {}
	local GM = gmod.GetGamemode()
	local lpl = LocalPlayer()
	for class, data in pairs(allAmmo) do
		if hook.Call("PlayerCanBuyAmmo", GM, lpl, class, data) then
			data.Class = class
			selectableAmmo[#selectableAmmo + 1] = data
		end
	end
	table.SortByMember(selectableAmmo, "Name")
	for _, data in ipairs(selectableAmmo) do
		local item = self:Add("OSEAmmoMenuItem")
		--- @cast item OSEAmmoMenuItem
		item:SetupAmmo(data)
		item:Dock(TOP)
		item:DockPadding(5, 5, 5, 5)
		item:DockMargin(0, 0, 0, 10)
	end
	-- Just picked random numbers here
	self:SetSize(300, 600)
	self:InvalidateChildren(true)
	self:Center()
	self:MakePopup()
end

function PANEL:PerformLayout()
	self:SizeToChildren(false, true)
	DFrame["PerformLayout"](self)
end

function PANEL:Think()
	local crate = self.m_AmmoCrate
	if not (IsValid(crate) and crate:CanPlayerUseMe(LocalPlayer())) then
		self:Close()
	end
end

function PANEL:OnClose()
	net.Start("OSE Ammo Menu Close")
	net.SendToServer()
end

-- When the user hits escape, close us instead of showing the pause menu
function PANEL:_onEscape()
	self:Close()
	return false
end

vgui.Register("OSEAmmoMenu", PANEL, "DFrame")

net.Receive("OSE Ammo Menu Open", function()
	local crate = net.ReadEntity()
	if IsValid(g_AmmoMenu) then
		g_AmmoMenu:Remove()
	end
	local menu = vgui.Create("OSEAmmoMenu") --[[@as OSEAmmoMenu]]
	g_AmmoMenu = menu
	if not IsValid(menu) then
		error("Failed to create ammo menu!!")
	end
	menu:SetAmmoCrate(crate)
end)

net.Receive("OSE Ammo Menu Close", function()
	if IsValid(g_AmmoMenu) then
		g_AmmoMenu:Remove()
	end
end)

--- @class OSEAmmoMenuItem : DPanel
--- @diagnostic disable-next-line: redefined-local
local PANEL = {}

local ICON_SIZE = 64
local MARGIN = 5

--- @param ammoData OSEAmmoDefinition2
function PANEL:SetupAmmo(ammoData)
	local imageHolder = self:Add("DPanel") --[[@as DPanel]]
	local image = imageHolder:Add("ModelImage")
	image:SetMouseInputEnabled(false)
	image:SetKeyboardInputEnabled(false)
	image:SetSize(ICON_SIZE, ICON_SIZE)
	image:SetModel(ammoData.DisplayModel, 0, "000000000")
	imageHolder:SetPaintBackground(false)
	imageHolder:Dock(LEFT)
	imageHolder:DockMargin(0, 0, 10, 0)

	local heading = self:Add("DLabel") --[[@as DLabel]]
	heading:SetFont("DermaHeading")
	heading:SetText(ammoData.Name)
	heading:SetDark(true)
	heading:Dock(TOP)

	local quantity = self:Add("DLabel") --[[@as DLabel]]
	quantity:SetText(
		string.format(
			language.GetPhrase("ose.ammomenu.quantity"),
			ammoData.Quantity
		)
	)
	quantity:SetDark(true)
	quantity:Dock(TOP)

	local price = self:Add("DLabel") --[[@as DLabel]]
	price:SetText(
		string.format(
			language.GetPhrase("ose.ammomenu.price"),
			hook.Run("LookupAmmoPrice", LocalPlayer(), ammoData.Class, ammoData)
		)
	)
	price:SetDark(true)
	price:Dock(TOP)

	local buttonHolder = self:Add("DPanel") --[[@as DPanel]]
	local buy1 = buttonHolder:Add("DButton") --[[@as DButton]]
	buy1:SetText("#ose.ammomenu.buy_1")
	buy1:Dock(LEFT)
	local buy3 = buttonHolder:Add("DButton") --[[@as DButton]]
	buy3:SetText("#ose.ammomenu.buy_3")
	buy3:Dock(RIGHT)
	buttonHolder:SetPaintBackground(false)
	buttonHolder:Dock(TOP)
	-- gragh
	---@diagnostic disable-next-line: inject-field
	function buttonHolder:PerformLayout()
		local width = (self:GetWide() - MARGIN) / 2
		buy1:SetWide(width)
		buy3:SetWide(width)
	end

	function buy1:DoClick()
		RunConsoleCommand("ose_buy_ammo", ammoData.Class, 1)
	end

	function buy3:DoClick()
		RunConsoleCommand("ose_buy_ammo", ammoData.Class, 3)
	end
end

function PANEL:PerformLayout()
	self:SizeToChildren(false, true)
end

vgui.Register("OSEAmmoMenuItem", PANEL, "DPanel")
