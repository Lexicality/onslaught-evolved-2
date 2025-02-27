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

local PROP_REPAIR_VALUE = 25
local TURRET_REPAIR_VALUE = 5
local NPC_DAMAGE_AMOUNT = 25

--- @class SWEP_OSERepairStick : SSWEP
local SWEP = SWEP --[[@as SWEP_OSERepairStick]]
--- @type SSWEP
local BaseClass
DEFINE_BASECLASS("weapon_base")

SWEP.PrintName = "#weapon_ose_repair_stick"
SWEP.DrawWeaponInfoBox = false -- TODO!

-- TODO: Icon
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_stunstick.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")
SWEP.Slot = 1

SWEP.DrawAmmo = false
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

local SOUND_MISS = Sound("Weapon_StunStick.Melee_Miss")
local SOUND_HIT_ALIVE = Sound("Weapon_StunStick.Melee_Hit")
local SOUND_HIT_OBJECT = Sound("Weapon_StunStick.Melee_HitWorld")
local SOUND_EXTINGUISH = Sound("ambient/fire/mtov_flame2.wav")
local SOUND_HEAL = Sound("npc/dog/dog_idle3.wav")
local SOUND_HEAL_FAIL = Sound("npc/dog/dog_idle2.wav")

function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

-- "Stretch the swing box down to catch low level physics objects"
-- local STUNSTICK_MINS = Vector(-16, -16, -40)

-- Don't do that because it complicates matters
local STUNSTICK_MINS = Vector(-16, -16, -16)
local STUNSTICK_MAXS = Vector(16, 16, 16)

local STUNSTICK_RANGE = 75 -- match the crowbar
-- local HULL_REACH = 1.732 * 16 -- magic
local HULL_REACH = 16      -- not magic

