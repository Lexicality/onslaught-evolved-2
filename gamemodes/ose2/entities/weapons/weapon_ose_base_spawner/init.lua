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
