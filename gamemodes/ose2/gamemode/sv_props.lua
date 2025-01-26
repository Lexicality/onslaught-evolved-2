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

-- A little hacky function to help prevent spawning props partially inside walls
-- From Sandbox
local function fixupProp(ply, ent, hitpos, mins, maxs)
	local entPos = ent:GetPos()
	local endposD = ent:LocalToWorld(mins)
	local tr_down = util.TraceLine({
		start = entPos,
		endpos = endposD,
		filter = { ent, ply }
	})

	local endposU = ent:LocalToWorld(maxs)
	local tr_up = util.TraceLine({
		start = entPos,
		endpos = endposU,
		filter = { ent, ply }
	})

	-- Both traces hit meaning we are probably inside a wall on both sides, do nothing
	if (tr_up.Hit and tr_down.Hit) then return end

	if (tr_down.Hit) then ent:SetPos(entPos + (tr_down.HitPos - endposD)) end
	if (tr_up.Hit) then ent:SetPos(entPos + (tr_up.HitPos - endposU)) end
end

local function TryFixPropPosition(ply, ent, hitpos)
	local mins = ent:OBBMins()
	local maxs = ent:OBBMaxs()
	fixupProp(ply, ent, hitpos, Vector(mins.x, 0, 0), Vector(maxs.x, 0, 0))
	fixupProp(ply, ent, hitpos, Vector(0, mins.y, 0), Vector(0, maxs.y, 0))
	fixupProp(ply, ent, hitpos, Vector(0, 0, mins.z), Vector(0, 0, maxs.z))
end

--- The simplest anti-griefing check I could come up with, can easily trigger
--- false positives
--- @param ent GEntity
--- @return boolean
local function isPropIntersectingPlayer(ent)
	for _, intersecting in ipairs(ents.FindInSphere(ent:GetPos(), ent:GetModelRadius())) do
		--- @cast intersecting GEntity
		if intersecting:IsPlayer() then
			return true
		end
	end
	return false
end

---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSESpawn(ply, cmd, args)
	local model = args[1]
	if not list.HasEntry("OSEProps", model) then
		-- TODO: sensible notification
		ply:PrintMessage(HUD_PRINTTALK, "bzzzt wrong")
		return
	elseif not IsValid(ply) then
		print("The server can't spawn things")
		return
	elseif not gamemode.Call("PlayerSpawnProp", ply, model) then
		-- no need to notify the player, the hook will do that
		return
	end

	-- This is roughly copy/pasted from sandbox and then mucked about with

	local start = ply:GetShootPos()
	local aim = ply:GetAimVector()

	local trace = {}
	trace.start = start
	trace.endpos = start + (aim * 1000)
	trace.filter = ply

	local tr = util.TraceLine(trace)
	--- @cast tr STraceResult
	if not tr.Hit then return end

	--- @type OSEPropDefinition
	local propData = list.Get("OSEProps")[model]

	local ang = Angle(0, ply:EyeAngles().yaw + 180, 0)
	if propData.SpawnAngle then
		ang = ang + propData.SpawnAngle
	end

	local ent = ents.Create("ose_prop")
	ent:SetModel(model)
	ent:SetPos(tr.HitPos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()

	ent["SetPlayer"](ent, ply)

	-- Attempt to move the object so it sits flush
	local vFlushPoint = tr.HitPos - (tr.HitNormal * 512)
	vFlushPoint = ent:NearestPoint(vFlushPoint)
	vFlushPoint = ent:GetPos() - vFlushPoint
	vFlushPoint = tr.HitPos + vFlushPoint
	ent:SetPos(vFlushPoint)

	TryFixPropPosition(ply, ent, tr.HitPos)

	if isPropIntersectingPlayer(ent) then
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end

	hook.Run("PlayerSpawnedProp", ply, model, ent)

	ent:SetSpawnEffect(true)

	undo.Create("Prop")
	undo.SetPlayer(ply)
	undo.AddEntity(ent)
	undo.Finish(propData.Name)

	ply:AddCleanup("props", ent)

	cleanup.Add(ply, "props", ent)
end

concommand.Add("ose_spawn", ccOSESpawn)

---@param ply GPlayer
---@param model string
---@return boolean
function GM:PlayerSpawnProp(ply, model)
	-- TODO player prop limit goes here
	return self.m_RoundPhase == ROUND_PHASE_BUILD and ply:CheckLimit("props")
end

---@param ply GPlayer
---@param model string
---@param ent GEntity
function GM:PlayerSpawnedProp(ply, model, ent)
	ply:AddCount("props", ent)
end

function GM:PhysgunPickup(ply, ent)
	-- TODO: teams? prop protection?

	return not ent:CreatedByMap()
end

function GM:OnPhysgunPickup(ply, ent)
	if ent:GetClass() == "ose_prop" then
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end

function GM:PhysgunDrop(ply, ent)
	if ent:GetClass() == "ose_prop" then
		if not isPropIntersectingPlayer(ent) then
			ent:SetCollisionGroup(COLLISION_GROUP_NONE)
		end
		ent:GetPhysicsObject():EnableMotion(false)
	end
end
