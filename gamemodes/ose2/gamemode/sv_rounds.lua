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

local buildTimeCvar = GetConVar("ose_build_time")
local battleTimeBaseCvar = GetConVar("ose_battle_time_base")
local battleTimeaddCvar = GetConVar("ose_battle_time_add")

util.AddNetworkString("BuildPhaseStarted")
util.AddNetworkString("BattlePhaseStarted")
util.AddNetworkString("RoundWon")
util.AddNetworkString("RoundLost")

function GM:SetupRounds()
	-- Hack - set everything up so the first tick will trigger build round #1
	self.m_BattlePhase = true
	self.m_Round = 0
	self.m_PhaseEnd = 0
	self.m_LastSecond = 0
end

function GM:StartBuildPhase()
	self.m_BattlePhase = false
	self.m_PhaseEnd = CurTime() + buildTimeCvar:GetInt()

	-- TODO

	net.Start("BuildPhaseStarted")
	net.WriteUInt(self.m_Round, 8)
	net.WriteFloat(self.m_PhaseEnd)
	net.Broadcast()
	gamemode.Call("BuildPhaseStarted", self.m_Round)
	gamemode.Call("PhaseStarted", self.m_PhaseEnd)
end

function GM:StartBattlePhase()
	self.m_BattlePhase = true
	self.m_PhaseEnd = (
		CurTime()
		+ battleTimeBaseCvar:GetInt()
		+ ((self.m_Round - 1) * battleTimeaddCvar:GetInt())
	)

	-- TODO

	net.Start("BattlePhaseStarted")
	net.WriteUInt(self.m_Round, 8)
	net.WriteFloat(self.m_PhaseEnd)
	net.Broadcast()
	gamemode.Call("BattlePhaseStarted", self.m_Round)
	gamemode.Call("PhaseStarted", self.m_PhaseEnd)
end

function GM:WinRound()
	-- TODO
	self.m_Round = self.m_Round + 1
	net.Start("RoundWon")
	net.Broadcast()
	gamemode.Call("RoundWon")
	self:StartBuildPhase()
end

function GM:LoseRound()
	-- TODO
	if self.m_Round > 1 then
		self.m_Round = self.m_Round - 1
	end
	net.Start("RoundLost")
	net.Broadcast()
	gamemode.Call("RoundLost")
	self:StartBuildPhase()
end

function GM:Tick()
	local now = CurTime()
	if self.m_PhaseEnd <= now then
		if self.m_BattlePhase then
			self:WinRound()
		else
			self:StartBattlePhase()
		end
	end
	if now - self.m_LastSecond > 1 then
		self.m_LastSecond = now
		gamemode.Call("PhaseSecond", self.m_PhaseEnd - now)
	end
end

function GM:CheckForLoss()
	for _, ply in ipairs(player.GetAll()) do
		--- @cast ply GPlayer
		if ply:Alive() then
			return
		end
	end
	self:LoseRound()
end

-- TODO: Check which death hook to actually use
---@param ply GPlayer
---@param attacker GEntity
---@param dmg GCTakeDamageInfo
function GM:PlayerDeath(ply, attacker, dmg)
	-- TODO
	self:CheckForLoss()
end