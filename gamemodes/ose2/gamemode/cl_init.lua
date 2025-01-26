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

include("cl_hud.lua")

function GM:OnGamemodeLoaded()
	MsgN("Hello from OSE2!")
	self:SetupRounds()
	self:SetupProps()
	self:SetupHUD()
end

function GM:OnReloaded()
	self:SetupHUD()
end

--- Called when the user switches languages
--- @param new string The new language name
--- @param old string The old language name
function GM:OnLanguageChanged(new, old)
	self:SetupHUD()
end

cvars.AddChangeCallback(
	"gmod_language",
	function(_, old, new)
		GAMEMODE:OnLanguageChanged(new, old)
	end,
	"OSE OnLanguageChanged"
)


function GM:SetupRounds()
	--- @type `ROUND_PHASE_BUILD` | `ROUND_PHASE_PREP` | `ROUND_PHASE_BATTLE`
	self.m_RoundPhase = ROUND_PHASE_BUILD
	--- @type integer
	self.m_Round = 0
	--- @type number
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
	gamemode.Call("BuildPhaseStarted", roundNum)
	gamemode.Call("PhaseStarted", phaseEnd)
end)

net.Receive("PrepPhaseStarted", function()
	local roundNum = net.ReadUInt(8)
	local phaseEnd = net.ReadFloat()
	gamemode.Call("PrepPhaseStarted", roundNum)
	gamemode.Call("PhaseStarted", phaseEnd)
end)

net.Receive("BattlePhaseStarted", function()
	local roundNum = net.ReadUInt(8)
	local phaseEnd = net.ReadFloat()
	gamemode.Call("BattlePhaseStarted", roundNum)
	gamemode.Call("PhaseStarted", phaseEnd)
end)

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
