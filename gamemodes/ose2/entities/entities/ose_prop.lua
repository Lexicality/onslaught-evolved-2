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
local cvarFlammible = GetConVar("ose_flammable_props")

AddCSLuaFile()

--- @class SENT_OSEProp : SENT_OSEBaseAnim
local ENT = ENT --[[@as SENT_OSEProp]]
--- @type SENT_OSEBaseAnim
local BaseClass
DEFINE_BASECLASS("base_oseanim")

--- If this is a prop or prop-derived entity
ENT.OSEProp = true

if CLIENT then return end

--- @type GEntity
ENT.m_BullsEye = NULL

--- The base health for this particular model, without any modifiers
--- @type number
ENT.m_BaseHealth = 0

function ENT:Initialize()
	local physResult = self:PhysicsInit(SOLID_VPHYSICS)
	if not physResult then
		ErrorNoHalt("ose_prop with invalid model ", self:GetModel(), "!\n")
		self:Remove()
		return
	end
	-- Wake the prop so that touch triggers fire for nobuild areas
	self:PhysWake()
	-- And immediately go back to sleep
	self:GetPhysicsObject():EnableMotion(false)

	-- hmm?
	self:SetUnFreezable(true)

	self.m_BaseHealth = hook.Run("LookupPropHealth", self:GetCreator(), self:GetModel())
	self:SetupHooks()

	if self:GetName() == "" then
		self:SetName("ose_prop_" .. self:EntIndex())
	end
end

function ENT:SetupHooks()
	hook.Add("PrepPhaseStarted", self, self._OnPrepPhase)
	hook.Add("BuildPhaseStarted", self, self._OnBuildPhase)
end

function ENT:OnReloaded()
	self:SetupHooks()
end

function ENT:_OnPrepPhase(roundNum)
	--- @type GVector
	local pos = self:GetPos()
	-- Ensure no one's done anything weird
	--- @type STraceResult
	local tr = util.QuickTrace(pos, vector_origin, self)
	if tr.HitWorld or not self:IsInWorld() then
		self:Remove()
	end

	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	-- Figure out how floaty we are
	--- @type STraceResult
	tr = util.QuickTrace(
		pos,
		Vector(0, 0, -1000),
		--
		ents.FindByClass("ose_*")
	)
	local isInSky = tr.Fraction > 0.075

	local maxHealth = self.m_BaseHealth

	if tr.Fraction > 0.1 then
		maxHealth = maxHealth / (tr.Fraction * 10)
	end

	-- Make all props weaker as more props are spawned
	-- I've no idea how this particular formula was came up with but I figure it
	-- was probably vaguely sensible
	-- TODO: Figure out how to cache this, we really don't need to recalculate
	-- the prop count for every prop!
	local propCount = #ents.FindByClass("ose_prop")
	local adjustment = (propCount / 3) * (maxHealth / 320)
	maxHealth = maxHealth - adjustment

	-- Minimum health regardless
	if maxHealth < 50 then
		maxHealth = 50
	end
	self:SetMaxHealth(maxHealth)
	self:SetHealth(maxHealth)

	-- The bullseye needs to be visible on the outside of the prop, but it
	-- doesn't seem to matter exactly where it's visible, so this picks the
	-- centre of an arbitrary side
	local centre = self:OBBCenter()
	local maxs = self:OBBMaxs()
	local bullPos = Vector(maxs.x, centre.y, centre.z)

	local bull = ents.Create("npc_bullseye")
	bull:SetPos(self:LocalToWorld(bullPos))
	bull:SetParent(self)
	bull:SetKeyValue(
		"spawnflags",
		tostring(
		-- "Not Solid"
			65536
			-- "Take No Damage"
			+ 131072
			-- "Perfect Accuracy "
			+ 1048576
		)
	)
	if isInSky then
		bull:SetName("ose_be_sky")
	else
		bull:SetName("ose_be_gnd")
	end

	bull:Spawn()
	bull:Activate()
	-- "this should never happen"
	if IsValid(self.m_BullsEye) then
		self.m_BullsEye:Remove()
	end
	self.m_BullsEye = bull
end

function ENT:_OnBuildPhase(roundNum)
	self:Extinguish()
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:GetPhysicsObject():EnableMotion(false)
	-- This shouldn't matter, but just in case I guess
	self:SetHealth(self:GetMaxHealth())
	if IsValid(self.m_BullsEye) then
		self.m_BullsEye:Remove()
	end
end

function ENT:OnRemove()
	if IsValid(self.m_BullsEye) then
		self.m_BullsEye:Remove()
	end
end

ENT.m_CachedPlayerBonus = 1
ENT.m_NextPlayerCountUpdate = 0

--- Returns a damage scale reduction bonus depending on the number of nearby
--- players - if there's two or more then we massively reduce the damage to
--- promote players hanging out together
--- @return number
function ENT:GetPlayerNearbyBonus()
	local now = CurTime()
	if self.m_NextPlayerCountUpdate <= now then
		local count = 0
		for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 300)) do
			if ent:IsPlayer() then
				count = count + 1
			end
		end
		if count > 1 then
			self.m_CachedPlayerBonus = 1 / count
		else
			self.m_CachedPlayerBonus = 1
		end
	end

	return self.m_CachedPlayerBonus
end

function ENT:OnTakeDamage(dmginfo)
	local attacker = dmginfo:GetAttacker()
	-- TODO: Turrets, mines
	if IsValid(attacker) and attacker:IsPlayer() then
		return 0
	end

	-- Scale prop damage down for shotguns
	local weapon = NULL
	local inflictor = dmginfo:GetInflictor()
	if IsValid(inflictor) then
		-- The infilctor seems to always be the attacker, even when it should be
		-- the attacker's weapon:
		-- https://github.com/Facepunch/garrysmod-issues/issues/6150
		if inflictor:IsWeapon() then
			weapon = inflictor
		elseif inflictor:IsNPC() then
			--- @cast inflictor GNPC
			weapon = inflictor:GetActiveWeapon()
		end
	end
	if IsValid(weapon) and weapon:GetClass() == "weapon_shotgun" then
		dmginfo:ScaleDamage(0.5)
	end

	dmginfo:ScaleDamage(self:GetPlayerNearbyBonus())

	local damage = dmginfo:GetDamage()
	local newHealth = self:Health() - dmginfo:GetDamage()
	self:SetHealth(newHealth)

	if newHealth <= 0 then
		self:Die()
	elseif cvarFlammible:GetBool() and (newHealth / self:GetMaxHealth()) <= 0.4 then
		self:Ignite(8, 150)
	end

	-- Return the amount of damage we took for the hooks
	return damage
end

function ENT:Die()
	self:RemovePretty()
end

function ENT:RemovePretty()
	--- @type GEntity
	local dissolver = ents.FindByName("ose_dissolve_propdeath")[1]
	if IsValid(dissolver) then
		dissolver:Fire("Dissolve", self:GetName())
	else
		self:Remove()
	end
end

function ENT:OnHitNobuild()
	--- @type GEntity
	local dissolver = ents.FindByName("ose_dissolve_nobuild")[1]
	if IsValid(dissolver) then
		dissolver:Fire("Dissolve", self:GetName())
	else
		self:Remove()
	end
end

function ENT:Touch(ent)
	if ent:GetClass() == "func_nobuild" then
		self:OnHitNobuild()
	end
end
