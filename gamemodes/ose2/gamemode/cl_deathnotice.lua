--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
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
