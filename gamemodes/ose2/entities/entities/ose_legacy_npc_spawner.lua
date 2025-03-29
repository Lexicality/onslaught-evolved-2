--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

local manhackCvar = GetConVar("ose_max_manhacks")

--- @class SENT_OSESpawner : SENT_OSEBasePoint
local ENT = ENT --[[@as SENT_OSESpawner]]
--- @type SENT_OSEBasePoint
local BaseClass
DEFINE_BASECLASS("base_osepoint");

local SPAWN_RADIUS = 200

SPAWNER_SPAWN_MODE_NORMAL = 0
SPAWNER_SPAWN_MODE_ONCE = 1
SPAWNER_SPAWN_MODE_HUNTER = 2
SPAWNER_SPAWN_MODE_MANHACK = 2

--- What is actually going to be spawned
--- @type string[]
ENT.m_NPCs = nil

--- Internal spawning mode, for backwards compatability unfortunately
--- @type `SPAWNER_SPAWN_MODE_NORMAL` | `SPAWNER_SPAWN_MODE_HUNTER` | `SPAWNER_SPAWN_MODE_ONCE` | `SPAWNER_SPAWN_MODE_MANHACK`
ENT.m_SpawnMode = SPAWNER_SPAWN_MODE_NORMAL

--- Time between each spawn
--- @type number
ENT.m_SpawnFrequency = 0.5
--- Mapper defined time between each spawn (acts as a minimum)
--- @type number | nil
ENT.m_TargetSpawnFrequency = nil
--- Spicy `sent_spawnonce` behaviour - don't spawn until later in the round
--- @type number
ENT.m_SpawnTimeLeftTarget = 0

--- Name of the `path_track` to aim the NPCs at after they spawn
--- @type string
ENT.m_PathTargetName = "path"

--- Additional keyvalues to add on to the freshly spawned NPCs
--- @type nil | { [string]: string }
ENT.m_SpawnKeyValues = nil
--- Spawnflags to set on freshly spawned NPCs
--- @type integer
ENT.m_SpawnFlags = 0
--- TargetName to give freshly spawned NPC(s)
--- @type string | nil
ENT.m_SpawnTargetName = nil

--- If we should be spawning
--- @type boolean
ENT.m_Enabled = false
--- When to stop spawning NPCs
--- @type number
ENT.m_MaxLiveChildren = 5
--- How many have we spawned?
--- @type number
ENT.m_CurrentLiveChildren = 0
--- @type number
ENT.m_TimeLeft = 0


function ENT:Initialize()
	if self.m_NPCs == nil then
		self.m_NPCs = { "npc_combine_s", "npc_manhack", "npc_hunter" }
	end

	self:_handleHunters()

	-- Minor shenanigans
	if self.m_SpawnMode == SPAWNER_SPAWN_MODE_NORMAL and #self.m_NPCs == 1 and self.m_NPCs[1] == "npc_manhack" then
		self.m_SpawnMode = SPAWNER_SPAWN_MODE_MANHACK
	end

	local name = self:GetName()
	if name == "" then
		local id = self:MapCreationID()
		if id < 0 then
			id = self:EntIndex()
		end
		self:SetName("spawner" .. id)
	end
end

---
--- Ensures that hunters get the special magical treatment that 1.9 gave them
function ENT:_handleHunters()
	if self.m_SpawnMode ~= SPAWNER_SPAWN_MODE_NORMAL then
		return
	end

	local hunter_idx = table.Find(self.m_NPCs, "npc_hunter")
	if hunter_idx == nil then
		return
	end

	-- We could have just been created
	if #self.m_NPCs == 1 then
		self.m_SpawnMode = SPAWNER_SPAWN_MODE_HUNTER
		return
	end

	-- Purge any hunters from our table (there may be more than one!)
	repeat
		table.remove(self.m_NPCs, hunter_idx)
		hunter_idx = table.Find(self.m_NPCs, "npc_hunter")
	until hunter_idx == nil

	local hunter_spawner = ents.Create("ose_legacy_npc_spawner")
	hunter_spawner:SetPos(self:GetPos())
	hunter_spawner:SetKeyValue("npc", "npc_hunter")
	hunter_spawner:SetKeyValue("path", self.m_PathTargetName)
	if self.m_TargetSpawnFrequency then
		hunter_spawner:SetKeyValue("spawndelay", tostring(self.m_TargetSpawnFrequency))
	end
	hunter_spawner:Spawn()
	hunter_spawner:Activate()
end

