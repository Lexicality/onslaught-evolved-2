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
include("cl_notifications.lua")
include("ui/cl_ammomenu.lua")
include("ui/cl_spawnmenu.lua")

function GM:OnGamemodeLoaded()
	MsgN("Hello from OSE2!")
	self:SetupRounds()
	self:SetupProps()
	self:SetupHUD()
	self:SetupKillIcons()
	self:SetupClasses()
	self:SetupBuyables()
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

function GM:PhaseStarted(startedAt, endsAt)
	self.m_PhaseStart = startedAt
	self.m_PhaseEnd = endsAt
end

net.Receive("BuildPhaseStarted", function()
	local roundNum = net.ReadUInt(8)
	local phaseStart = net.ReadFloat()
	local phaseEnd = net.ReadFloat()
	hook.Run("BuildPhaseStarted", roundNum)
	hook.Run("PhaseStarted", phaseStart, phaseEnd)
end)

net.Receive("PrepPhaseStarted", function()
	local roundNum = net.ReadUInt(8)
	local phaseStart = net.ReadFloat()
	local phaseEnd = net.ReadFloat()
	hook.Run("PrepPhaseStarted", roundNum)
	hook.Run("PhaseStarted", phaseStart, phaseEnd)
end)

net.Receive("BattlePhaseStarted", function()
	local roundNum = net.ReadUInt(8)
	local phaseStart = net.ReadFloat()
	local phaseEnd = net.ReadFloat()
	hook.Run("BattlePhaseStarted", roundNum)
	hook.Run("PhaseStarted", phaseStart, phaseEnd)
end)
