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

	-- We need the player to have a consistent class from here on out and it
	-- doesn't really matter what that class is.
	-- If we set them as a builder and it's the build phase, everything is good.
	-- However, if we're mid battle, `PlayerSpawn` which is called immediately
	-- after this will notice they're the wrong class and fix that
	player_manager.SetPlayerClass(ply, "player_builder")
	-- TODO: Do we want to try and save the class the player was last time they
	-- played and set them to it? Per server? Global client `ose_preferredclass`
	-- cvar? Much to ponder.
	ply:SetTargetClass("player_soldier")

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

	-- restore all created entities
	local sid = ply:SteamID64()
	for _, ent in ents.Iterator() do
		--- @cast ent  GEntity
		if ent._oseCreatorSID == sid then
			ent:SetCreator(ply)
		end
	end
end

---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSEChooseClass(ply, cmd, args)
	if not IsValid(ply) then
		print("No classes for the server, stupid")
		return
	end
	local class = args[1]
	--- @type OSEClassDefinition
	local classData = list.GetEntry("OSEClasses", class)
	if not classData or not classData.Selectable then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.invalid_class", 10, class)
		return
	elseif class == ply:GetTargetClass() then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.same_class", 10, classData.Name)
		return
	elseif not hook.Run("PlayerCanChooseClass", ply, class, classData) then
		-- Notifying the player is the hook's problem
		return
	end

	ply:SetTargetClass(class)
	local name = classData.Name
	if GAMEMODE.m_RoundPhase == ROUND_PHASE_BUILD then
		ply:SendNotification(NOTIFY_GENERIC, "ose.notification.new_class_build", 10, name)
	else
		ply:SendNotification(NOTIFY_GENERIC, "ose.notification.new_class_battle", 10, name)
	end
end
concommand.Add("ose_chooseclass", ccOSEChooseClass, nil, "Picks what class to spawn as in the battle phase")
