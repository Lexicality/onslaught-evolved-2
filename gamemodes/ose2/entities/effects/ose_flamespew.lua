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

--- @class EFF_OSEFlameSpew : SEFFECT
--- @field m_Emitter GCLuaEmitter
--- @field m_Owner GPlayer | GNPC
--- @field m_Weapon SWEP_OSEFlamethrower
--- @field m_Attachment integer
local EFFECT = EFFECT --[[@as EFF_OSEFlameSpew]]

-- How often to fire new flame particles
local FRAME_RATE = 1 / 30

function EFFECT:Init(data)
	self.m_Attachment = data:GetAttachment()
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
	-- TODO: What is a 3d particle emitter? Do we want that?
	local emitter = ParticleEmitter(self:GetPos(), false)
	self.m_Emitter = emitter
	-- TODO: Is this secretly an option?
	-- self.m_Emitter:SetParent(ent)
	self:CallOnRemove("Parti-be-gone", function()
		emitter:Finish()
	end)
end

function EFFECT:Think()
	local wep = self.m_Weapon
	local owner = self.m_Owner
	if not (
			IsValid(wep)
			and IsValid(owner)
			and owner:GetActiveWeapon() == wep
			and wep:IsActive()
		)
	then
		return false
	end
	-- local now = CurTime()
	-- TODO ?? client think or next think wat
	self:SetNextClientThink(FRAME_RATE)

	local pos = self:GetTracerShootPos(owner:GetShootPos(), wep, self.m_Attachment)
	local aim = owner:GetAimVector()
	local emitter = self.m_Emitter
	local plyVelocity = owner:GetVelocity()

	-- TODO: Copied directly from the orignial onslaught flamer and I'm not a huge fan
	for i = 0, 20 do
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
	for i = 0, 2 do
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
	return true
end
