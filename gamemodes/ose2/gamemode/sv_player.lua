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

--- @type SGM
local BaseClass
DEFINE_BASECLASS("gamemode_base")

local noclipCvar = GetConVar("ose_build_noclip")
local spawnBaseCvar = GetConVar("ose_spawn_time_base")
local spawnAddCvar = GetConVar("ose_spawn_time_add")

function GM:PlayerNoClip(ply, desiredState)
	-- Players can always un-noclip
	if not desiredState then
		return true
	end
	-- No one may noclip during the battle
	if self.m_RoundPhase ~= ROUND_PHASE_BUILD then
		return false
	end

	return ply:IsAdmin() or noclipCvar:GetBool()
end

function GM:PlayerDeath(ply, attacker, dmg)
	BaseClass.PlayerDeath(self, ply, attacker, dmg)

	if self.m_RoundPhase == ROUND_PHASE_BATTLE then
		ply.NextSpawnTime = CurTime() + spawnBaseCvar:GetInt() +
			(spawnAddCvar:GetInt() * player.GetCount())
	end
end

function GM:PlayerSpawn(ply, isTransiton)
	if self.m_RoundPhase ~= ROUND_PHASE_BUILD and ply:GetTargetClassID() ~= ply:GetClassID() then
		player_manager.SetPlayerClass(ply, ply:GetTargetClass())
	end

	BaseClass.PlayerSpawn(self, ply, isTransiton)
end

function GM:PlayerInitialSpawn(ply, isTransiton)
	BaseClass.PlayerInitialSpawn(self, ply, isTransiton)

	if self.m_RoundPhase == ROUND_PHASE_BUILD then
		player_manager.SetPlayerClass(ply, "player_builder")
	else
		-- TODO: Do we want to try and save the class the player was last time
		-- they played and set them to it? Per server? Global client
		-- `ose_preferredclass` cvar? Much to ponder.
		player_manager.SetPlayerClass(ply, "player_soldier")
		ply:SetTargetClassID(ply:GetClassID())
	end

	if self.m_RoundPhase == ROUND_PHASE_BUILD then
		net.Start("BuildPhaseStarted")
	elseif self.m_RoundPhase == ROUND_PHASE_PREP then
		net.Start("PrepPhaseStarted")
	else
		net.Start("BattlePhaseStarted")
	end
	net.WriteUInt(self.m_Round, 8)
	net.WriteFloat(self.m_PhaseEnd)
	net.Broadcast()
end

local VALID_CLASSES = {
	player_engineer = false, -- TODO: All the SWEPs!
	player_pyro = false,  -- TODO: Flamethrower
	player_scout = true,
	player_sniper = true,
	player_soldier = true,
	player_support = false, -- TODO: Work out how to actually do this one
}

--- Checks if a player class is usable
--- @param class string @Arbitrary text input from the user
--- @return boolean
function GM:IsValidPlayerClass(class)
	return VALID_CLASSES[class] or false
end

--- Checks if a player is allowed to choose a certain class
--- @param ply GPlayer @The player who wants to switch to this class
--- @param class string @The pre-validated class, eg `player_soldier`
--- @return boolean
function GM:PlayerCanChooseClass(ply, class)
	return true
end
