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

local sandboxIconColour = Color(255, 80, 0, 255)

function GM:SetupKillIcons()
	-- Lambda Killicons Copyright (c) 2017 ζeh Matt
	-- Licensed under the terms of the MIT license
	-- https://github.com/GMLambda/Lambda/blob/f192e4368a107848f0cd27ed683cec1200d316a2/gamemode/huds/hud_deathnotice.lua#L39-L55
	killicon.Add("prop_physics", "lambda/killicons/func_physbox_killicon", sandboxIconColour)
	killicon.Add("func_physbox", "lambda/killicons/func_physbox_killicon", sandboxIconColour)
	killicon.Add("func_physbox_multiplayer", "lambda/killicons/func_physbox_killicon", sandboxIconColour)
	killicon.Add("env_fire", "lambda/killicons/env_fire_killicon", sandboxIconColour)
	killicon.Add("entityflame", "lambda/killicons/env_fire_killicon", sandboxIconColour)
	killicon.Add("env_explosion", "lambda/killicons/env_explosion_killicon", sandboxIconColour)
	killicon.Add("env_physexplosion", "lambda/killicons/env_explosion_killicon", sandboxIconColour)
	killicon.Add("point_hurt", "lambda/killicons/point_hurt_killicon", sandboxIconColour)
	killicon.Add("trigger_hurt", "lambda/killicons/point_hurt_killicon", sandboxIconColour)
	killicon.Add("radiation", "lambda/killicons/radiation_killicon", sandboxIconColour)
	killicon.Add("func_door", "lambda/killicons/func_door_killicon", sandboxIconColour)
	killicon.Add("func_door_rotating", "lambda/killicons/func_door_killicon", sandboxIconColour)
	killicon.Add("prop_door_rotating", "lambda/killicons/func_door_killicon", sandboxIconColour)
	killicon.Add("npc_barnacle", "lambda/killicons/npc_barnacle_killicon", sandboxIconColour)
	killicon.Add("npc_manhack", "lambda/killicons/npc_manhack_killicon", sandboxIconColour)
	killicon.Add("fall", "lambda/killicons/worldspawn_killicon", sandboxIconColour)
	killicon.Add("combine_mine", "lambda/killicons/combine_mine_killicon", sandboxIconColour)

	-- OSE killicons
	killicon.AddFont("weapon_ose_super_shotgun", "HL2MPTypeDeath", "0", sandboxIconColour, 0.45)
end
