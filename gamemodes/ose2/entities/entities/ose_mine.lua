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

--- @class SENT_OSEMine : SENT_OSEProp
--- @field m_Mine GEntity | nil
local ENT = ENT --[[@as SENT_OSEMine]]
--- @type SENT_OSEProp
local BaseClass
DEFINE_BASECLASS("ose_prop")

local MINE_MODEL = Model("models/props_combine/combine_mine01.mdl")
-- the citizen modified skins for the mine (inclusive):
local MINE_CITIZEN_SKIN_MIN = 1
local MINE_CITIZEN_SKIN_MAX = 2
local BOUNCEBOMB_HOOK_RANGE = 64


function ENT:Initialize()
	self:SetModel(MINE_MODEL)
	-- Pop the hooks up to look authentic
	self:SetPoseParameter("blendstates", BOUNCEBOMB_HOOK_RANGE)
	if CLIENT then
		self:InvalidateBoneCache()
	else
		-- Look citizen-ey
		self:SetSkin(math.random(MINE_CITIZEN_SKIN_MIN, MINE_CITIZEN_SKIN_MAX))
	end
	BaseClass.Initialize(self)
end

if CLIENT then return end

function ENT:_OnPrepPhase(roundNum)
	-- Get rid of the old mine
	self:RemoveMine()

	-- Make us not get in the way of the actual mine
	self:SetNoDraw(true)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)

	local mine = ents.Create("combine_mine")
	mine:SetKeyValue("Modification", "1")
	mine:SetName(self:GetName() .. "_mine")
	mine:SetPos(self:GetPos())
	mine:SetAngles(self:GetAngles())
	self:SetParent(mine)
	self:DeleteOnRemove(mine)
	mine:SetCreator(self:GetCreator())
	mine._oseCreatorSID = self._oseCreatorSID
	mine._oseSpawner = self
	mine:SetNW2Entity("OSESpawner", self)

	mine:Spawn()
	mine:Activate()
	-- Override the automatic skin with the one on the preview so it looks more
	-- seamless to the players
	mine:SetSkin(self:GetSkin())
	self.m_Mine = mine
end

function ENT:RemoveMine()
	if IsValid(self.m_Mine) then
		-- Prevent some weird snapback behaviours when de-parented
		local pos = self.m_Mine:GetPos()
		self:SetParent(NULL)
		self:SetPos(pos)

		self.m_Mine:Remove()
	end
end

function ENT:_OnBuildPhase(roundNum)
	self:RemoveMine()
	self:SetNoDraw(false)
	BaseClass._OnBuildPhase(self, roundNum)
end

-- just in case
function ENT:OnTakeDamage(dmginfo)
	-- do nothing
end

function ENT:OnHitNobuild()
	if IsValid(self.m_Mine) then
		local vel = self.m_Mine:GetVelocity()
		self:RemoveMine()
		self:SetNoDraw(false)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		local phys = self:GetPhysicsObject()
		phys:EnableMotion(true)
		phys:Wake()
		phys:AddVelocity(vel)
	end
	BaseClass.OnHitNobuild(self)
end
