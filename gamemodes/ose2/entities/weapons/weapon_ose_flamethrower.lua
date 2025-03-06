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

--- @class SWEP_OSEFlamethrower : SSWEP
--- @field SetActive fun(self, active: boolean)
--- @field GetActive fun(self): boolean
local SWEP = SWEP --[[@as SWEP_OSEFlamethrower]]
--- @type SSWEP
local BaseClass
DEFINE_BASECLASS("weapon_base")

local ACTIVE_SPEED = 450 / 2

function SWEP:PrimaryAttack()
	-- TODO
end

function SWEP:Think()
	if not self:IsActive() then
		return
	end
	local owner = self:GetOwner() --[[@as GPlayer]]
	if not IsValid(owner) then
		return
	end
end

--- Returns if the flamer is flaming
--- @return boolean
function SWEP:IsActive()
	return self:GetActive()
end

function SWEP:CanBePickedUpByNPCs() return false end

function SWEP:Holster()
	self:SetActive(false)
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
