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

-- NOTE: Most of the code in here has been adapted from the sandbox code in gmod version 2024.12.09

local spawnmenuBorderCvar = CreateConVar(
	"spawnmenu_border",
	"0.1",
	FCVAR_ARCHIVE,
	"Amount of empty space around the Sandbox spawn menu."
)

include("cl_propmenu.lua")
include("cl_sidemenu.lua")

--- @class OSESpawnMenu : VEditablePanel
--- @field m_Divider DHorizontalDivider
--- @field m_PropMenu OSEPropMenu
--- @field m_SideMenu OSESideMenu
--- @field m_HangOpen boolean Keeps the menu open if the user is editing an input
--- @field m_FocusedPanel GPanel | nil What the user's currently editing (if they are!)
local PANEL = {}

function PANEL:Init()
	-- Fullscreen time
	self:Dock(FILL)

	local scrw = ScrW()
	local divider = vgui.Create("DHorizontalDivider", self)
	--- @cast divider DHorizontalDivider
	self.m_Divider = divider
	divider:Dock(FILL)
	divider:SetDividerWidth(6)
	-- Make the prop side as big as possible
	divider:SetLeftWidth(scrw)
	-- Then knock it back down with the side menu
	if scrw >= 1024 then
		divider:SetRightMin(460)
	else
		divider:SetRightMin(300)
	end
	-- HACK: don't allow the user to resize the divider
	divider["StartGrab"] = function() end
	divider["m_DragBar"]:SetCursor("none")

	-- Create and attach our panels
	local sideMenu = vgui.Create("OSESideMenu", divider)
	divider:SetRight(sideMenu)
	local propMenu = vgui.Create("OSEPropMenu", divider)
	divider:SetLeft(propMenu)
	-- TODO: Do we actually need to save these? We're not doing the same
	-- shenanigans as sandbox does
	--- @cast propMenu OSEPropMenu
	--- @cast sideMenu OSESideMenu
	self.m_SideMenu = sideMenu
	self.m_PropMenu = propMenu

	self.m_HangOpen = false

	-- gotta go click
	self:SetMouseInputEnabled(true)

	hook.Add("OnTextEntryGetFocus", self, self._onTextFocus)
	hook.Add("OnTextEntryLoseFocus", self, self._onTextUnfocus)
	hook.Add("OnPrepPhaseStarted", self, self.ForceClose)
	hook.Add("OnBattlePhaseStarted", self, self.ForceClose)
end

--- @param panel GPanel
function PANEL:_onTextFocus(panel)
	if not IsValid(panel) or not panel:HasParent(self) then
		return
	end

	self.m_HangOpen = true
	self.m_FocusedPanel = panel
	self:SetKeyboardInputEnabled(true)
end

--- @param panel GPanel
function PANEL:_onTextUnfocus(panel)
	if IsValid(panel) and panel ~= self.m_FocusedPanel then
		return
	end

	self:SetKeyboardInputEnabled(false)
end

--- Compatability for sandbox stuff
--- @param shouldHang boolean
function PANEL:HangOpen(shouldHang)
	self.m_HangOpen = shouldHang
end

--- Compatability for sandbox stuff
--- @return boolean
function PANEL:HangingOpen()
	return self.m_HangOpen
end

local MIN_BORDER, MAX_BORDER = 25, 256

function PANEL:PerformLayout()
	self:DockPadding(0, 0, 0, 0)

	local scrw = ScrW()
	local scrh = ScrH()

	local marginX, marginY = 0, 0
	if scrw > 1024 and scrh > 768 then
		local border = spawnmenuBorderCvar:GetFloat()
		marginX = math.Clamp((scrw - 1024) * border, MIN_BORDER, MAX_BORDER)
		marginY = math.Clamp((scrh - 768) * border, MIN_BORDER, MAX_BORDER)
	end

	local divider = self.m_Divider
	divider:DockMargin(marginX, marginY, marginX, marginY)
	divider:SetLeftMin(divider:GetWide() / 3)
end

function PANEL:OnSizeChanged()
	-- TODO: I don't think this is necessary because we don't let the user
	-- resize the divider, but I'm not 100% sure about that
	local divider = self.m_Divider
	local oldWidth = divider:GetWide()
	local leftWdith = divider:GetLeftWidth()
	self:InvalidateLayout(true)
	local newWidth = divider:GetWide()

	if oldWidth > leftWdith and oldWidth < newWidth then
		local ratio = leftWdith / oldWidth
		divider:SetLeftWidth(ratio * newWidth)
	end
end

-- Allow the user to close the menu by clicking on the margin around the menu
-- (why? idk, ask Garry)
function PANEL:OnMousePressed()
	self:Close()
end

function PANEL:Open()
	-- Paranoia: This shouldn't be necessary, but weird things can happen I suppose
	self.m_HangOpen = false

	if self:IsVisible() then
		return
	end

	RestoreCursorPosition()

	self:MakePopup()
	self:SetVisible(true)
	-- TODO: I'm pretty sure we do not need these because MakePopup should do it for us
	-- self:SetMouseInputEnabled( true )
	-- self:SetAlpha(255)

	-- MakePopup makes us automatically steal keyboard focus but we want the
	-- player to be able to move around with the spawn menu open, so return
	-- focus to the game
	self:SetKeyboardInputEnabled(false)
end

--- @param force? boolean
function PANEL:Close(force)
	if self.m_HangOpen and not force then
		self.m_HangOpen = false
		return
	end

	if self:IsVisible() then
		RememberCursorPosition()
	end

	-- There is no PANEL:UnPopup(), though it feels like there should be
	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
	self:SetVisible(false)
end

function PANEL:ForceClose()
	self:Close(true)
end

-- Note to self: This derives from `EditablePanel` rather than `Panel` because
-- it's the root element in the spawn menu hierarchy and there needs to be an
-- `EditablePanel` in there somewhere. Normally this comes from a `DFrame` but
-- we don't have one of those here for obvious reasons
vgui.Register("OSESpawnMenu", PANEL, "EditablePanel")

function GM:SetupSpawnMenu()
	if IsValid(g_SpawnMenu) then
		g_SpawnMenu:Remove()
		g_SpawnMenu = nil
	end

	-- TODO: Tool chaos goes here

	g_SpawnMenu = vgui.Create("OSESpawnMenu")
	if IsValid(g_SpawnMenu) then
		g_SpawnMenu:SetVisible(false)
		hook.Call("SpawnMenuCreated", self, g_SpawnMenu)
	end
end

concommand.Add("spawnmenu_reload", function() GAMEMODE:SetupSpawnMenu() end)

function GM:OnSpawnMenuOpen()
	-- Let the gamemode decide whether we should open or not..
	if not hook.Call("SpawnMenuOpen", self) then
		return
	end

	if IsValid(g_SpawnMenu) then
		g_SpawnMenu:Open()
	end

	hook.Call("SpawnMenuOpened", self)
end

function GM:OnSpawnMenuClose()
	if IsValid(g_SpawnMenu) then
		g_SpawnMenu:Close()
	end
	hook.Call("SpawnMenuClosed", self)
end

function GM:SpawnMenuOpen()
	return self.m_RoundPhase == ROUND_PHASE_BUILD
end
