--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

local refundMultiplierCvar = GetConVar("ose_refund_multiplier")

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

--- @param undo SUndo
--- @param ent SENT_OSEProp
local function fancyUndo(undo, ent)
	if not IsValid(ent) then
		return false
	end
	ent:RemovePretty()
	return true
end

--- Generic(ish) entity spawning code
--- This started life as DoPlayerEntitySpawn from sandbox and was then mucked
--- about with a bunch
--- @param ply GPlayer
--- @param class string
--- @param model? string
--- @param spawnAngle? SpawnAngle
--- @return GEntity
local function doSpawn(ply, class, model, spawnAngle)
	local start = ply:GetShootPos()
	local aim = ply:GetAimVector()

	local tr = util.TraceLine({
		start = start,
		endpos = start + (aim * 1000),
		filter = ply,
	})
	if not tr.Hit then return NULL end

	for _, ent in ipairs(ents.FindInSphere(tr.HitPos, 10)) do
		--- @cast ent GEntity
		if ent:GetClass() == "func_nobuild" then
			ply:SendNotification(NOTIFY_ERROR, "ose.notification.invalid_pos", 10)
			return NULL
		end
	end

	local ang = Angle(0, ply:EyeAngles().yaw + 180, 0)
	if spawnAngle then
		if isfunction(spawnAngle) then
			ang = spawnAngle(tr)
		else
			ang = ang + spawnAngle
		end
	end

	local ent = ents.Create(class)
	if not IsValid(ent) then
		return ent
	end

	if model then
		ent:SetModel(model)
	end
	ent:SetPos(tr.HitPos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	ent:SetCreator(ply)

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

	ent:SetSpawnEffect(true)

	return ent
end

---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSESpawn(ply, cmd, args)
	if not IsValid(ply) then
		print("The server can't spawn things")
		return
	end
	local model = args[1]
	if not list.HasEntry("OSEProps", model) then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.invalid_prop", 10, model)
		return
	elseif not hook.Run("PlayerSpawnProp", ply, model) then
		-- no need to notify the player, the hook will do that
		return
	end

	--- @type number
	local price = hook.Run("LookupPropPrice", ply, model)
	if not ply:CanAfford(price) then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.cant_afford", 10)
		return
	end

	--- @type OSEPropDefinition
	local propData = list.GetEntry("OSEProps", model)

	local ent = doSpawn(ply, "ose_prop", model, propData.SpawnAngle)
	if not IsValid(ent) then
		return
	end

	ent._osePropValue = price
	ply:AddMoney(-price, "ose.money.reason.bought_x", propData.Name)

	hook.Run("PlayerSpawnedProp", ply, model, ent)

	undo.Create("Prop")
	undo.SetPlayer(ply)
	undo.AddFunction(fancyUndo, ent)
	undo.Finish(propData.Name)

	ply:AddCleanup("props", ent)
end
concommand.Add("ose_spawn", ccOSESpawn)

---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSESpawnEnt(ply, cmd, args)
	if not IsValid(ply) then
		print("The server can't spawn things")
		return
	end
	local class = args[1]
	--- @type OSEEntityDefinition
	local entData = list.GetEntry("OSEEntities", class)
	if not entData then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.invalid_ent", 10, class)
		return
	elseif not hook.Run("PlayerSpawnEntity", ply, class, entData) then
		-- no need to notify the player, the hook will do that
		return
	end

	--- @type number
	local price = hook.Run("LookupEntityPrice", ply, class, entData)
	if not ply:CanAfford(price) then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.cant_afford", 10)
		return
	end

	local ent = doSpawn(ply, class, nil, entData.SpawnAngle)
	if not IsValid(ent) then
		return
	end

	ent._osePropValue = price
	ply:AddMoney(-price, "ose.money.reason.bought_x", entData.Name)

	hook.Run("PlayerSpawnedEntity", ply, class, ent, entData)

	undo.Create(entData.Name)
	undo.SetPlayer(ply)
	undo.AddFunction(fancyUndo, ent)
	undo.Finish()

	ply:AddCleanup(class .. "s", ent)
end
concommand.Add("ose_spawnent", ccOSESpawnEnt)

---@param ply GPlayer
---@param model string
---@return boolean
function GM:PlayerSpawnProp(ply, model)
	if self.m_RoundPhase ~= ROUND_PHASE_BUILD then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.only_build_mode", 10)
		return false
	end
	return ply:CheckLimit("props")
end

---@param ply GPlayer
---@param model string
---@param ent GEntity
function GM:PlayerSpawnedProp(ply, model, ent)
	ply:AddCount("props", ent)
end

---@param ply GPlayer
---@param class string
---@param entData OSEEntityDefinition
---@return boolean
function GM:PlayerSpawnEntity(ply, class, entData)
	if not entData.AllowInBattle and self.m_RoundPhase ~= ROUND_PHASE_BUILD then
		ply:SendNotification(NOTIFY_ERROR, "ose.notification.only_build_mode", 10)
		return false
	end
	-- TODO: Class-restricted ents
	return ply:CheckLimit(class)
end

---@param ply GPlayer
---@param class string
---@param ent GEntity
---@param entData OSEEntityDefinition
function GM:PlayerSpawnedEntity(ply, class, ent, entData)
	ply:AddCount(class, ent)
end

function GM:PhysgunPickup(ply, ent)
	-- TODO: teams? prop protection?

	return not ent:CreatedByMap() and ent["OSEProp"]
end

function GM:OnPhysgunPickup(ply, ent)
	if ent["OSEProp"] then
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end

function GM:PhysgunDrop(ply, ent)
	if ent["OSEProp"] then
		if not isPropIntersectingPlayer(ent) then
			ent:SetCollisionGroup(COLLISION_GROUP_NONE)
		end
		ent:GetPhysicsObject():EnableMotion(false)
	end
end

function GM:OnPhysgunReload(physgun, ply)
	-- TODO: teams? prop protection?
	local tr = ply:GetEyeTrace()
	local target = tr.Entity
	if not target or not IsValid(target) or not target["OSEProp"] then
		return
	end
	--- @cast target SENT_OSEProp
	target:RemovePretty()
end

---@param ply GPlayer
---@param undo SUndo
function GM:CanUndo(ply, undo)
	-- Don't let players accidentally destroy their own stuff mid-battle
	return self.m_RoundPhase == ROUND_PHASE_BUILD
end

function GM:EntityRemoved(ent, fullUpdate)
	-- Refund the player when their stuff gets deleted during the build phase
	if self.m_RoundPhase ~= ROUND_PHASE_BUILD then
		return
	end
	local refundM = refundMultiplierCvar:GetFloat()
	if refundM <= 0 then
		return
	end
	local owner = ent:GetCreator()
	local amount = ent._osePropValue
	if IsValid(owner) and isnumber(amount) then
		owner:AddMoney(amount * refundM, "ose.money.reason.refund")
	end
end
