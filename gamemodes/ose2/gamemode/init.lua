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

include("shared.lua")

include("sv_entities.lua")
include("sv_money.lua")
include("sv_npcs.lua")
include("sv_player.lua")
include("sv_props.lua")
include("sv_rounds.lua")
include("sv_syncfiles.lua")


function GM:OnGamemodeLoaded()
	MsgN("Hello from OSE2!")
	scripted_ents.Alias("sent_spawner", "ose_legacy_npc_spawner")
	scripted_ents.Alias("sent_spawnonce", "ose_legacy_npc_spawner")

	self:SetupNPCs()
	self:SetupRounds()
	self:SetupProps()
	self:SetupClasses()
	self:SetupBuyables()
end