---
--- Splits and validates a space separated kv table
---@param raw_value string
---@return {[string]: string} | nil
local function handleKeyValues(raw_value)
	local split = string.Explode(" +", raw_value, true)
	local splitlen = #split
	if splitlen % 2 ~= 0 then
		return nil
	end
	local ret = {}
	for i = 1, splitlen, 2 do
		local key = string.Trim(split[i])
		if key == "" then
			return nil
		end
		local value = string.Trim(split[i + 1])
		if value == "" then
			return nil
		end
		ret[key] = value
	end
	return ret
end

---
--- Splits and validates a space separated table
---@param raw_value string
---@return string[] | nil
local function handleNPCs(raw_value)
	local split = string.Explode(" +", raw_value, true)
	local ret = {}
	for i, v in ipairs(split) do
		v = string.Trim(v)
		if v == "" then
			return nil
		end
		ret[i] = v
	end
	return ret
end

---@param key string
---@param value string
function ENT:KeyValue(key, value)
	BaseClass.KeyValue(self, key, value)

	if key == "copykeys" then
		local parsed_value = handleKeyValues(value)
		if parsed_value == nil then
			ErrorNoHalt("sent_spawnonce has invalid `copykeys` keyvalue '", value, "'!\n")
			return
		end
		self.m_SpawnKeyValues = parsed_value
	elseif key == "classname" then
		if value == "sent_spawnonce" then
			self.m_SpawnMode = SPAWNER_SPAWN_MODE_ONCE
			self.m_MaxLiveChildren = 1
		end
	elseif key == "namecpy" then
		self.m_SpawnTargetName = value
	elseif key == "npc" then
		local parsed_value = handleNPCs(value)
		if parsed_value == nil then
			ErrorNoHalt("sent_spawner has invalid `npc` keyvalue '", value, "'!\n")
			return
		end
		self.m_NPCs = parsed_value
	elseif key == "path" then
		self.m_PathTargetName = value
	elseif key == "spawndelay" then
		local parsed_value = tonumber(value)
		if parsed_value == nil then
			ErrorNoHalt("sent_spawner has invalid `spawndelay` keyvalue '", value, "'!\n")
			return
		end
		self.m_TargetSpawnFrequency = parsed_value
	elseif key == "spawnflags" then
		local parsed_value = tonumber(value)
		if parsed_value == nil then
			ErrorNoHalt("sent_spawnonce has invalid `spawnflags` keyvalue '", value, "'!\n")
			return
		end
		self.m_SpawnFlags = math.floor(parsed_value)
	elseif key == "sptime" then
		local value = tonumber(value)
		if value == nil then
			ErrorNoHalt("sent_spawnonce has invalid `sptime` keyvalue '", value, "'!\n")
			return
		end
		self.m_SpawnTimeLeftTarget = math.floor(value)
		if self.m_SpawnTimeLeftTarget > 0 then
			hook.Add("OnRoundSecond", self, self._OnRoundSecond)
		else
			hook.Remove("OnRoundSecond", self)
		end
	end
end

function ENT:AcceptInput(name, activator, caller, value)
	if BaseClass.AddOutputFromAcceptInput(self, name, value) then
		return true
	end

	if name == "Enable" then
		self.m_Enabled = true
		self:NextThink(CurTime())
		return true
	elseif name == "Disable" then
		self.m_Enabled = false
		return true
	elseif name == "SetMaxLiveChildren" and self.m_SpawnMode ~= SPAWNER_SPAWN_MODE_ONCE then
		local parsed_value = tonumber(value)
		if parsed_value == nil or parsed_value < 0 then
			ErrorNoHalt("ose_legacy_npc_spawner got invalid `SetMaxLiveChildren` value '", value, "'!\n")
			return true
		end

		self.m_MaxLiveChildren = math.floor(parsed_value)
		return true
	elseif name == "SetSpawnFrequency" then
		local parsed_value = tonumber(value)
		if parsed_value == nil or parsed_value < 0 then
			ErrorNoHalt("ose_legacy_npc_spawner got invalid `SetSpawnFrequency` value '", value, "'!\n")
			return true
		end

		if self.m_TargetSpawnFrequency ~= nil then
			self.m_SpawnFrequency = math.max(parsed_value, self.m_TargetSpawnFrequency)
		else
			self.m_SpawnFrequency = parsed_value
		end
		return true
	end

	return false
end

local COMBINE_TYPES = { "CombineElite", "ShotgunSoldier", "npc_combine_s" }

