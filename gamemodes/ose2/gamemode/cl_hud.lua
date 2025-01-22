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

---@type SGM
local BaseClass
DEFINE_BASECLASS("gamemode_base")


--- @type SFontData
local oseHudTextData = {
	font = "Verdana",
	size = 42,
	weight = 900,
}
surface.CreateFont("OSEHudText", oseHudTextData)
--- @type SFontData
local oseHudTimerData = {
	font = "HalfLife2",
	-- font = "Verdana",
	size = 52,
	weight = 0,
	additive = true
}
surface.CreateFont("OSEHudTimer", oseHudTimerData)
--- @type SFontData
local oseHudTimerColonData = {
	font = "Verdana",
	size = 64,
	weight = 0,
	additive = true
}
surface.CreateFont("OSEHudTimerColon", oseHudTimerColonData)

local HUD_BACKGROUND_COLOUR = Color(0, 0, 0, 76)
local HUD_TEXT_COLOUR = Color(255, 235, 20, 255)
local HUD_TEXT_BRIGHT_COLOUR = Color(255, 220, 0, 255)
local HUD_DAMAGE_BACKGROUND_COLOUR = Color(180, 0, 0, 200)
local HUD_DAMAGE_TEXT_COLOUR = Color(180, 0, 0, 230)
local HUD_TEXT_FONT = "OSEHudText"
local HUD_TIMER_FONT = "OSEHudTimer"
local HUD_TIMER_COLON_FONT = "OSEHudTimerColon"
-- HudDefault
-- HudNumbers
-- HudNumbersGlow
-- HudNumbersSmall


function GM:SetupHUD()
	surface.SetFont(HUD_TEXT_FONT)

	self.hud_BuildModePhrase = language.GetPhrase("ose.mode.build")
	local w, h = surface.GetTextSize(self.hud_BuildModePhrase)
	self.hud_BuildModePhraseWidth = w
	self.hud_BuildModePhraseHeight = h

	self.hud_PrepModePhrase = language.GetPhrase("ose.mode.prep")
	w, h = surface.GetTextSize(self.hud_PrepModePhrase)
	self.hud_PrepModePhraseWidth = w
	self.hud_PrepModePhraseHeight = h

	self.hud_BattleModePhrase = language.GetPhrase("ose.mode.battle")
	w, h = surface.GetTextSize(self.hud_BattleModePhrase)
	self.hud_BattleModePhraseWidth = w
	self.hud_BattleModePhraseHeight = h

	surface.SetFont(HUD_TIMER_FONT)
	w, h = surface.GetTextSize("00")
	self.hud_TimerWidth = w
	self.hud_TimerHeight = h
end

function GM:HUDPaint()
	BaseClass.HUDPaint(self)
	self:HUDDrawRoundData()
	self:HUDDrawTimer()
end

function GM:HUDDrawRoundData()
	local sWidthHalf = ScrW() / 2
	local sHeight = ScrH()
	--- @type string, number, number
	local text, textWidth, textHeight
	if self.m_RoundPhase == ROUND_PHASE_PREP then
		text = self.hud_PrepModePhrase
		textWidth = self.hud_PrepModePhraseWidth
		textHeight = self.hud_PrepModePhraseHeight
	elseif self.m_RoundPhase == ROUND_PHASE_BATTLE then
		text = self.hud_BattleModePhrase
		textWidth = self.hud_BattleModePhraseWidth
		textHeight = self.hud_BattleModePhraseHeight
	else
		text = self.hud_BuildModePhrase
		textWidth = self.hud_BuildModePhraseWidth
		textHeight = self.hud_BuildModePhraseHeight
	end

	local widthHalf = textWidth / 2

	local textVOffset = sHeight - textHeight - 45
	local PADDING_H = 5
	local PADDING_W = 15

	draw.RoundedBox(
		8,
		sWidthHalf - widthHalf - PADDING_W,
		textVOffset - PADDING_H - 2,
		textWidth + PADDING_W * 2,
		textHeight + PADDING_H * 2,
		HUD_BACKGROUND_COLOUR
	)

	surface.SetFont(HUD_TEXT_FONT)
	surface.SetTextColor(
		HUD_TEXT_COLOUR.r,
		HUD_TEXT_COLOUR.g,
		HUD_TEXT_COLOUR.b,
		HUD_TEXT_COLOUR.a
	)
	surface.SetTextPos(
		sWidthHalf - widthHalf,
		textVOffset
	)
	surface.DrawText(text)


	-- draw.DrawText(
	-- text,
	-- HUD_TEXT_FONT, (ScrW() / 2) - 30, ScrH() - 70, HUD_TEXT_COLOUR)

	-- draw.RoundedBox(8, 265, ScrH() - 108, 200, 81, HUD_BACKGROUND_COLOUR)
	-- draw.RoundedBox(8, ScrW() / 2 - 50, ScrH() - 90, 200, 70, HUD_BACKGROUND_COLOUR)
	-- draw.DrawText("10  10", "OSEHudTimer", (ScrW() / 2) - 50, 20, HUD_TEXT_COLOUR)
	-- draw.DrawText(":", "OSEHudTimerColon", (ScrW() / 2) + 1, 20, HUD_TEXT_COLOUR)
	-- draw.DrawText("SUIT", HUD_TEXT_FONT, 323, ScrH() - 170, HUD_TEXT_BRIGHT_COLOUR)
end

--- @param phaseEnd number
--- @return string, string
local function calcTimeLeft(phaseEnd)
	local timeLeft = phaseEnd - CurTime()
	if timeLeft < 0 then
		return "00", "00"
	end

	local mins = timeLeft / 60
	local secs = timeLeft % 60

	return string.format("%02d", mins), string.format("%02d", secs)
end

function GM:HUDDrawTimer()
	local sWidthHalf = ScrW() / 2
	local textVOffset = 20
	local textWidth = self.hud_TimerWidth
	local textHeight = self.hud_TimerHeight
	local centrePadding = 8

	local PADDING_H = 5
	local PADDING_W = 15

	local mins, secs = calcTimeLeft(self.m_PhaseEnd)

	draw.RoundedBox(
		8,
		sWidthHalf - textWidth - centrePadding - PADDING_W,
		textVOffset - 2,
		(textWidth + PADDING_W + centrePadding) * 2,
		textHeight + PADDING_H * 2,
		HUD_BACKGROUND_COLOUR
	)

	surface.SetFont(HUD_TIMER_FONT)
	surface.SetTextColor(
		HUD_TEXT_COLOUR.r,
		HUD_TEXT_COLOUR.g,
		HUD_TEXT_COLOUR.b,
		HUD_TEXT_COLOUR.a
	)
	surface.SetTextPos(
		sWidthHalf - textWidth - centrePadding,
		textVOffset
	)
	surface.DrawText(mins)
	surface.SetTextPos(
		sWidthHalf + centrePadding,
		textVOffset
	)
	surface.DrawText(secs)

	-- TODO: Should this thing blink? Probably yes?
	surface.SetFont(HUD_TIMER_COLON_FONT)
	surface.SetTextPos(
		sWidthHalf - 7,
		textVOffset - 1
	)
	surface.DrawText(":")
end
