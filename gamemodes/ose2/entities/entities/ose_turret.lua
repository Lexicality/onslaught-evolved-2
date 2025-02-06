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

AddCSLuaFile()

--- @class SENT_OSETurret : SENT_OSEProp
--- @field m_Turret GEntity | nil
local ENT = ENT --[[@as SENT_OSETurret]]
--- @type SENT_OSEProp
local BaseClass
DEFINE_BASECLASS("ose_prop")

local TURRET_MODEL = "models/combine_turrets/floor_turret.mdl"
local TURRET_CITIZEN_SKIN_MIN = 1
local TURRET_CITIZEN_SKIN_MAX = 2
-- TODO: Configurable?
local TURRET_HEALTH = 100

SF_FLOOR_TURRET_FASTRETIRE = 128

function ENT:Initialize()
	self:SetModel(TURRET_MODEL)

	-- TODO: Probs don't need to reset the pitch/yaw pose parameters?
	-- The c++ does this:
	-- SetPoseParameter( m_poseAim_Yaw, 0 );
	-- SetPoseParameter( m_poseAim_Pitch, 0 );

	if CLIENT then
		-- 	self:InvalidateBoneCache()
		return
	end

	-- Look citizen-ey
	self:SetSkin(math.random(TURRET_CITIZEN_SKIN_MIN, TURRET_CITIZEN_SKIN_MAX))

	BaseClass.Initialize(self)

	-- We're not going to be using any of the dynamic health stuff here
	-- TODO: Do we want a hook? Probably want a hook.
	self.m_BaseHealth = TURRET_HEALTH
	self:SetMaxHealth(TURRET_HEALTH)
	self:SetHealth(TURRET_HEALTH)
end

if CLIENT then return end

function ENT:SetupHooks()
	BaseClass.SetupHooks(self)
	hook.Add("BattlePhaseStarted", self, self._OnBattlePhase)
end

function ENT:_OnPrepPhase(roundNum)
	self:RemoveTurret()

	-- Make us not get in the way of the actual mine
	self:SetNoDraw(true)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local turret = ents.Create("npc_turret_floor")
	if not IsValid(turret) then
		error("Couldn't create turret!")
	end
	-- Set FASTRETIRE on the turret so the turret only alerts for a second
	turret:SetKeyValue("spawnflags", tostring(SF_FLOOR_TURRET_FASTRETIRE + SF_FLOOR_TURRET_CITIZEN))
	turret:SetKeyValue("SkinNumber", tostring(self:GetSkin()))
	turret:SetName(self:GetName() .. "_turret")
	turret:SetPos(self:GetPos())
	turret:SetAngles(self:GetAngles())
	self:SetParent(turret)
	self:DeleteOnRemove(turret)
	turret:SetCreator(self:GetCreator())
	turret._oseSpawner = self

	turret:Spawn()
	turret:Activate()
	-- Make the turret wiggle around, possibly causing it to fall over if it's been placed weirdly
	turret:Fire("Enable", "", 0.1)
	self.m_Turret = turret
end

function ENT:_OnBattlePhase(roundNum)
	local turret = self.m_Turret
	if turret and IsValid(turret) then
		-- Get rid of FASTRETIRE so the turret is more deadly for the fight
		turret:SetKeyValue("spawnflags", tostring(SF_FLOOR_TURRET_CITIZEN))
		-- Give the turret another kick so it can immediately start attacking
		-- NPCs if needed
		turret:Fire("Enable", "", 0)
	end
end

function ENT:RemoveTurret()
	if IsValid(self.m_Turret) then
		-- Prevent some weird snapback behaviours when de-parented
		local pos = self.m_Turret:GetPos()
		self:SetParent(NULL)
		self:SetPos(pos)

		self.m_Turret:Remove()
	end
end

function ENT:_OnBuildPhase(roundNum)
	self:RemoveTurret()
	self:SetNoDraw(false)
	BaseClass._OnBuildPhase(self, roundNum)
end

function ENT:Die()
	-- If we've got a turret spawned, have it go out in a blaze of glory
	local turret = self.m_Turret
	if turret and IsValid(turret) then
		-- First, detach ourselves from the turret
		self:DontDeleteOnRemove(turret)
		self:SetParent(NULL)
		-- Then silently disappear
		self:Remove()
		-- Now it's safe for the turret to blow itself up
		turret:Fire("SelfDestruct")
	else
		-- Otherwise, do the normal boring thing
		BaseClass.Die(self)
	end
end

function ENT:OnHitNobuild()
	if IsValid(self.m_Turret) then
		local vel = self.m_Turret:GetVelocity()
		self:RemoveTurret()
		self:SetNoDraw(false)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:EnableMotion(true)
		phys:Wake()
		phys:AddVelocity(vel)
	end
	BaseClass.OnHitNobuild(self)
end
