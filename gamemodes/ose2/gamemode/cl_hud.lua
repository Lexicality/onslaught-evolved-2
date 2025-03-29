--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

---@type SGM
local BaseClass
DEFINE_BASECLASS("gamemode_base")


surface.CreateFont("OSEHudText", {
	font = "Verdana",
	size = 42,
	weight = 900,
})
surface.CreateFont("OSEHudTimer", {
	font = "HalfLife2",
	-- font = "Verdana",
	size = 52,
	weight = 0,
	additive = true
})
surface.CreateFont("OSEHudTimerColon", {
	font = "Verdana",
	size = 64,
	weight = 0,
	additive = true
})

local HUD_BACKGROUND_COLOUR = Color(0, 0, 0, 76)
local HUD_TEXT_COLOUR = Color(255, 235, 20, 255)
local HUD_DAMAGE_BACKGROUND_COLOUR = Color(180, 0, 0, 200)
local HUD_DAMAGE_TEXT_COLOUR = Color(180, 0, 0, 230)
local HUD_TEXT_FONT = "OSEHudText"
local HUD_TIMER_FONT = "OSEHudTimer"
local HUD_TIMER_COLON_FONT = "OSEHudTimerColon"


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

	self.hud_MoneyText = ""
	self.hud_MoneyLast = 0

	self.hud_ClassLast = -1
end

function GM:HUDPaint()
	BaseClass.HUDPaint(self)
	self:HUDDrawRoundData()
	self:HUDDrawTimer()
	self:HUDDrawMoney()
	self:HUDDrawClass()
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

function GM:HUDDrawMoney()
	local textOffset = 20
	local money = LocalPlayer():GetMoney()

	surface.SetFont(HUD_TEXT_FONT)
	if money ~= self.hud_MoneyLast then
		self.hud_MoneyText = string.FormatMoney(money)
		self.hud_MoneyWidth, self.hud_MoneyHeight = surface.GetTextSize(self.hud_MoneyText)
		self.hud_MoneyLast = money
	end
	local text = self.hud_MoneyText
	local textWidth = self.hud_MoneyWidth
	local textHeight = self.hud_MoneyHeight
	local PADDING_H = 5
	local PADDING_W = 15

	draw.RoundedBox(
		8,
		textOffset,
		textOffset,
		textWidth + PADDING_W * 2,
		textHeight + PADDING_H * 2,
		HUD_BACKGROUND_COLOUR
	)

	surface.SetTextColor(
		HUD_TEXT_COLOUR.r,
		HUD_TEXT_COLOUR.g,
		HUD_TEXT_COLOUR.b,
		HUD_TEXT_COLOUR.a
	)
	surface.SetTextPos(
		textOffset + PADDING_W,
		textOffset + PADDING_H + 3
	)
	surface.DrawText(text)
end

function GM:HUDDrawClass()
	local classID
	local lpl = LocalPlayer()
	if self.m_RoundPhase == ROUND_PHASE_BUILD then
		classID = lpl:GetTargetClassID()
	else
		classID = lpl:GetClassID()
	end

	surface.SetFont(HUD_TEXT_FONT)

	if classID == 0 then
		return
	elseif classID ~= self.hud_ClassLast then
		self.hud_ClassLast = classID
		local className = util.NetworkIDToString(classID)
		--- @type OSEClassDefinition
		local classData = list.GetEntry("OSEClasses", className)
		if classData == nil then
			self.hud_ClassText = ""
			return
		end
		local text = language.GetPhrase(classData.Name)
		self.hud_ClassText = text
		self.hud_ClassWidth, self.hud_ClassHeight = surface.GetTextSize(text)
	elseif not self.hud_ClassText then
		return
	end


	local sWidth = ScrW()
	local text, textWidth, textHeight = self.hud_ClassText, self.hud_ClassWidth, self.hud_ClassHeight

	local topPadding = 20
	local rightPadding = 20

	local PADDING_H = 5
	local PADDING_W = 15

	local textX = sWidth - rightPadding - textWidth - PADDING_W
	local textY = topPadding + PADDING_H + 3

	draw.RoundedBox(
		8,
		textX - PADDING_W,
		topPadding,
		textWidth + PADDING_W * 2,
		textHeight + PADDING_H * 2,
		HUD_BACKGROUND_COLOUR
	)

	surface.SetTextColor(
		HUD_TEXT_COLOUR.r,
		HUD_TEXT_COLOUR.g,
		HUD_TEXT_COLOUR.b,
		HUD_TEXT_COLOUR.a
	)
	surface.SetTextPos(textX, textY)
	surface.DrawText(text)
end
