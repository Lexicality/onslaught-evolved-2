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


function ENT:Initialize()
	if self.m_NPCs == nil then
		self.m_NPCs = { "npc_combine_s", "npc_manhack", "npc_hunter" }
	end

	print("Hey, I got spawned!!", self.ClassName, self.ClassNameOverride)
end

function ENT:KeyValue(key, value)
	BaseClass.KeyValue(key, value)
	print("I got keyvalued!", key, value)
	if key == "classname" and value == "sent_spawnonce" then
		self.m_SpawnMode = SPAWNER_SPAWN_MODE_ONCE
	end
end
