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

include("shared.lua")

include("cl_deathnotice.lua")
include("cl_effects.lua")
include("cl_hud.lua")
include("ui/cl_spawnmenu.lua")

function GM:OnGamemodeLoaded()
	MsgN("Hello from OSE2!")
	self:SetupRounds()
	self:SetupProps()
	self:SetupHUD()
	self:SetupKillIcons()
end

function GM:InitPostEntity()
	-- This needs to be here because otherwise we can't create the temporary
	-- physobjects needed for the prop price calculation
	self:SetupSpawnMenu()
end

function GM:OnReloaded()
	MsgN("OSE2: Client reloaded!")
	self:SetupHUD()
	self:SetupSpawnMenu()
end

--- Called when the user switches languages
--- @param new string The new language name
--- @param old string The old language name
function GM:OnLanguageChanged(new, old)
	self:SetupHUD()
	self:SetupSpawnMenu()
end

cvars.AddChangeCallback(
	"gmod_language",
	function(_, old, new)
		GAMEMODE:OnLanguageChanged(new, old)
	end,
	"OSE OnLanguageChanged"
)


function GM:SetupRounds()
	self.m_RoundPhase = ROUND_PHASE_BUILD
	self.m_Round = 0
	self.m_PhaseEnd = 0.0
end

function GM:BuildPhaseStarted(roundNum)
	self.m_RoundPhase = ROUND_PHASE_BUILD
	self.m_Round = roundNum
end

function GM:PrepPhaseStarted(roundNum)
	self.m_RoundPhase = ROUND_PHASE_PREP
	self.m_Round = roundNum
end

function GM:BattlePhaseStarted(roundNum)
	self.m_RoundPhase = ROUND_PHASE_BATTLE
	self.m_Round = roundNum
end

function GM:PhaseStarted(endsAt)
	self.m_PhaseEnd = endsAt
end

net.Receive("BuildPhaseStarted", function()
	local roundNum = net.ReadUInt(8)
	local phaseEnd = net.ReadFloat()
	hook.Run("BuildPhaseStarted", roundNum)
	hook.Run("PhaseStarted", phaseEnd)
end)

net.Receive("PrepPhaseStarted", function()
	local roundNum = net.ReadUInt(8)
	local phaseEnd = net.ReadFloat()
	hook.Run("PrepPhaseStarted", roundNum)
	hook.Run("PhaseStarted", phaseEnd)
end)

net.Receive("BattlePhaseStarted", function()
	local roundNum = net.ReadUInt(8)
	local phaseEnd = net.ReadFloat()
	hook.Run("BattlePhaseStarted", roundNum)
	hook.Run("PhaseStarted", phaseEnd)
end)

--- Sandbox Compat
--- @param str string
--- @param type number
--- @param length number
function GM:AddNotify(str, type, length)
	notification.AddLegacy(str, type, length)
end

---@param name string
function GM:LimitHit(name)
	local str = "#SBoxLimit_" .. name
	local translated = language.GetPhrase(str)
	if str == translated then
		-- No translation available, apply our own
		translated = string.format(language.GetPhrase("hint.hitXlimit"), language.GetPhrase(name))
	end

	notification.AddLegacy(translated, NOTIFY_ERROR, 6)
	surface.PlaySound("buttons/button10.wav")
end

function GM:OnUndo(name, strCustomString)
	local text = strCustomString

	if not text then
		local strId = "#Undone_" .. name
		text = language.GetPhrase(strId)
		if strId == text then
			-- No translation available, generate our own
			text = string.format(
				language.GetPhrase("hint.undoneX"),
				language.GetPhrase(name)
			)
		end
	end

	notification.AddLegacy(text, NOTIFY_UNDO, 2)

	surface.PlaySound("buttons/button15.wav")
end

function GM:OnCleanup(name)
	local str = "#Cleaned_" .. name
	local translated = language.GetPhrase(str)
	if str == translated then
		-- No translation available, apply our own
		translated = string.format(
			language.GetPhrase("hint.cleanedX"),
			language.GetPhrase(name)
		)
	end

	notification.AddLegacy(translated, NOTIFY_CLEANUP, 5)

	surface.PlaySound("buttons/button15.wav")
end
