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

--- This file is vaguely the same thing as a typescript d.ts file
--- @meta

error("Don't include me!")

-------------
-- GLOBALS --
-------------
-- The Lua Reload System means any globals you define are nuked and recreated
-- every time a file reloads which is a massive bugger for typing them.
--
-- Conveniently, the Lua Language Server will execute this file even though it's
-- never referenced by any files in the workspace so we can define them here

--- @type `ROUND_PHASE_BUILD` | `ROUND_PHASE_PREP` | `ROUND_PHASE_BATTLE`
GM.m_RoundPhase = ROUND_PHASE_BATTLE
--- @type integer
GM.m_Round = 0
--- @type number
GM.m_PhaseEnd = 0
--- @type number
GM.m_LastSecond = 0

-----------
-- Types --
-----------

--- @class OSEPropDefinition
--- @field Name string
--- @field ModelGroup number
--- @field SpawnAngle? GAngle

--- @class NPCListDefinition
--- @field Class string
--- @field Health? integer
--- @field KeyValues? {[string]: string}
--- @field Material? string
--- @field Model? string
--- @field Name string
--- @field Reward integer
--- @field Skin? integer
--- @field SpawnFlags? integer
--- @field TotalSpawnFlags? integer
