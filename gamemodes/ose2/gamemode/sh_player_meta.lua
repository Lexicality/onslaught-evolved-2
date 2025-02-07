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

include("sandbox/gamemode/player_extension.lua")

local LIMIT_TRANSLATIONS = {
	ose_mine = "mines",
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

--- Adds an arbitrary amount of money to the player.
--- The amount may be negative.
--- @param amount integer
--- @return integer # The amount of money the user now has
function plyMeta:AddMoney(amount)
	local money = self:GetMoney(true)
	money = money + amount
	if money < 0 then
		money = 0
	elseif money > INT32_MAX then
		-- shouldn't happen, potentially could if some server admin does
		-- something very silly though
		money = INT32_MAX
	end
	self:SetMoney(money)
	return money
end

--- Checks if the player can afford to buy something
--- @param amount integer
--- @return boolean
function plyMeta:CanAfford(amount)
	local money = self:GetMoney()
	return money >= amount
end
