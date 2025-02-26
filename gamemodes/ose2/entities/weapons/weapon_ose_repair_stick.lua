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
SWEP.WorldModel = Model("models/weapons/w_stunstick.mdl")
SWEP.Slot = 3

SWEP.DrawAmmo = false
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Ammo = "none"

local SOUND_MISS = Sound("Weapon_StunStick.Melee_Miss")
local SOUND_HIT_ALIVE = Sound("Weapon_StunStick.Melee_Hit")
local SOUND_HIT_OBJECT = Sound("Weapon_StunStick.Melee_HitWorld")

function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

-- "Stretch the swing box down to catch low level physics objects"
-- local STUNSTICK_MINS = Vector(-16, -16, -40)

-- Don't do that because it complicates matters
local STUNSTICK_MINS = Vector(-16, -16, -16)
local STUNSTICK_MAXS = Vector(16, 16, 16)

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.3)
	local owner = self:GetOwner()
	-- owner cannot be a NPC
	--- @cast owner GPlayer
	local shootPos = owner:GetShootPos()
	local aimvec = owner:GetAimVector()
	--- @type SHullTrace
	local hullTrace = {
		start = shootPos,
		endpos = shootPos + aimvec * 32,
		mins = STUNSTICK_MINS,
		maxs = STUNSTICK_MAXS,
		filter = owner,
	}
	debugoverlay.SweptBox(hullTrace.start, hullTrace.endpos, hullTrace.mins, hullTrace.maxs, aimvec:Angle())
	local tr = util.TraceHull(hullTrace) --[[@as STraceResult]]
	if not tr.Hit then
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
		self:EmitSound(SOUND_MISS)
		return
	end
	self:SendWeaponAnim(ACT_VM_HITCENTER)

	local hitEnt = tr.Entity
	if not IsValid(hitEnt) then
		hitEnt = nil
	end

	-- NOTE: tr.HitPos is *NOT* the point where the hull trace collided!!
	-- See if we can relaibly do hit effects
	--- @type STrace
	local tr2c = {
		start = tr.HitPos,
		endpos = tr.HitPos + tr.Normal * 32,
	}
	local tr2 = util.TraceLine(tr2c) --[[@as STraceResult]]
	--- @type GVector?
	local hitpos = nil
	--- @type GVector?
	local hitnormal = nil
	-- time to get silly with it
	if
		tr2.Hit
		and
		(
			not hitEnt
			or
			(
				IsValid(tr2.Entity)
				and tr2.Entity == hitEnt
			)
		)
	then
		hitpos = tr2.HitPos
		hitnormal = tr2.HitNormal
	elseif hitEnt then
		hitpos = hitEnt:NearestPoint(tr.HitPos)
		-- TODO: CHECK DIRECTION!! MIGHT BE INVERTED!!
		hitnormal = (hitpos - tr.HitPos):Normal()
	end


	--- @type number?
	local bloodColour = nil
	local didOwnBloodEffect = false
	if hitEnt then
		local dmginfo = DamageInfo()
		if hitEnt["oseProp"] then
			self:HealEntity(hitEnt, PROP_REPAIR_VALUE, hitpos, hitnormal)
			return
		elseif IsValid(hitEnt._oseSpawner) then
			-- Currently only turrets can be repaired
			if hitEnt:GetClass() == "npc_turret_floor" then
				self:HealEntity(hitEnt._oseSpawner, TURRET_REPAIR_VALUE, hitpos, hitnormal)
			end
			return
		elseif hitEnt:IsNPC() and --[[@cast hitEnt GNPC]] hitEnt:Disposition(owner) ~= D_LI then
			dmginfo:SetDamage(NPC_DAMAGE_AMOUNT)
			didOwnBloodEffect = true
		end

		bloodColour = hitEnt:GetBloodColor()

		if SERVER and IsFirstTimePredicted() then
			dmginfo:SetAttacker(owner)
			dmginfo:SetInflictor(self)
			dmginfo:SetDamageForce(aimvec * 50)
			dmginfo:SetDamagePosition(hitpos or tr.HitPos)
			dmginfo:SetReportedPosition(shootPos)
			dmginfo:SetDamageType(DMG_CLUB)
			-- hitEnt:TakeDamageInfo(dmginfo)

			hitEnt:DispatchTraceAttack(dmginfo, tr)
		end
	end

	local shouldFlesh = bloodColour ~= nil and bloodColour ~= -1

	if shouldFlesh then
		self:EmitSound(SOUND_HIT_ALIVE)
	else
		self:EmitSound(SOUND_HIT_OBJECT)
	end

	if
		not IsFirstTimePredicted()
		or hitnormal == nil
		or hitpos == nil
	then
		return
	end

	if shouldFlesh and not didOwnBloodEffect then
		local effectData = EffectData()
		effectData:SetOrigin(hitpos)
		effectData:SetNormal(hitnormal)
		---@diagnostic disable-next-line: param-type-mismatch
		effectData:SetColor(bloodColour)
		util.Effect("BloodImpact", effectData)
	end

	--- @type SBullet
	local boolet = {
		Src = shootPos,
		-- TODO: CHECK DIRECTION HERE TOO
		Dir = shootPos - hitpos,
		Num = 1,
		Damage = 0,
		Spread = vector_origin,
		Tracer = 0,
		Force = 25,
	}
	-- Generate impact effects
	owner:FireBullets(boolet)
end

--- Applies healing and applies effects
--- @param ent GEntity
--- @param amount integer
--- @param hitPos GVector?
--- @param hitNormal GVector?
function SWEP:HealEntity(ent, amount, hitPos, hitNormal)
	-- TODO - effects?? Sounds??
	if SERVER and IsFirstTimePredicted() then
		local cHealth = ent:Health()
		local mHealth = ent:GetMaxHealth()
		if ent:IsOnFire() then
			-- If it's on fire they've gotta put it out first and we're
			-- gonna make that annoying for them
			if math.random(1, 3) == 1 then
				ent:Extinguish()
			end
		elseif cHealth < mHealth then
			ent:SetHealth(math.min(cHealth + amount, mHealth))
		end
	end
end

function SWEP:SecondaryAttack()
end
