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

--- @class SWEP_OSEBaseSpawner : SSWEP
local SWEP = SWEP --[[@as SWEP_OSEBaseSpawner]]
--- @type SSWEP
local BaseClass
DEFINE_BASECLASS("weapon_base")

SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_toolgun.mdl")
SWEP.WorldModel = Model("models/weapons/w_toolgun.mdl")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.RefireTime = 1

--- The entity for the user to spawn, eg `ose_mine`
SWEP.EntityClass = "error"

SOUND_SHOOT = Sound("Airboat.FireGunRevDown")

function SWEP:SecondaryAttack()
	-- Nothing
end

function SWEP:ShootEffects()
	local owner = self:GetOwner()
	--- @cast owner GPlayer

	self:EmitSound(SOUND_SHOOT)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- View model animation
	owner:SetAnimation(PLAYER_ATTACK1)     -- 3rd Person Animation

	if IsFirstTimePredicted() then
		local tr = owner:GetEyeTrace()
		local effect_tr = EffectData()
		effect_tr:SetOrigin(tr.HitPos)
		effect_tr:SetStart(tr.StartPos)
		effect_tr:SetAttachment(1)
		effect_tr:SetEntity(self)
		util.Effect("ToolTracer", effect_tr)
	end
end
