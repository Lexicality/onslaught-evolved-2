--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- @class EFF_OSEFlameSpew : SEFFECT
--- @field m_Emitter GCLuaEmitter
--- @field m_Owner GPlayer | GNPC
--- @field m_Weapon SWEP_OSEFlamethrower
--- @field m_Attachment integer
--- @field m_DieTime number
local EFFECT = EFFECT --[[@as EFF_OSEFlameSpew]]

-- How often to fire new flame particles
local FRAME_RATE = 1 / 60
-- Must match FIRE_FREQUENCY in the flamethrower!
local ALIVE_TIME = 0.25

function EFFECT:Init(data)
	self.m_Attachment = data:GetAttachment()
	-- self.m_DieTime = CurTime() + ALIVE_TIME
	local ent = data:GetEntity()
	if not (IsValid(ent) and ent:IsWeapon()) then
		ErrorNoHalt("ose_flamespew not given a weapon??? " .. ent)
		self:Remove()
		return
	end
	--- @cast ent SWEP_OSEFlamethrower
	self.m_Weapon = ent
	local owner = ent:GetOwner()
	if not (IsValid(owner) and (owner:IsNPC() or owner:IsPlayer())) then
		ErrorNoHalt("ose_flamespew's weapon has invalid owner " .. owner)
		self:Remove()
		return
	end
	self.m_Owner = owner --[[@as GNPC]]
	-- Put us somewhere sensible and stick us to the gun in case the player moves about while shooting
	self:SetPos(ent:GetPos())
	self:SetParent(ent, self.m_Attachment)
	local emitter = ParticleEmitter(self:GetPos(), false)
	self.m_Emitter = emitter
	self:CallOnRemove("Parti-be-gone", function()
		emitter:Finish()
	end)
end

function EFFECT:Think()
	local now = CurTime()
	if self.m_DieTime and self.m_DieTime < now then
		return false
	end
	local wep = self.m_Weapon
	local owner = self.m_Owner
	if not (
			IsValid(wep)
			and IsValid(owner)
			and owner:GetActiveWeapon() == wep
		)
	then
		return false
	end
	self:SetNextClientThink(now + FRAME_RATE)

	if not self.m_DieTime and not wep:IsActive() then
		self.m_DieTime = now + ALIVE_TIME
	end

	local pos = self:GetTracerShootPos(owner:GetShootPos(), wep, self.m_Attachment)
	local aim = owner:GetAimVector()

	if self.m_DieTime then
		self:_DyingParticles(owner, pos, aim)
	else
		self:_LiveParticles(owner, pos, aim)
	end

	return true
end

--- Fires an active stream of deadly particles
--- @param owner GNPC|GPlayer
--- @param pos GVector
--- @param aim GVector
function EFFECT:_LiveParticles(owner, pos, aim)
	local emitter = self.m_Emitter
	local plyVelocity = owner:GetVelocity()
	-- TODO: This eats 30 fps, can we make it more efficient?
	for _ = 0, 20 do
		local p = emitter:Add("particles/flamelet" .. math.random(1, 5),
			(pos + aim * 5))
		local vel = (
			aim * math.random(500, 600)
			+ plyVelocity
			-- spread it out a bit
			+ VectorRand(-25, 25)
		)
		p:SetVelocity(vel)
		p:SetDieTime(math.Rand(.5, .8))
		p:SetGravity(Vector(0, 0, -1))
		p:SetStartSize(math.Rand(0.5, 1))
		p:SetEndSize(9)
		p:SetStartAlpha(math.Rand(200, 255))
		p:SetAirResistance(10)
		p:SetEndAlpha(0)
	end
	for _ = 0, 2 do
		local p = emitter:Add("particles/flamelet" .. math.random(1, 5), pos)
		local vel = aim * 450 + plyVelocity
		p:SetVelocity(vel)
		p:SetDieTime(math.Rand(.1, .2))
		p:SetGravity(Vector(0, 0, -5))
		p:SetStartSize(math.Rand(0.5, 1))
		p:SetEndSize(1)
		p:SetStartAlpha(math.Rand(200, 255))
		p:SetAirResistance(10)
		p:SetEndAlpha(0)
		p:SetColor(100, 100, 255)
	end
	if math.random(1, 5) >= 4 then
		local p = emitter:Add("sprites/heatwave", (pos + aim * 5))
		local vel = (
			aim * math.random(440, 460)
			+ plyVelocity
			--spread it out a bit
			+ VectorRand(-25, 25)
		)
		p:SetVelocity(vel)
		p:SetDieTime(math.Rand(.5, .8))
		p:SetGravity(Vector(0, 0, -1))
		p:SetStartSize(math.Rand(5, 6))
		p:SetEndSize(10)
		p:SetStartAlpha(math.Rand(200, 255))
		p:SetAirResistance(10)
		p:SetEndAlpha(0)
	end
	if math.random(1, 5) == 1 then
		local p = emitter:Add("particle/smokesprites_000" .. math.random(1, 6),
			pos + aim)
		local vel = aim * 5 + plyVelocity + VectorRand(-5, 5) --spread it out a bit
		p:SetVelocity(vel)
		p:SetDieTime(math.Rand(.5, .8))
		p:SetGravity(Vector(0, 0, 2))
		p:SetStartSize(math.Rand(0.8, 1.2))
		p:SetEndSize(3)
		p:SetStartAlpha(math.Rand(150, 200))
		p:SetAirResistance(10)
		p:SetEndAlpha(0)
		p:SetColor(50, 50, 50)
	end
end

--- Dribbles particles as the flamer turns off
--- @param owner GNPC|GPlayer
--- @param pos GVector
--- @param aim GVector
function EFFECT:_DyingParticles(owner, pos, aim)
	local emitter = self.m_Emitter
	local plyVelocity = owner:GetVelocity()
	-- Low velocity high gravity flame dribbles
	for _ = 0, 10 do
		local p = emitter:Add("particles/flamelet" .. math.random(1, 5), pos)
		local vel = (
			aim * math.random(10, 15)
			+ plyVelocity
			-- spread it out a bit
			+ VectorRand(-5, 5)
		)
		p:SetVelocity(vel)
		p:SetDieTime(math.Rand(.5, .8))
		p:SetGravity(Vector(0, 0, -50))
		p:SetStartSize(0.5)
		p:SetEndSize(0.5)
		p:SetStartAlpha(math.Rand(200, 255))
		p:SetAirResistance(1)
		p:SetEndAlpha(0)
	end
	-- Unhappy smoke particles
	for _ = 0, 3 do
		local p = emitter:Add("particle/smokesprites_000" .. math.random(1, 6),
			pos + aim)
		local vel = aim * 5 + plyVelocity + VectorRand(-5, 5)
		p:SetVelocity(vel)
		p:SetDieTime(math.Rand(.5, .8))
		p:SetGravity(Vector(0, 0, 20))
		p:SetStartSize(math.Rand(0.8, 1.2))
		p:SetEndSize(3)
		p:SetStartAlpha(math.Rand(150, 200))
		p:SetAirResistance(10)
		p:SetEndAlpha(0)
		p:SetColor(50, 50, 50)
	end
end

function EFFECT:Render()
end
