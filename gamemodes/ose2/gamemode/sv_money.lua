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

local startingMoneyCvar = GetConVar("ose_starting_money")

---@param player GPlayer
---@return integer
function GM:GetStartingMoney(player)
	return startingMoneyCvar:GetInt()
end

--- Checks if a player is allowed to use a particular ammo crate
--- @param ply GPlayer
--- @param crate SENT_OSEAmmoCrate
--- @return boolean
function GM:PlayerOpenAmmoCrate(ply, crate)
	-- Do we care about prop protection? Probably not
	return true
end

--- Called when a player successfully opens an ammo crate
--- @param ply GPlayer
--- @param crate SENT_OSEAmmoCrate
function GM:PlayerOpenedAmmoCrate(ply, crate)
	-- TODO: Ammo pannel mechanics go here!
	crate:OnPlayerFinished(ply)
end

--- Find a player by name, entindex or steamID
--- @param text string
--- @return GPlayer?
function FindPlayerConsole(text)
	local ply = player.GetBySteamID(text)
	if IsValid(ply) then
		return ply
	end
	ply = player.GetBySteamID64(text)
	if IsValid(ply) then
		return ply
	end

	text = string.lower(text)

	--- @type GPlayer[]
	local matches = {}
	for _, ply in ipairs(player.GetAll()) do
		--- @cast ply GPlayer
		local name = string.lower(ply:Name())
		if name == text then
			return ply
		elseif string.find(ply:Name(), text, 1, true) then
			matches[#matches + 1] = ply
		end
	end
	local numMatches = #matches
	if numMatches == 1 then
		return matches[1]
	elseif numMatches == 0 then
		print(
			"!!!",
			string.format(
				"No players match search string %q",
				text
			)
		)
	else
		print(
			"!!!",
			string.format(
				"%d players match search string %q:",
				numMatches,
				text
			)
		)
		for _, ply in ipairs(matches) do
			print(
				"!!!",
				string.format(
					"Player %d: %q / %q",
					ply:UserID(),
					ply:Name(),
					ply:SteamID()
				)
			)
		end
	end
	return nil
end

--- comment
--- @param lookup string
--- @return string[]
function PlayerNameAutoComplete(lookup)
	local ret = {}
	for _, ply in ipairs(player.GetAll()) do
		--- @cast ply GPlayer
		local name = ply:Name()
		if not lookup or name:StartsWith(lookup) then
			ret[#ret + 1] = name
		end
	end
	table.sort(ret)
	return ret
end

---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSESetMoney(ply, cmd, args)
	if IsValid(ply) and not ply:IsListenServerHost() then
		ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have permission to use this command")
	end
	local targetName = args[1]
	local amount = tonumber(args[2])
	if targetName == nil or amount == nil then
		print("Usage: ose_set_money playername amount")
		return
	end
	local target = FindPlayerConsole(args[1])
	if not target then
		return
	end
	target:SetMoney(amount)
end

---@param cmd string
---@param argStr string
---@param args string[]
---@return string[]
local function ccOSESetMoneyAutocomplete(cmd, argStr, args)
	if #args > 1 then
		return {}
	end
	return PlayerNameAutoComplete(argStr)
end
concommand.Add(
	"ose_set_money",
	ccOSESetMoney,
	ccOSESetMoneyAutocomplete,
	"Sets a user's money to a specific value"
)


---@param ply GPlayer
---@param cmd string
---@param args string[]
local function ccOSEAddMoney(ply, cmd, args)
	if IsValid(ply) and not ply:IsListenServerHost() then
		ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have permission to use this command")
	end
	local targetName = args[1]
	local amount = tonumber(args[2])
	if targetName == nil or amount == nil then
		print("Usage: ose_add_money playername amount")
		return
	end
	local target = FindPlayerConsole(args[1])
	if not target then
		return
	end
	target:AddMoney(amount, "ose.money.reason.admin")
end

---@param cmd string
---@param argStr string
---@param args string[]
---@return string[]
local function ccOSEAddMoneyAutocomplete(cmd, argStr, args)
	if #args > 1 then
		return {}
	end
	return PlayerNameAutoComplete(argStr)
end
concommand.Add(
	"ose_add_money",
	ccOSEAddMoney,
	ccOSEAddMoneyAutocomplete,
	"Give a user some money"
)
