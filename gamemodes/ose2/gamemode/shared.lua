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

AddCSLuaFile()

DeriveGamemode("base")

GM.Name = "Onslaught: Evolved 2"
GM.Author = "Lexi Robinson"
GM.Email = "lexi@lexi.org.uk"
GM.Website = "https://github.com/Lexicality/onslaught-evolved-2"

GM.TeamBased = false

-- Fixes might be used by other files
include("sh_fixes.lua")

-- Base must be included before all others
include("player_class/player_osebase.lua")

include("player_class/player_builder.lua")
include("player_class/player_engineer.lua")
include("player_class/player_osebase.lua")
include("player_class/player_pyro.lua")
include("player_class/player_scout.lua")
include("player_class/player_sniper.lua")
include("player_class/player_soldier.lua")
-- include("player_class/player_support.lua")
include("sh_entity_meta.lua")
include("sh_money.lua")
include("sh_player.lua")
include("sh_player_meta.lua")
include("sh_props.lua")

ROUND_PHASE_BUILD = 0
ROUND_PHASE_PREP = 1
ROUND_PHASE_BATTLE = 2

--- Returns the current round and phase
--- @return integer round
--- @return OSERoundPhase phase
function GM:GetCurrentRound()
	return self.m_Round, self.m_RoundPhase
end
