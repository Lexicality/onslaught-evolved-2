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

AddCSLuaFile("cl_init.lua")
include("shared.lua")

--- @class SENT_OSEHealthCharger : SENT_OSEProp
--- @field m_CurrentUser GPlayer # The player currently using the dispenser
--- @field m_Looping boolean # If we've started looping yet
--- @field m_NextHealth number # When the user should be given their next point of HP
--- @field m_NextSound number # When it's safe to play another sound without stepping on anything
--- @field m_TotalHealthRestored integer # How much health we've given out
local ENT = ENT --[[@as SENT_OSEHealthCharger]]
--- @type SENT_OSEProp
local BaseClass
DEFINE_BASECLASS("ose_prop")

ENT.m_NextSound = 0

-- Copied from the hl2 source
local DENY_SOUND_LENGTH = 0.62
local START_SOUND_LENGTH = 0.56
local DEACTIVATE_THINK_TIME = 0.25

-- These should probably be cvars
local HEALTH_PER_SECOND = 10 -- (hl2 does 10 per second, but we may want to tune this)
local HEALING_REWARD = 100

local HEALING_RATE = 1 / HEALTH_PER_SECOND

function ENT:Initialize()
	self:SetModel(self._model)
	BaseClass.Initialize(self)
	self:SetUseType(CONTINUOUS_USE)
	self.m_TotalHealthRestored = 0
	self.m_NextHealth = 0
end

function ENT:Use(activator, caller, useType, value)
	if not IsValid(activator) or not activator:IsPlayer() then
		return
	end
	local ply = activator --[[@as GPlayer]]
	local now = CurTime()
	-- Only one player at a time please
	if self:IsActive() and self.m_CurrentUser ~= ply then
		if self.m_NextSound <= now then
			self.m_NextSound = now + DENY_SOUND_LENGTH
			-- Notify the player (but no one else) that they can't use a health charger someone else is using
			local filter = RecipientFilter(true)
			filter:AddPlayer(ply)
			self:EmitSound(
				self._denySound,
				nil,
				nil,
				nil,
				nil,
				nil,
				nil,
				filter
			)
		end
		return
	end
	local health = ply:Health()
	if health >= ply:GetMaxHealth() then
		self:EmitSound(self._denySound)
		-- "Make the user re-use me to get started drawing health."
		self:SetUseType(SIMPLE_USE)
		if self:IsActive() then
			self:_Deactivate()
		end
		return
	elseif not self:IsActive() then
		-- We might have changed use type a few lines above, so switch back to
		-- continuous use. Turns out you can do this mid-use!
		self:SetUseType(CONTINUOUS_USE)

		self:SetActive(true)
		self.m_CurrentUser = ply
		self.m_Looping = false
		self:EmitSound(self._startSound)
		self.m_NextSound = now + START_SOUND_LENGTH
	elseif not self.m_Looping and self.m_NextSound <= now then
		self.m_Looping = true
		self:StartLoopingSound(self._chargeSound)
	end

	-- Keep pushing the next think back and back and back while the player is
	-- successfully using the entity
	self:NextThink(now + DEACTIVATE_THINK_TIME)

	if self.m_NextHealth <= now then
		ply:SetHealth(health + 1)
		self.m_NextHealth = now + HEALING_RATE
	end

	self.m_TotalHealthRestored = self.m_TotalHealthRestored + 1
	if self.m_TotalHealthRestored % 50 == 0 then
		local owner = self:GetCreator()
		if IsValid(owner) then
			owner:AddMoney(HEALING_REWARD, "ose.money.reason.health_charger")
		end
	end
end

function ENT:_Deactivate()
	self:SetActive(false)
	self:StopSound(self._chargeSound)
	---@diagnostic disable-next-line: assign-type-mismatch
	self.m_CurrentUser = NULL
end

function ENT:Think()
	if self:IsActive() then
		self:_Deactivate()
	end
	-- Don't need to think about anything for a while
	self:NextThink(CurTime() + 10)
	return true
end

function ENT:Remove()
	-- TODO: Why doesn't this actually stop the looping sound on remove????
	self:StopSound(self._chargeSound)
end
