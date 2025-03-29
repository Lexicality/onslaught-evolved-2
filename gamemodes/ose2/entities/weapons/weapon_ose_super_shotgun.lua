--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

AddCSLuaFile()

--- @class SWEP_OSESuperShotgun : SSWEP
--- @field m_NeedPump boolean If the weapon should pump after the animation finishes
--- @field m_Reloading boolean If we're mid-reload
--- @field m_DelayedFire1 boolean If the player tried to primary fire while reloading
--- @field m_DelayedFire2 boolean If the player tried to secondary fire while reloading
--- @field m_DelayedReload boolean If the player tried to reload while waiting for the pump
local SWEP = SWEP --[[@as SWEP_OSESuperShotgun]]
--- @type SSWEP
local BaseClass
DEFINE_BASECLASS("weapon_base")

SWEP.PrintName = "#weapon_ose_super_shotgun"
SWEP.DrawWeaponInfoBox = false -- TODO!

-- TODO: Icon
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_shotgun.mdl")
SWEP.WorldModel = Model("models/weapons/w_shotgun.mdl")
SWEP.Slot = 3

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "HeavyBuckshot"
SWEP.Primary.FireSound = Sound("Weapon_Shotgun.Single")
SWEP.Primary.EmptySound = Sound("Weapon_Shotgun.Empty")

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.Secondary.FireSound = Sound("Weapon_Shotgun.Double")
SWEP.Secondary.EmptySound = Sound("Weapon_Shotgun.Empty")

local SOUND_PUMP = Sound("Weapon_Shotgun.Special1")
local SOUND_RELOAD = Sound("Weapon_Shotgun.Reload")


function SWEP:Initialize()
	self:SetWeaponHoldType("shotgun")
	self.m_NeedPump = false
	self.m_Reloading = false
end

local VIEWPUNCH = Angle(-10, 0, 0)

function SWEP:ShootEffects()
	BaseClass.ShootEffects(self)
	local owner = self:GetOwner()
	if owner:IsPlayer() then
		--- @cast owner GPlayer
		owner:ViewPunch(VIEWPUNCH)
	end
end

function SWEP:_SetNextFire()
	local nextFire = CurTime() + self:SequenceDuration()
	self:SetNextPrimaryFire(nextFire)
	self:SetNextSecondaryFire(nextFire)
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end

	self:ShootBullet(10, 10, 0.015)
	self:EmitSound(self.Primary.FireSound)
	self:TakePrimaryAmmo(1)
	self:_SetNextFire()

	if self:Clip1() > 0 then
		self.m_NeedPump = true
	else
		self.m_DelayedReload = true
	end
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then
		return
	end

	self:ShootBullet(10, 30, 0.03)
	self:EmitSound(self.Secondary.FireSound)
	self:TakePrimaryAmmo(4)
	self:_SetNextFire()

	-- Yeet!
	if SERVER and IsFirstTimePredicted() then
		local owner = self:GetOwner()
		--- @cast owner GPlayer
		-- TODO: This seems like a genuinely crazy amount of force, you can
		-- cross the map instantly with a single shot!
		owner:SetVelocity(owner:GetAimVector() * -600)
	end

	if self:Clip1() > 0 then
		self.m_NeedPump = true
	else
		self.m_DelayedReload = true
	end
end

function SWEP:CanPrimaryAttack()
	if self.m_Reloading or self.m_NeedPump then
		-- This should never happen, but lag might get in the way - the next
		-- frame *should* clear this state
		DebugInfo(0, "ERROR: Shotgun think hook desynced?")
		return false
	elseif self:Clip1() >= 1 then
		return true
	end

	self:EmitSound(self.Primary.EmptySound)
	self:Reload()
	return false
end

function SWEP:CanSecondaryAttack()
	if self.m_Reloading or self.m_NeedPump then
		-- This should never happen, but lag might get in the way - the next
		-- frame *should* clear this state
		DebugInfo(0, "ERROR: Shotgun think hook desynced?")
		return false
	elseif self:Clip1() >= 4 then
		return true
	end

	self:EmitSound(self.Primary.EmptySound)
	self:Reload()
	return false
end

function SWEP:Think()
	-- The hl2mp shotgun synchronises everything with the primary fire timer
	-- so let's do that too
	local next = self:GetNextPrimaryFire()
	local now = CurTime()
	local owner = self:GetOwner()
	--- @cast owner GPlayer
	if not owner:IsPlayer() then
		---@diagnostic disable-next-line: cast-local-type
		owner = nil
	end

	if self.m_Reloading then
		local clip = self:Clip1()
		if next <= now then
			if
				self:Ammo1() <= 0
				or clip >= self:GetMaxClip1()
				or self.m_DelayedFire1
				or self.m_DelayedFire2
			then
				self:_EndReload()
			else
				self:_ReloadOne()
			end
			return
		elseif owner and owner:KeyDown(IN_ATTACK) and clip >= 1 then
			self.m_DelayedFire1 = true
			self.m_DelayedFire2 = false
		elseif owner and owner:KeyDown(IN_ATTACK2) and clip >= 4 then
			self.m_DelayedFire1 = false
			self.m_DelayedFire2 = true
		end
	end

	if self.m_NeedPump then
		if next <= now then
			self:_Pump()
		end
		return
	end

	if next <= now then
		if self.m_DelayedReload then
			self.m_DelayedReload = false
			self:Reload()
		elseif self.m_DelayedFire1 then
			self.m_DelayedFire1 = false
			self.m_DelayedFire2 = false
			self:PrimaryAttack()
		elseif self.m_DelayedFire2 then
			self.m_DelayedFire1 = false
			self.m_DelayedFire2 = false
			self:SecondaryAttack()
		end
	end
end

function SWEP:_Pump()
	self:EmitSound(SOUND_PUMP)
	self:SendWeaponAnim(ACT_SHOTGUN_PUMP)
	self:_SetNextFire()
	self.m_NeedPump = false
end

function SWEP:Reload()
	if self.m_Reloading then
		return
	elseif self.m_NeedPump or self:GetNextPrimaryFire() > CurTime() then
		self.m_DelayedReload = true
		return
	elseif self:Clip1() >= self:GetMaxClip1() then
		return
	elseif self:Ammo1() <= 0 then
		self:SendWeaponAnim(ACT_VM_DRYFIRE)
		self:_SetNextFire()
		return
	end
	self:_StartReload()
end

function SWEP:_StartReload()
	self.m_Reloading = true
	-- Gotta do a pump if you've emptied the tube
	if self:Clip1() <= 0 then
		self.m_NeedPump = true
	end
	-- ??
	self:SetBodygroup(1, 0)

	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
	self:_SetNextFire()
end

function SWEP:_ReloadOne()
	self:EmitSound(SOUND_RELOAD)
	self:SendWeaponAnim(ACT_VM_RELOAD)
	self:_SetNextFire()

	self:SetClip1(self:Clip1() + 1)
	local owner = self:GetOwner()
	if owner:IsPlayer() then
		--- @cast owner GPlayer
		owner:RemoveAmmo(1, self.Primary.Ammo)
	end
end

function SWEP:_EndReload()
	self:SetBodygroup(1, 1)
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	self:_SetNextFire()
	self.m_Reloading = false
end
