--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]

AddCSLuaFile()

--- @type GPlayerClass
local BaseClass
DEFINE_BASECLASS("player_default")

--- @class OSEPlayerBase : GPlayerClass
local PLAYER = {}

--- @type string[]
PLAYER.ValidAmmo = {}

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Int", 0, "MoneyVar")
	self.Player:NetworkVar("Int", 1, "TargetClassID")
end

function PLAYER:Init()
	-- Ensure the money var is up to date
	self.Player:GetMoney(true)
end

--- Checks if this class can buy this ammo type
--- @param ammoName string
--- @param ammoData OSEAmmoDefinition
--- @return boolean
function PLAYER:CanBuyAmmo(ammoName, ammoData)
	return table.Find(self.ValidAmmo, ammoName) ~= nil
end

player_manager.RegisterClass("player_osebase", PLAYER, "player_default")
