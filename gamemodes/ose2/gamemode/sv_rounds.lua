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
util.AddNetworkString("PrepPhaseStarted")
util.AddNetworkString("BattlePhaseStarted")
util.AddNetworkString("RoundWon")
util.AddNetworkString("RoundLost")

function GM:SetupRounds()
	-- Hack - set everything up so the first tick will trigger build round #1
	self.m_RoundPhase = ROUND_PHASE_BATTLE
	self.m_Round = 0
	self.m_PhaseEnd = 0
	self.m_LastSecond = 0
end

function GM:StartBuildPhase()
	self.m_RoundPhase = ROUND_PHASE_BUILD
	local now = CurTime()
	self.m_PhaseStart = now
	self.m_PhaseEnd = now + buildTimeCvar:GetInt()

	for _, ply in player.Iterator() do
		--- @cast ply GPlayer
		player_manager.SetPlayerClass(ply, "player_builder")
		if ply:Alive() then
			ply:KillSilent()
			ply:Spawn()
		else
			ply.NextSpawnTime = 0
		end
	end

	net.Start("BuildPhaseStarted")
	net.WriteUInt(self.m_Round, 8)
	net.WriteFloat(self.m_PhaseStart)
	net.WriteFloat(self.m_PhaseEnd)
	net.Broadcast()
	hook.Call("BuildPhaseStarted", self, self.m_Round)
	hook.Call("PhaseStarted", self, self.m_PhaseStart, self.m_PhaseEnd)
	MsgAll("Starting the build phase!")
end

function GM:BuildPhaseStarted(roundNum) end

function GM:StartPrepPhase()
	self.m_RoundPhase = ROUND_PHASE_PREP
	local now = CurTime()
	self.m_PhaseStart = now
	self.m_PhaseEnd = now + 10

	for _, ply in player.Iterator() do
		--- @cast ply GPlayer
		ply:KillSilent()
		-- Spawning the player will change them to the correct class
		ply:Spawn()
		-- Reset the various battle flags.
		ply._joinedBattleLate = nil
		ply._deathCount = 0
	end

	net.Start("PrepPhaseStarted")
	net.WriteUInt(self.m_Round, 8)
	net.WriteFloat(self.m_PhaseStart)
	net.WriteFloat(self.m_PhaseEnd)
	net.Broadcast()
	hook.Call("PrepPhaseStarted", self, self.m_Round)
	hook.Call("PhaseStarted", self, self.m_PhaseStart, self.m_PhaseEnd)
	MsgAll("Starting the prep phase!")
end

function GM:PrepPhaseStarted(roundNum) end

function GM:StartBattlePhase()
	self.m_RoundPhase = ROUND_PHASE_BATTLE
	local now = CurTime()
	self.m_PhaseStart = now
	self.m_PhaseEnd = (
		now
		+ battleTimeBaseCvar:GetInt()
		+ ((self.m_Round - 1) * battleTimeaddCvar:GetInt())
	)

	net.Start("BattlePhaseStarted")
	net.WriteUInt(self.m_Round, 8)
	net.WriteFloat(self.m_PhaseStart)
	net.WriteFloat(self.m_PhaseEnd)
	net.Broadcast()
	hook.Call("BattlePhaseStarted", self, self.m_Round)
	hook.Call("PhaseStarted", self, self.m_PhaseStart, self.m_PhaseEnd)
	MsgAll("Starting the battle phase!")
end

function GM:BattlePhaseStarted(roundNum) end

function GM:WinRound()
	self.m_Round = self.m_Round + 1
	net.Start("RoundWon")
	net.Broadcast()
	hook.Call("RoundWon", self)
	self:StartBuildPhase()
end

function GM:RoundWon()
	for _, ply in player.Iterator() do
		--- @cast ply GPlayer

		--- @type number
		local reward = hook.Call(
			"CalculateRoundReward",
			self,
			ply,
			hook.Call("CalculateBaseRoundReward", self, ply, ply._deathCount)
		)
		if ply._joinedBattleLate then
			--- @type number
			local modifier = hook.Call(
				"CalculatePartialRoundModifier",
				self,
				ply,
				self.m_PhaseStart,
				ply._joinedBattleLate,
				self.m_PhaseEnd,
				true
			)
			reward = math.floor(reward * modifier)
		end
		if reward > 0 then
			ply:AddMoney(reward, "#ose.money.reason.round_won")
		end
	end
end

function GM:LoseRound()
	if self.m_Round > 1 then
		self.m_Round = self.m_Round - 1
	end
	net.Start("RoundLost")
	net.Broadcast()
	hook.Call("RoundLost", self)
	self:StartBuildPhase()
end

function GM:RoundLost()
	local now = CurTime()
	for _, ply in player.Iterator() do
		--- @cast ply GPlayer

		--- @type number
		local reward = hook.Call(
			"CalculateRoundReward",
			self,
			ply,
			hook.Call("CalculateBaseRoundReward", self, ply, ply._deathCount)
		)
		--- @type number
		local lossModifier = hook.Call(
			"CalculateLostRoundModifier",
			self,
			ply,
			self.m_PhaseStart,
			now,
			self.m_PhaseEnd
		)
		-- Set a floor and ceiling on the percentage of the reward players get,
		-- otherwise there would be barely any penalty for losing right at the
		-- end of the round and it's important to punish players.
		lossModifier = math.Clamp(lossModifier, 0.25, 0.75)
		if ply._joinedBattleLate then
			--- @type number
			local modifier = hook.Call(
				"CalculatePartialRoundModifier",
				self,
				ply,
				self.m_PhaseStart,
				ply._joinedBattleLate,
				self.m_PhaseEnd,
				true
			)
			lossModifier = lossModifier * modifier
		end
		reward = math.floor(reward * lossModifier)
		if reward > 0 then
			ply:AddMoney(reward, "#ose.money.reason.round_lost")
		end
	end
end

function GM:Tick()
	local now = CurTime()
	if self.m_PhaseEnd <= now then
		if self.m_RoundPhase == ROUND_PHASE_BUILD then
			self:StartPrepPhase()
		elseif self.m_RoundPhase == ROUND_PHASE_PREP then
			self:StartBattlePhase()
		elseif self.m_RoundPhase == ROUND_PHASE_BATTLE then
			self:WinRound()
		end
	end
	if now - self.m_LastSecond > 1 then
		self.m_LastSecond = now
		hook.Call("PhaseSecond", self, self.m_PhaseEnd - now)
	end
end

function GM:PhaseStarted(startedAt, endsAt) end

function GM:PhaseSecond(timeLeft) end

function GM:CheckForLoss()
	for _, ply in player.Iterator() do
		--- @cast ply GPlayer
		if ply:Alive() then
			return
		end
	end
	self:LoseRound()
end

function GM:PostPlayerDeath(ply)
	if self.m_RoundPhase == ROUND_PHASE_BATTLE then
		hook.Call("CheckForLoss", self)
	end
end

---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSEStartBuild(ply, cmd, args)
	if IsValid(ply) and not ply:IsListenServerHost() then
		ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have permission to use this command")
	end
	GAMEMODE:StartBuildPhase()
end

concommand.Add("ose_debug_start_build", ccOSEStartBuild, nil, "Force start the build phase")

---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSEStartBattle(ply, cmd, args)
	if IsValid(ply) and not ply:IsListenServerHost() then
		ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have permission to use this command")
	end
	GAMEMODE:StartPrepPhase()
end

concommand.Add("ose_debug_start_battle", ccOSEStartBattle, nil, "Force start the build phase")
