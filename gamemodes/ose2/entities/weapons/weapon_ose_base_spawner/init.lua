--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

--- @class SWEP_OSEBaseSpawner : SSWEP
local SWEP = SWEP --[[@as SWEP_OSEBaseSpawner]]
--- @type SSWEP
local BaseClass
DEFINE_BASECLASS("weapon_base")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.RefireTime)
	self:ShootEffects()

	if IsFirstTimePredicted() then
		local owner = self:GetOwner()
		--- @cast owner GPlayer
		owner:ConCommand("ose_spawnent " .. self.EntityClass)
	end
end

function SWEP:CanBePickedUpByNPCs()
	return false
end
