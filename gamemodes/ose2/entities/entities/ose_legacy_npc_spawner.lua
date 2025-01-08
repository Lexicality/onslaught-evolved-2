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

DEFINE_BASECLASS("base_osepoint");

SPAWNER_SPAWN_MODE_NORMAL = 0
SPAWNER_SPAWN_MODE_HUNTER = 1
SPAWNER_SPAWN_MODE_ONCE = 2


--- What is actually going to be spawned
--- @type string[]
ENT.m_NPCs = nil

--- Internal spawning mode, for backwards compatability unfortunately
--- @type `SPAWNER_SPAWN_MODE_NORMAL` | `SPAWNER_SPAWN_MODE_HUNTER` | `SPAWNER_SPAWN_MODE_ONCE`
ENT.m_SpawnMode = SPAWNER_SPAWN_MODE_NORMAL

--- Time between each spawn
--- @type number
ENT.m_SpawnFrequency = 0.5
--- Mapper defined time between each spawn (acts as a minimum)
--- @type number | nil
ENT.m_TargetSpawnFrequency = nil
--- Spicy `sent_spawnonce` behaviour - don't spawn until later in the round
--- @type number | nil
ENT.m_SpawnTimeLeftTarget = nil

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


-- TODO this should probs be in a utilities file somewhere
---
local function table_find(table, value)
	for i, v in ipairs(table) do
		if v == value then
			return i
		end
	end

	return nil
end


function ENT:Initialize()
	if self.m_NPCs == nil then
		self.m_NPCs = { "npc_combine_s", "npc_manhack", "npc_hunter" }
	end

	self:_handleHunters()

	-- TODO
end

---
--- Ensures that hunters get the special magical treatment that 1.9 gave them
function ENT:_handleHunters()
	if self.m_SpawnMode ~= SPAWNER_SPAWN_MODE_NORMAL then
		return
	end

	local hunter_idx = table_find(self.m_NPCs, "npc_hunter")
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
		hunter_idx = table_find(self.m_NPCs, "npc_hunter")
	until hunter_idx == nil

	local hunter_spawner = ents.Create("ose_legacy_npc_spawner")
	hunter_spawner:SetPos(self:GetPos())
	hunter_spawner:SetKeyValue("npc", "npc_hunter")
	hunter_spawner:SetKeyValue("path", self.m_PathTargetName)
	hunter_spawner:SetKeyValue("spawndelay", tostring(self.m_TargetSpawnFrequency))
	hunter_spawner:Spawn()
	hunter_spawner:Activate()
end

---
--- Splits and validates a space separated kv table
---@param raw_value string
---@return {[string]: string} | nil
local function handleKeyValues(raw_value)
	local split = string.Explode(" ", raw_value, false)
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
	local split = string.Explode(" ", raw_value, false)
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
	BaseClass.KeyValue(key, value)
	if key == "copykeys" then
		local parsed_value = handleKeyValues(value)
		if parsed_value == nil then
			ErrorNoHalt("sent_spawnonce has invalid `copykeys` keyvalue '", value, "'!")
			return
		end
		self.m_SpawnKeyValues = parsed_value
	elseif key == "classname" then
		if value == "sent_spawnonce" then
			self.m_SpawnMode = SPAWNER_SPAWN_MODE_ONCE
		end
	elseif key == "namecpy" then
		self.m_SpawnTargetName = value
	elseif key == "npc" then
		local parsed_value = handleNPCs(value)
		if parsed_value == nil then
			ErrorNoHalt("sent_spawner has invalid `npc` keyvalue '", value, "'!")
			return
		end
		self.m_NPCs = parsed_value
	elseif key == "path" then
		self.m_PathTargetName = value
	elseif key == "spawndelay" then
		local parsed_value = tonumber(value)
		if parsed_value == nil then
			ErrorNoHalt("sent_spawner has invalid `spawndelay` keyvalue '", value, "'!")
			return
		end
		self.m_TargetSpawnFrequency = parsed_value
	elseif key == "spawnflags" then
		local parsed_value = tonumber(value)
		if parsed_value == nil then
			ErrorNoHalt("sent_spawnonce has invalid `spawnflags` keyvalue '", value, "'!")
			return
		end
		self.m_SpawnFlags = math.floor(parsed_value)
	elseif key == "sptime" then
		local value = tonumber(value)
		if value == nil then
			ErrorNoHalt("sent_spawnonce has invalid `sptime` keyvalue '", value, "'!")
			return
		end
		self.m_SpawnFlags = math.floor(value)
	end
end