local function calledOnRemove(_npc, spawner)
	if not IsValid(spawner) then
		return
	end
	spawner.m_CurrentLiveChildren = spawner.m_CurrentLiveChildren - 1
	spawner:NextThink(CurTime() + spawner.m_SpawnFrequency)
end

---@param classname string
function ENT:SpawnNPC(classname)
	-- turbo hack
	if classname == "npc_manhack" then
		if #ents.FindByClass("npc_manhack") >= manhackCvar:GetInt() then
			return
		end
	end

	if classname == "npc_combine_s" then
		classname = COMBINE_TYPES[math.random(#COMBINE_TYPES)]
	end

	--- @type NPCListDefinition | nil
	local npcData = list.GetEntry("OSENPC", classname)

	if npcData ~= nil then
		classname = npcData.Class
	end

	local npc = ents.Create(classname)
	--- @cast npc GNPC
	if not IsValid(npc) then
		ErrorNoHalt("Tried to create invalid npc ", classname, "!!\n")
		self.m_Enabled = false
		return
	end

	local offset = Vector(
		math.random(-SPAWN_RADIUS, SPAWN_RADIUS),
		math.random(-SPAWN_RADIUS, SPAWN_RADIUS),
		10
	)
	npc:SetPos(self:GetPos() + offset)


	local spawnflags = self.m_SpawnFlags

	if npcData ~= nil then
		if (npcData.Model) then
			npc:SetModel(npcData.Model)
		end

		if (npcData.Material) then
			npc:SetMaterial(npcData.Material)
		end

		if (npcData.TotalSpawnFlags) then
			spawnflags = npcData.TotalSpawnFlags
		else
			spawnflags = SF_NPC_LONG_RANGE + SF_NPC_FADE_CORPSE + SF_NPC_ALWAYSTHINK + SF_NPC_NO_WEAPON_DROP
			if (npcData.SpawnFlags) then
				spawnflags = spawnflags + npcData.SpawnFlags
			end
		end

		if (npcData.KeyValues) then
			for k, v in pairs(npcData.KeyValues) do
				npc:SetKeyValue(k, v)
			end
		end
		if (npcData.Skin) then
			npc:SetSkin(npcData.Skin)
		end

		-- Since we have this on hand, let's save time later
		npc._oseReward = npcData.Reward
		npc._oseName = npcData.Name
	end

	npc:SetKeyValue("spawnflags", tostring(spawnflags))
	npc:SetKeyValue("target", self.m_PathTargetName)

	npc:SetSquad(self:GetName())

	if self.m_SpawnKeyValues then
		for k, v in pairs(self.m_SpawnKeyValues) do
			npc:SetKeyValue(k, v)
		end
	end

	if self.m_SpawnTargetName ~= nil then
		npc:SetName(self.m_SpawnTargetName)
	else
		npc:SetName(self:GetName() .. "&" .. npc:GetCreationID())
	end

	-- TODO: Spawn effects

	npc:Spawn()
	npc:CallOnRemove("ose", calledOnRemove, self)
	self.m_CurrentLiveChildren = self.m_CurrentLiveChildren + 1
	npc:Activate()

	if npcData ~= nil then
		-- From the sandbox code:
		-- For those NPCs that set their model/skin in Spawn function
		-- We have to keep the call above for NPCs that want a model set by Spawn() time
		-- BAD: They may adversly affect entity collision bounds
		if (npcData.Model and npc:GetModel():lower() ~= npcData.Model:lower()) then
			npc:SetModel(npcData.Model)
		end

		if (npcData.Skin) then
			npc:SetSkin(npcData.Skin)
		end

		if (npcData.Health) then
			npc:SetHealth(npcData.Health)
			npc:SetMaxHealth(npcData.Health)
		end
	end

	npc:DropToFloor()
	npc:Fire("Wake")

	self:TriggerOutput("OnSpawnNPC", npc, npc:GetName())
end

function ENT:_OnRoundSecond(timeLeft)
	self.m_TimeLeft = timeLeft
end

function ENT:Think()
	local now = CurTime()
	if
		not self.m_Enabled
		or self.m_CurrentLiveChildren >= self.m_MaxLiveChildren
		or (self.m_SpawnTimeLeftTarget > 0 and self.m_TimeLeft > self.m_SpawnTimeLeftTarget)
	then
		-- hibernate
		self:NextThink(now + 1)
		return true
	end

	-- time to spawn
	local classname = self.m_NPCs[math.random(#self.m_NPCs)]
	self:SpawnNPC(classname)

	self:NextThink(now + self.m_SpawnFrequency)
	return true
end
