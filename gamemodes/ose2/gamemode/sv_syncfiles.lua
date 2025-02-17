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

AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_effects.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_notifications.lua")
AddCSLuaFile("ui/cl_classquickmenu.lua")
AddCSLuaFile("ui/cl_entityicon.lua")
AddCSLuaFile("ui/cl_propicon.lua")
AddCSLuaFile("ui/cl_propmenu.lua")
AddCSLuaFile("ui/cl_propsheet.lua")
AddCSLuaFile("ui/cl_sidemenu.lua")
AddCSLuaFile("ui/cl_spawnmenu.lua")

-- Gonna need to automate this at some point (probably soon)
resource.AddFile("materials/lambda/killicons/combine_mine_killicon.vmt")
resource.AddFile("materials/lambda/killicons/env_explosion_killicon.vmt")
resource.AddFile("materials/lambda/killicons/env_fire_killicon.vmt")
resource.AddFile("materials/lambda/killicons/env_laser_killicon.vmt")
resource.AddFile("materials/lambda/killicons/func_door_killicon.vmt")
resource.AddFile("materials/lambda/killicons/func_physbox_killicon.vmt")
resource.AddFile("materials/lambda/killicons/npc_barnacle_killicon.vmt")
resource.AddFile("materials/lambda/killicons/npc_manhack_killicon.vmt")
resource.AddFile("materials/lambda/killicons/point_hurt_killicon.vmt")
resource.AddFile("materials/lambda/killicons/radiation_killicon.vmt")
resource.AddFile("materials/lambda/killicons/worldspawn_killicon.vmt")
resource.AddFile("materials/ose/classes/icon_engineer.vmt")
resource.AddFile("materials/ose/classes/icon_pyro.vmt")
resource.AddFile("materials/ose/classes/icon_scout.vmt")
resource.AddFile("materials/ose/classes/icon_sniper.vmt")
resource.AddFile("materials/ose/classes/icon_soldier.vmt")
resource.AddFile("materials/ose/classes/icon_support.vmt")
