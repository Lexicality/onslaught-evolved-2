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

--- @type OSESpawnMenu | nil
_G.g_SpawnMenu = nil

-----------
-- Types --
-----------

--- @class OSEPropDefinition
--- @field Name string
--- @field ModelGroup number
--- @field SpawnAngle? GAngle

--- @class OSEPropGroupDefinition
--- @field Name string
--- @field Icon? string
--- @field Tooltip? string

--- @class OSEEntityDefinition
--- @field Name string The name to display to clients (should probably be #class)
--- @field DisplayModel string The model to display in the spawn menu
--- @field DisplaySkin? number The skin to apply to that model (if any)
--- @field SpawnAngle? GAngle Spawn angles override
--- @field AllowInBattle boolean If players can spawn this mid-combat
--- @field ModelGroup number What tab to diplay under
--- @field Price integer How much the players have to pay to spawn this

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

--- @class OSEClassDefinition
--- @field Name string
--- @field Description string
--- @field Selectable boolean
--- @field Icon string

--- @class EntityOutputDefiniton
--- @field entities string
--- @field input string
--- @field param string
--- @field delay number
--- @field time integer

--- @class ToolMenuOptionDefinition
--- @field ItemName string
--- @field Text string
--- @field Command string
--- @field CPanelFunction? function

--- @class ToolTabCategoryDefinition : {[integer]: ToolMenuOptionDefinition}
--- @field ItemName string
--- @field Text string

--- @class ToolTabDefinition
--- @field Icon? string
--- @field Label string
--- @field Name string
--- @field Items ToolTabCategoryDefinition[]

--------------------------
-- Missing Entity stuff --
--------------------------

--- @type {[string]: EntityOutputDefiniton[]}?
ENT.m_tOutputs = nil

--- @param key string
--- @param value string
--- @return boolean
function ENT:SetNetworkKeyValue(key, value) end

--- @class GEntity
--- @field _oseNPC? boolean @True if this entity is a NPC that was created by an onslaught spawner
--- @field _osePropValue? integer @How much the player paid for this prop (if it's a prop)
--- @field _oseSpawner? GEntity @If this entity was spawned by something else eg ose_mine

--- @class GNPC
--- @field _oseReward? integer @If we've got a pre-calculated reward for this NPC

--- @class GPlayer
--- @field NextSpawnTime integer @When the base gamemode should next allow the player to spawn

--- @class GPlayer
local ply = {}
--- @return integer
function ply:GetMoneyVar() end

--- @param money integer
function ply:SetMoneyVar(money) end

--- Returns the class ID the player wants to be next time they spawn in battle mode
--- @return integer
function ply:GetTargetClassID() end

--- Sets the class ID the player wants to be next time they spawn in battle mode
--- @param targetClass integer
function ply:SetTargetClassID(targetClass) end
