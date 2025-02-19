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



local STATE_CLOSED = 0
local STATE_OPENING = 1
local STATE_OPEN = 2
local STATE_CLOSING = 3

--- @alias OSEAmmoCrateOpenState `STATE_CLOSED` | `STATE_OPENING` | `STATE_OPEN` | `STATE_CLOSING`

--- @class SENT_OSEAmmoCrate : SENT_OSEProp
--- @field SetOpenState fun(self, state: OSEAmmoCrateOpenState)
--- @field GetOpenState fun(self): OSEAmmoCrateOpenState
--- @field m_CloseSequence integer
--- @field m_IdleSequence integer
--- @field m_NextClose number
--- @field m_OpenSequence integer
--- @field m_Users GPlayer[]
local ENT = ENT --[[@as SENT_OSEAmmoCrate]]
--- @type SENT_OSEProp
local BaseClass
DEFINE_BASECLASS("ose_prop")

local CRATE_MODEL = Model("models/items/ammocrate_smg1.mdl")
local OPEN_SOUND = Sound("AmmoCrate.Open")
local CLOSE_SOUND = Sound("AmmoCrate.Close")
local AMMO_CRATE_CLOSE_DELAY = 1.5

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetworkVar("Int", 0, "OpenState")
end

-- From mucking about, it seems like the eyetrace used for the use hook is about
-- 97 units which is a weirdly specific number (maybe it means something in
-- inches?) but that uses vphysics traces which are expensive to calculate.
-- The furthest pos-to-pos distance I've been able to get is 114 units, so slap
-- a bit of padding on there and hope for the best
local CLOSE_RADIUS = math.pow(120, 2)


--- @param ply GPlayer # The player to check
--- @param strict? boolean # If we should enforce strict line-of-sight
--- @param _pos? GVector # INTERNAL
--- @return boolean
function ENT:CanPlayerUseMe(ply, strict, _pos)
	local here = _pos or self:GetPos()
	return IsValid(ply)
		and ply:Alive()
		and (not strict or ply:GetEyeTrace().Entity == self)
		and ply:GetPos():DistToSqr(here) <= CLOSE_RADIUS
end

if CLIENT then return end

function ENT:Initialize()
	self:SetModel(CRATE_MODEL)
	-- For whatever reason the crate defaults to half empty, so we need to
	-- switch body groups to put all the ammo back in it
	self:SetBodygroup(1, 1)
	self:SetUseType(SIMPLE_USE)
	self.m_OpenSequence = self:LookupSequence("Open")
	self.m_CloseSequence = self:LookupSequence("Close")
	self.m_IdleSequence = self:LookupSequence("Idle")
	self.m_Users = {}
	BaseClass.Initialize(self)
end

function ENT:Use(activator)
	if not IsValid(activator) or not activator:IsPlayer() then
		return
	end
	local ply = activator --[[@as GPlayer]]
	if not hook.Run("PlayerOpenAmmoCrate", ply, self) then
		-- The hook will presumably notify them as to why not
		-- TODO: Locked sound effect maybe?
		return
	end
	-- Reset the next close time
	self.m_NextClose = 0
	self.m_Users[#self.m_Users + 1] = ply
	local state = self:GetOpenState()
	if state == STATE_OPENING then
		-- We're already swinging open, nothing to do
		return
	elseif state == STATE_OPEN then
		-- Since we're already open the player can immediately start using the menu
		hook.Run("PlayerOpenedAmmoCrate", ply, self)
		return
	end
	-- Time to open!
	self:SetOpenState(STATE_OPENING)
	self:ResetSequence(self.m_OpenSequence)
	self:EmitSound(OPEN_SOUND)
end

--- Ensures everyone we think is still using us is actually still using us
--- @param strict? boolean
--- @param plyToRemove? GPlayer
function ENT:PruneUsers(strict, plyToRemove)
	local remaining = {}
	local here = self:GetPos()
	for _, ply in ipairs(self.m_Users) do
		if ply ~= plyToRemove and self:CanPlayerUseMe(ply, strict, here) then
			remaining[#remaining + 1] = ply
		end
	end
	self.m_Users = remaining
end

function ENT:Think()
	local state = self:GetOpenState()
	if state == STATE_CLOSED then
		-- Shut boxes do nothing
		return
	elseif state ~= STATE_OPEN then
		-- We're currently opening or closing
		-- Gotta do our own animations here smh
		self:FrameAdvance()
		if not self:IsSequenceFinished() then
			-- If we've not finished animating, we continue to wait
			return
		elseif state == STATE_OPENING then
			-- If we've just finished opening, then open the ammo panel for the
			-- user(s) who opened us
			self:SetOpenState(STATE_OPEN)
			self:PruneUsers(true)
			-- This will almost certainly always be one user, so no need to
			-- optimise for 10 people all hitting use on the same crate
			-- simultaneously
			for _, ply in ipairs(self.m_Users) do
				hook.Run("PlayerOpenedAmmoCrate", ply, self)
			end
		else
			-- Otherwise we're shut and can play the idle animation
			-- (Sitting there completely stationary like a big metal box)
			self:SetOpenState(STATE_CLOSED)
			self:ResetSequence(self.m_IdleSequence)
			-- Make a loud thunk noise
			self:EmitSound(CLOSE_SOUND)
		end
		return
	end
	-- We are currently open, figure out if we should shut because we're no longer in use
	self:PruneUsers()
	if #self.m_Users > 0 then
		return
	end
	local now = CurTime()
	-- Stay open for a second or two after the last person finishes using us
	if self.m_NextClose == 0 then
		self.m_NextClose = now + AMMO_CRATE_CLOSE_DELAY
	elseif self.m_NextClose <= now then
		self:SetOpenState(STATE_CLOSING)
		self:ResetSequence(self.m_CloseSequence)
	end
end

--- Checks if a player is a valid user of this entity
--- @param ply GPlayer
--- @return boolean
function ENT:IsPlayerUsingMe(ply)
	return (
		self:GetOpenState() == STATE_OPEN
		and table.Find(self.m_Users, ply) ~= nil
	)
end

--- @param ply GPlayer
function ENT:OnPlayerFinished(ply)
	self:PruneUsers(false, ply)
end
