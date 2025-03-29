--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

AddCSLuaFile()

--- @class SWEP_OSEFlamethrower : SSWEP
--- @field SetActive fun(self, active: boolean)
--- @field GetActive fun(self): boolean
--- @field m_FireLoop number|nil
--- @field m_GasLoop number|nil
local SWEP = SWEP --[[@as SWEP_OSEFlamethrower]]
--- @type SSWEP
local BaseClass
DEFINE_BASECLASS("weapon_base")

SWEP.PrintName = "#weapon_ose_flamethrower"
SWEP.DrawWeaponInfoBox = false -- TODO!
SWEP.DrawAmmo = true

-- TODO: Icon
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_smg1.mdl")
SWEP.WorldModel = Model("models/weapons/w_smg1.mdl")
SWEP.Slot = 3

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "FlamerFuel"

SWEP.Secondary.Ammo = "none"

do
	sound.Add({
		sound = "ambient/fire/fire_big_loop1.wav",
		name = "OSEFlamethrower.Fire",
		channel = CHAN_WEAPON,
		volume = 1,
		level = SNDLVL_GUNFIRE,
	})
	sound.Add({
		sound = "ambient/gas/steam2.wav",
		name = "OSEFlamethrower.Gas",
		channel = CHAN_STATIC,
		volume = 0.5,
		level = SNDLVL_GUNFIRE,
	})
end
-- -- sound.Add()

local SOUND_FIRE = Sound("OSEFlamethrower.Fire")
local SOUND_GAS = Sound("OSEFlamethrower.Gas")
local SOUND_STOP = Sound("k_lab.eyescanner_click")

local ACTIVE_SPEED = 450 / 2
local FIRE_FREQUENCY = 0.25
local IGNITE_THRESHHOLD = 1 / 3
local IGNITE_LENGTH = 10
local IGNITE_RADIUS = 40
local CONE_ANGLE = math.cos(math.rad(10))

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Active")
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end

	self:SetNextPrimaryFire(CurTime() + FIRE_FREQUENCY)

	if not IsFirstTimePredicted() then
		return
	end

	if not self:IsActive() then
		self:SetActive(true)
		local ed = EffectData()
		ed:SetAttachment(1)
		ed:SetEntity(self)
		util.Effect("ose_flamespew", ed)
	end

	self:TakePrimaryAmmo(1)

	if self.m_FireLoop == nil then
		self.m_FireLoop = self:StartLoopingSound(SOUND_FIRE)
	end
	if self.m_GasLoop == nil then
		self.m_GasLoop = self:StartLoopingSound(SOUND_GAS)
	end

	if not SERVER then
		return
	end

	local owner = self:GetOwner() --[[@as GPlayer]]
	local start = owner:GetShootPos()
	local dir = owner:GetAimVector()
	local fireDamage = DamageInfo()
	fireDamage:SetInflictor(self)
	fireDamage:SetAttacker(owner)
	fireDamage:SetDamage(5)
	fireDamage:SetDamageType(DMG_BURN)
	fireDamage:SetReportedPosition(start)
	for _, ent in ipairs(ents.FindInCone(start, dir, 400, CONE_ANGLE)) do
		if ent:IsNPC() and not IsValid(ent._oseSpawner) then
			if not ent:IsOnFire() then
				ent._oseIgniter = owner
				ent:TakeDamageInfo(fireDamage)
				if (ent:Health() / ent:GetMaxHealth()) < IGNITE_THRESHHOLD then
					ent:Ignite(IGNITE_LENGTH, IGNITE_RADIUS)
				end
			end
		end
	end
end

function SWEP:CanPrimaryAttack()
	if self:Clip1() > 0 then
		return true
	end

	if self:IsActive() then
		self:Stop()
	else
		self:EmitSound(SOUND_STOP)
		self:SetNextPrimaryFire(CurTime() + 0.2)
	end

	self:Reload()
end

function SWEP:Think()
	if CLIENT or not self:IsActive() then
		return
	elseif not self:CanPrimaryAttack() then
		-- That method handles everything
		return
	end
	-- "This hook only runs while the weapon is in players hands.
	-- It does not run while it is carried by an NPC."
	local owner = self:GetOwner() --[[@as GPlayer]]
	if owner:KeyDown(IN_ATTACK) then
		return
	end
	self:Stop()
end

function SWEP:Stop()
	if self.m_FireLoop ~= nil then
		self:StopLoopingSound(self.m_FireLoop)
		self.m_FireLoop = nil
	end
	if self.m_GasLoop ~= nil then
		self:StopLoopingSound(self.m_GasLoop)
		self.m_GasLoop = nil
	end
	self:EmitSound(SOUND_STOP)
	self:SetActive(false)
	-- Don't let the player start firing again for half a second
	self:SetNextPrimaryFire(CurTime() + 0.5)
end

--- Returns if the flamer is flaming
--- @return boolean
function SWEP:IsActive()
	return self:GetActive()
end

function SWEP:CanBePickedUpByNPCs() return false end

function SWEP:Deploy()
	self:SetActive(false)
	return true
end

function SWEP:Holster()
	self:Stop()
	return true
end

function SWEP:OnRemove()
	if self.m_FireLoop ~= nil then
		self:StopLoopingSound(self.m_FireLoop)
	end
	if self.m_GasLoop ~= nil then
		self:StopLoopingSound(self.m_GasLoop)
	end
end

function SWEP:SecondaryAttack() end

--- Slows players down massively when they're flaming
--- @param ply GPlayer
--- @param move GCMoveData
--- @param cmd GCUserCmd
local function onSetupMove(ply, move, cmd)
	local wep = ply:GetActiveWeapon()
	if not (IsValid(wep) and wep:GetClass() == "weapon_ose_flamethrower") then
		return
	end
	--- @cast wep SWEP_OSEFlamethrower
	if wep:IsActive() then
		move:SetMaxClientSpeed(ACTIVE_SPEED)
	end
end
hook.Add("SetupMove", "OSE Flamethrower Slowdown", onSetupMove)
