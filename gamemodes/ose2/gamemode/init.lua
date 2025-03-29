--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

include("shared.lua")

include("sv_damage.lua")
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
	self:SetupDamageOverrides()
end
