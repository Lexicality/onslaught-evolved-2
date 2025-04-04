--[[
 Copyright (C) 2025 Lexi Robinson

 Licensed under the EUPL, Version 1.2

 You may not use this work except in compliance with the Licence.
 You should have received a copy of the Licence along with this work. If not, see:
 <https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12>.
 See the Licence for the specific language governing permissions and limitations under the Licence.
--]]
AddCSLuaFile()

include("sandbox/gamemode/player_extension.lua")

local LIMIT_TRANSLATIONS = {
	ose_mine = "mines",
	ose_turret = "turrets",
	ose_health_charger = "healthchargers",
	ose_ammo_crate = "ammocrates",
}

--- @class GPlayer
local plyMeta = FindMetaTable("Player")

-- gotta override `CheckLimit` to make it more onslaughty
function plyMeta:CheckLimit(limitName)
	local cvarName = LIMIT_TRANSLATIONS[limitName] or limitName
	local c = cvars.Number("ose_max" .. cvarName, 0)
	local count = self:GetCount(limitName)

	local ret = hook.Run("PlayerCheckLimit", self, limitName, count, c)
	if ret ~= nil then
		if not ret and SERVER then
			self:LimitHit(limitName)
		end
		return ret
	end

	if c < 0 then return true end

	if count >= c then
		if SERVER then
			self:LimitHit(limitName)
		end
		return false
	end

	return true
end

-- backup functions for when the player doesn't have a class
--- Returns the value in the money DTVar
--- @return integer
function plyMeta:GetMoneyVar()
	return self["GetDTInt"](self, 0)
end

--- Updates the player's money DTVar
--- @param amount integer
function plyMeta:SetMoneyVar(amount)
	self["SetDTInt"](self, 0, amount)
end

local MONEY_KEY = "OSEMoney"

--- Gets the player's current money
--- @param fromDatabase? true # If true (and the server)
--- @return integer
function plyMeta:GetMoney(fromDatabase)
	if CLIENT or not fromDatabase then
		return self:GetMoneyVar()
	end
	local money = tonumber(self:GetPData(MONEY_KEY, nil))
	if money == nil then
		money = hook.Run("GetStartingMoney", self)
		self:SetMoney(money)
	else
		-- Make sure the money var stays in sync
		self:SetMoneyVar(money)
	end
	return money
end

--- Updates the player's money
--- @param amount integer
function plyMeta:SetMoney(amount)
	if CLIENT then return end
	self:SetPData(MONEY_KEY, amount)
	self:SetMoneyVar(amount)
end

local INT32_MAX = 2147483647
if SERVER then
	util.AddNetworkString("OSE Money Notification")
end

--- Adds an arbitrary amount of money to the player.
--- The amount may be negative.
--- @param amount integer
--- @param reason? string # Reason to display to the player in a notification
--- @param ... any # Format args for reason
--- @return integer # The amount of money the user now has
function plyMeta:AddMoney(amount, reason, ...)
	local prevMoney = self:GetMoney(true)
	local newMoney = prevMoney + amount
	if newMoney < 0 then
		newMoney = 0
	elseif newMoney > INT32_MAX then
		-- shouldn't happen, potentially could if some server admin does
		-- something very silly though
		newMoney = INT32_MAX
	end
	self:SetMoney(newMoney)

	if SERVER and reason then
		net.Start("OSE Money Notification")
		net.WriteString(reason)
		net.WriteInt(newMoney - prevMoney, 32)
		net.WriteTable({ ... }, true)
		net.Send(self)
	end
	return newMoney
end

--- Checks if the player can afford to buy something
--- @param amount integer
--- @return boolean
function plyMeta:CanAfford(amount)
	local money = self:GetMoney()
	return money >= amount
end

--- Returns the class the player wants to be next time they spawn in battle mode
--- @return string # eg `player_soldier`
function plyMeta:GetTargetClass()
	local id = self:GetTargetClassID()
	if id == 0 then
		return "player_soldier"
	end
	return util.NetworkIDToString(id)
end

--- Sets the class the player wants to be next time they spawn in battle mode
--- @param targetClass string # validated classname, eg `player_soldier`
function plyMeta:SetTargetClass(targetClass)
	self:SetTargetClassID(util.NetworkStringToID(targetClass))
end

if SERVER then
	util.AddNetworkString("OSE Notification")

	NOTIFY_GENERIC = 0
	--- Error notification
	NOTIFY_ERROR = 1
	--- Sends the user a notification
	--- @param type `NOTIFY_GENERIC` | `NOTIFY_ERROR` # The type of notification to display
	--- @param text string # Text to display in the notification
	--- @param length integer # How long to display the notification for
	--- @param ... any # Format args for text
	function plyMeta:SendNotification(type, text, length, ...)
		if type < 0 or type > 1 then
			error("Unknown notification type " .. type)
		end
		net.Start("OSE Notification")
		net.WriteString(text)
		net.WriteUInt(type, 1)
		net.WriteUInt(math.Clamp(length, 0, 127), 7)
		net.WriteTable({ ... }, true)
		net.Send(self)
	end
end