local DEBUG_COLOUR_RED = Color(255, 0, 0)
local DEBUG_COLOUR_GREEN = Color(0, 255, 0)
local DEBUG_COLOUR_BLUE = Color(0, 0, 255)
local DEBUG_LIFETIME = 10

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.3)
	-- Basing this on https://github.com/ValveSoftware/source-sdk-2013/blob/aea94b32cbefeba5d16ef6fc70eff9508cf11673/src/game/shared/hl2mp/weapon_hl2mpbasebasebludgeon.cpp#L286

	local owner = self:GetOwner()
	-- owner cannot be a NPC
	--- @cast owner GPlayer
	local startPos = owner:GetShootPos()
	local forward = owner:GetAimVector()
	local endPos = startPos + (forward * STUNSTICK_RANGE)

	--- @type STrace
	local trc = {
		start = startPos,
		endpos = endPos,
		mask = MASK_SHOT_HULL,
		filter = owner,
	}
	-- First do a direct trace as to what the player's looking at, to avoid
	-- surprises like the hull trace hitting something at the side of the screen
	-- that's technically closer than what the player's aiming at
	local tr = util.TraceLine(trc) --[[@as STraceResult]]

	-- debugoverlay.Line(startPos, endPos, DEBUG_LIFETIME)

	if not tr.Hit then
		-- If they're not looking directly at anything, do a hull trace to see
		-- if they're close enough to something to hit that anyway
		--- @type SHullTrace
		local hullTrace = {
			start = startPos,
			endpos = endPos - forward * HULL_REACH,
			mins = STUNSTICK_MINS,
			maxs = STUNSTICK_MAXS,
			mask = MASK_SHOT_HULL,
			filter = owner,
		}
		local hullTraceResult = util.TraceHull(hullTrace) --[[@as STraceResult]]
		-- debugoverlay.SweptBox(
		-- 	hullTrace.start,
		-- 	hullTrace.endpos,
		-- 	hullTrace.mins,
		-- 	hullTrace.maxs,
		-- 	forward:Angle(),
		-- 	DEBUG_LIFETIME,
		-- 	hullTraceResult.Hit and color_white or DEBUG_COLOUR_RED
		-- )
		local maybeTR = self:_ReconstructTrace(hullTraceResult)
		if maybeTR then
			tr = maybeTR
		end
	end

	if not tr.Hit then
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
		self:EmitSound(SOUND_MISS)
		return
	end

	self:SendWeaponAnim(ACT_VM_HITCENTER)

	local hitEnt = tr.Entity
	--- @type number?
	local bloodColour = nil
	local didOwnBloodEffect = false
	if hitEnt and IsValid(hitEnt) then
		local dmginfo = DamageInfo()
		if hitEnt["OSEProp"] then
			self:HealEntity(tr, hitEnt, PROP_REPAIR_VALUE)
			return
		elseif hitEnt:GetClass() == "npc_turret_floor" then
			local spawner = hitEnt:GetNW2Entity("OSESpawner")
			if IsValid(spawner) then
				self:HealEntity(tr, spawner, TURRET_REPAIR_VALUE)
				return
			end
		elseif SERVER and hitEnt:IsNPC() and --[[@cast hitEnt GNPC]] hitEnt:Disposition(owner) ~= D_LI then
			dmginfo:SetDamage(NPC_DAMAGE_AMOUNT)
			didOwnBloodEffect = true
		end

		bloodColour = hitEnt:GetBloodColor()

		if SERVER and IsFirstTimePredicted() then
			dmginfo:SetAttacker(owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageForce(forward * 10)
			dmginfo:SetDamagePosition(tr.HitPos)
			dmginfo:SetReportedPosition(startPos)
			dmginfo:SetDamageType(DMG_CLUB)
			hitEnt:DispatchTraceAttack(dmginfo, tr)
		end
	end

	local shouldFlesh = bloodColour ~= nil and bloodColour ~= -1

	if shouldFlesh then
		self:EmitSound(SOUND_HIT_ALIVE)
	else
		self:EmitSound(SOUND_HIT_OBJECT)
	end

	if not IsFirstTimePredicted() then
		return
	end

	if shouldFlesh and not didOwnBloodEffect then
		local effectData = EffectData()
		effectData:SetOrigin(tr.HitPos)
		effectData:SetNormal(tr.HitNormal)
		---@diagnostic disable-next-line: param-type-mismatch
		effectData:SetColor(bloodColour)
		util.Effect("BloodImpact", effectData)
	end

	--- @type SBullet
	local boolet = {
		Src = startPos,
		Dir = tr.HitPos - startPos,
		Num = 1,
		Damage = 0,
		Spread = vector_origin,
		Tracer = 0,
		Force = 10,
	}
	-- Generate impact effects
	owner:FireBullets(boolet)
end

--- Creates a new attack trace that actually hits the hull traced entity
--- @param tr STraceResult
--- @return STraceResult | nil
function SWEP:_ReconstructTrace(tr)
	local ent = tr.Entity
	if not ent or not IsValid(ent) then
		return nil
	end

	local owner = self:GetOwner()
	--- @cast owner GPlayer
	local startPos = owner:GetShootPos()
	local forward = owner:GetAimVector()

	-- https://github.com/ValveSoftware/source-sdk-2013/blob/aea94b32cbefeba5d16ef6fc70eff9508cf11673/src/game/shared/hl2mp/weapon_hl2mpbasebasebludgeon.cpp#L320-L331
	-- local targetdir = ent:GetPos() - startPos
	local targetdir = ent:WorldSpaceCenter() - startPos
	targetdir:Normalize()
	-- "YWB:  Make sure they are sort of facing the guy at least..."
	if targetdir:Dot(forward) < 0.70721 then
		return nil
	end

	-- https://github.com/ValveSoftware/source-sdk-2013/blob/aea94b32cbefeba5d16ef6fc70eff9508cf11673/src/game/shared/hl2mp/weapon_hl2mpbasebasebludgeon.cpp#L175C97-L175C103
	-- local endPos = startPos + (tr.HitPos - tr.StartPos) * 2
	local endPos = startPos + forward * STUNSTICK_RANGE

	--- @type STrace
	local trConf = {
		start = startPos,
		endpos = endPos,
		mask = MASK_SHOT_HULL,
		filter = owner,
	}
	-- local tempTR = util.TraceLine(trConf) --[[@as STraceResult]]

	-- if tempTR.Hit then
	-- 	-- debugoverlay.Line(startPos, endPos, DEBUG_LIFETIME, DEBUG_COLOUR_GREEN, true)
	-- 	return tempTR
	-- end

	-- debugoverlay.Line(startPos, endPos, DEBUG_LIFETIME, DEBUG_COLOUR_RED, true)

	--- @type STraceResult?
	local ret = nil
	local dist = 1e6

	local minmax = { STUNSTICK_MINS, STUNSTICK_MAXS }

	for i = 1, 2 do
		for j = 1, 2 do
			for k = 1, 2 do
				trConf.endpos = Vector(
					endPos.x + minmax[i].x,
					endPos.y + minmax[j].y,
					endPos.z + minmax[k].z
				)
				local tempTR = util.TraceLine(trConf) --[[@as STraceResult]]
				if tempTR.Hit then
					-- debugoverlay.Line(trConf.start, tempTR.HitPos, DEBUG_LIFETIME, DEBUG_COLOUR_GREEN, true)
					-- debugoverlay.Cross(tempTR.HitPos, 1, DEBUG_LIFETIME, DEBUG_COLOUR_GREEN, true)
					local thisDist = (tempTR.HitPos - startPos) --[[@as GVector]]:Length()
					if thisDist < dist then
						dist = thisDist
						ret = tempTR
					end
					-- else
					-- 	debugoverlay.Line(trConf.start, tempTR.HitPos, DEBUG_LIFETIME, DEBUG_COLOUR_RED, true)
					-- 	debugoverlay.Cross(trConf.endpos, 1, DEBUG_LIFETIME, DEBUG_COLOUR_RED, true)
				end
			end
		end
	end


	return ret
end

--- Applies healing and applies effects
--- @param tr STraceResult
--- @param ent GEntity
--- @param amount integer
function SWEP:HealEntity(tr, ent, amount)
	local cHealth = ent:Health()
	local mHealth = ent:GetMaxHealth()
	if ent:IsOnFire() then
		-- If it's on fire they've gotta put it out first and we're
		-- gonna make that annoying for them
		local rando = math.floor(util.SharedRandom("Repair Extinguish", 1, 3))
		if rando == 1 then
			self:EmitSound(SOUND_EXTINGUISH)
			-- sound/ambient/fire/mtov_flame2.wav
			if SERVER and IsFirstTimePredicted() then
				ent:Extinguish()
			end
		else
			self:EmitSound(SOUND_HIT_OBJECT)
		end
	elseif cHealth < mHealth then
		self:EmitSound(SOUND_HEAL)
		if SERVER and IsFirstTimePredicted() then
			-- TODO - some kind of healing effect would be nice
			ent:SetHealth(math.min(cHealth + amount, mHealth))
		end
	else
		self:EmitSound(SOUND_HEAL_FAIL)
	end
end

function SWEP:SecondaryAttack()
end
