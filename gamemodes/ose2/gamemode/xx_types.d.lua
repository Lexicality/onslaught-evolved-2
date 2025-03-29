--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
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

--- @alias OSERoundPhase `ROUND_PHASE_BATTLE`|`ROUND_PHASE_BUILD`|`ROUND_PHASE_PREP`

--- @type OSERoundPhase
GM.m_RoundPhase = ROUND_PHASE_BATTLE
--- @type integer
GM.m_Round = 0
--- @type number
GM.m_PhaseStart = 0
--- @type number
GM.m_PhaseEnd = 0
--- @type number
GM.m_LastSecond = 0

--- @type OSESpawnMenu | nil
_G.g_SpawnMenu = nil

--- @type OSEAmmoMenu | nil
_G.g_AmmoMenu = nil

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

--- @alias SpawnAngle GAngle | fun(tr: STraceResult): GAngle

--- @class OSEEntityDefinition
--- @field Name string The name to display to clients (should probably be #class)
--- @field DisplayModel string The model to display in the spawn menu
--- @field DisplaySkin? number The skin to apply to that model (if any)
--- @field SpawnAngle? SpawnAngle Spawn angles override
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

--- @class OSEAmmoDefinition
--- @field Name string The name to display for the ammo
--- @field DisplayModel string The model to display in the spawn menu
--- @field Price integer How much the players have to pay
--- @field Quantity integer How much ammo the player gets when they buy it
--- @field EngineName string The actual ammo name eg "SMG1_Grenade"
--- @field GiveWeapon? string Specifically just for grenades

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
--- @field _oseCreatorSID? string @The entity creator's steam ID 64, if applicable
--- @field _oseIgniter? GPlayer @If we've been set on fire, this player did it

--- @class GNPC
--- @field _oseReward? integer @If we've got a pre-calculated reward for this NPC
--- @field _oseName? string @If we've got a pre-specified name for this NPC

--- @class GPlayer
--- @field NextSpawnTime integer @When the base gamemode should next allow the player to spawn
--- @field _joinedBattleLate number | nil @If the player spawned mid-battle, when they spawned
--- @field _deathCount number @How many times the player has died this battle phase

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
