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

NPCS                         = {}
NPCS["npc_combine_s"]        = {
	{
		spawnflags = 403204,
		reward = 100,
		kvs = {
			tacticalvariant = "1",
			additionalequipment = "weapon_smg1",
			model = "models/combine_soldier.mdl",
			NumGrenades = "999999",
			wakeradius = "999999"
		}
	},
	{
		spawnflags = 403204,
		reward = 140,
		kvs = {
			tacticalvariant = "1",
			additionalequipment = "weapon_ar2",
			model = "models/combine_super_soldier.mdl",
			wakeradius = "999999",
		}
	},
	{
		spawnflags = 403204,
		reward = 120,
		kvs = {
			tacticalvariant = "1",
			additionalequipment = "weapon_shotgun",
			model = "models/combine_soldier_prisonguard.mdl",
			NumGrenades = "999999",
			wakeradius = "999999",
		}
	}
}
NPCS["npc_metropolice"]      = {
	spawnflags = 403204,
	reward = 50,
	kvs = {
		additionalequipment = "weapon_pistol"
	}
}
NPCS["npc_hunter"]           = {
	spawnflags = 9984,
	reward = 500,
}
NPCS["npc_manhack"]          = {
	spawnflags = 263940,
	reward = 50,
}
NPCS["npc_zombie"]           = {
	spawnflags = 1796,
	reward = 75,
}
NPCS["npc_fastzombie"]       = {
	spawnflags = 1796,
	reward = 100,
}
NPCS["npc_zombine"]          = {
	spawnflags = 1796,
	reward = 100,
}
NPCS["npc_antlion"]          = {
	spawnflags = 9984,
	reward = 100,
	KEYS =
	"radius 512"
}
NPCS["npc_headcrab"]         = {
	spawnflags = 1796,
	reward = 33,
}
NPCS["npc_headcrab_fast"]    = {
	spawnflags = 1796,
	reward = 40,
}
NPCS["npc_antlionguard"]     = {
	spawnflags = 9988,
	reward = 700,
}
NPCS["npc_rollermine"]       = {
	spawnflags = 9988,
	reward = 175,
	KEYS = "uniformsightdist 1"
}
NPCS["npc_poisonzombie"]     = {
	spawnflags = 9988,
	reward = 125,
	KEYS = "crabcount 3"
}
NPCS["npc_headcrab_black"]   = {
	spawnflags = 9988,
	reward = 120,
}
NPCS["npc_zombie_torso"]     = {
	spawnflags = 1796,
	reward = 50,
}
NPCS["npc_fastzombie_torso"] = {
	spawnflags = 1796,
	reward = 75,
}
